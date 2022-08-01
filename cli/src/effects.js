const chokidar = require('chokidar')
const path = require('path')
const Vite = require('vite')
const ElmVitePlugin = require('./vite-plugin/index.js')
const { Codegen } = require('./codegen')
const { Files } = require('./files')
const { Utils } = require('./commands/_utils')


let srcPagesFolderFilepath = path.join(process.cwd(), 'src', 'Pages')
let srcLayoutsFolderFilepath = path.join(process.cwd(), 'src', 'Layouts')

let runServer = async (options) => {
  try {
    let rawConfig = await Files.readFromUserFolder('elm-land.json')
    let config = JSON.parse(rawConfig)

    // Check if `.elm-land` folder exists
    let hasElmLandJsAlready =
      await Files.exists(path.join(process.cwd(), '.elm-land', 'server', 'main.js'))

    // If not, create a new one with the initial files
    if (!hasElmLandJsAlready) {
      await Files.copyPasteFolder({
        source: path.join(__dirname, 'templates', '_elm-land', 'server'),
        destination: path.join(process.cwd(), '.elm-land'),
      })
    }

    // Expose ENV variables to Vite explicitly allowed by the user
    attemptToLoadEnvVariablesFromUserConfig()

    // Listen for changes to static assets too
    let staticFolder = `${path.join(process.cwd(), 'static')}/**`
    let staticFolderWatcher = chokidar.watch(staticFolder, {
      ignorePermissionErrors: true,
      ignoreInitial: true
    })
    let indexHtmlPath = path.join(process.cwd(), '.elm-land', 'server', 'index.html')

    staticFolderWatcher.on('all', () => {
      Files.touch(indexHtmlPath)
    })

    // Listen for config changes
    let configFilepath = path.join(process.cwd(), 'elm-land.json')
    let configFileWatcher = chokidar.watch(configFilepath, {
      ignorePermissionErrors: true,
      ignoreInitial: true
    })

    configFileWatcher.on('change', async () => {
      try {
        let rawConfig = await Files.readFromUserFolder('elm-land.json')
        config = JSON.parse(rawConfig)
        let result = await generateHtml(config)
        if (result.problem) {
          console.info(result.problem)
        }
      } catch (_) { }

    })

    // Listen for changes to src/Pages and src/Layouts folders
    let srcPagesAndLayoutsFolderWatcher = chokidar.watch([srcPagesFolderFilepath, srcLayoutsFolderFilepath], {
      ignorePermissionErrors: true,
      ignoreInitial: true
    })

    srcPagesAndLayoutsFolderWatcher.on('all', generateElmFiles)
    await generateElmFiles()

    // Check config for Elm debugger options
    let debug = false

    try {
      if (process.env.NODE_ENV === 'production') {
        debug = config.app.elm.production.debugger
      } else {
        debug = config.app.elm.development.debugger
      }
    } catch (_) { }

    // Run the vite server on options.port 
    const server = await Vite.createServer({
      configFile: false,
      root: path.join(process.cwd(), '.elm-land', 'server'),
      publicDir: path.join(process.cwd(), 'static'),
      server: {
        port: options.port,
        fs: { allow: ['../..'] }
      },
      plugins: [
        ElmVitePlugin.plugin({
          debug,
          optimize: false
        })
      ],
      logLevel: 'silent'
    })

    await server.listen()

    return { problem: null, port: server.httpServer.address().port }
  } catch (e) {
    console.error(e)
    console.log('')
    return { problem: `❗️ Had trouble starting the server...` }
  }

}

let generateElmFiles = async () => {
  try {
    let pageFilepaths = Files.listElmFilepathsInFolder(srcPagesFolderFilepath)
    let layouts = Files.listElmFilepathsInFolder(srcLayoutsFolderFilepath).map(filepath => filepath.split('/'))

    let pages =
      await Promise.all(pageFilepaths.map(async filepath => {
        let contents = await Files.readFromUserFolder(`src/Pages/${filepath}.elm`)

        return {
          filepath: filepath.split('/'),
          contents
        }
      }))

    let newFiles = await Codegen.generateElmLandFiles({ pages, layouts })

    await Files.create(
      newFiles.map(generatedFile => ({
        kind: 'file',
        name: `.elm-land/src/${generatedFile.filepath}`,
        content: generatedFile.contents
      }))
    )

  } catch (err) {
    console.error(err)
  }
}

let attemptToLoadEnvVariablesFromUserConfig = () => {
  try {
    let config = require(path.join(process.cwd(), 'elm-land.json'))
    if (config) {
      if (config.app && config.app.env && Array.isArray(config.app.env)) {
        for (var key of config.app.env) {
          if (typeof key === 'string') {
            process.env[`VITE_${key}`] = process.env[key]
          }
        }
      }
    }
  } catch (_) { }
}

const attempt = (fn) => {
  try {
    return fn()
  } catch (_) {
    return undefined
  }
}

const customize = async (filepath) => {
  let source = path.join(__dirname, 'templates', '_elm-land', 'customizable', ...filepath.split('/'))
  let destination = path.join(process.cwd(), 'src', ...filepath.split('/'))

  let alreadyExists = await Files.exists(destination)

  if (!alreadyExists) {
    // Copy the default into the user's `src` folder
    await Files.copyPasteFile({
      source,
      destination,
    })
  }

  try {
    await Files.remove(path.join(process.cwd(), '.elm-land', 'src', ...filepath.split('/')))
  } catch (_) {
    // If the file isn't there, no worries
  }

  return { problem: null }
}

const build = async (config) => {

  // Create default files in `.elm-land/src` if they aren't already 
  // defined by the user in the `src` folder
  let defaultFilepaths = Object.values(Utils.customizableFiles)

  await Promise.all(defaultFilepaths.map(async filepath => {
    let fileInUsersSrcFolder = path.join(process.cwd(), 'src', ...filepath.split('/'))
    let fileInTemplatesFolder = path.join(__dirname, 'templates', '_elm-land', 'customizable', ...filepath.split('/'))
    let fileInElmLandSrcFolder = path.join(process.cwd(), '.elm-land', 'src', ...filepath.split('/'))

    let userSrcFileExists = await Files.exists(fileInUsersSrcFolder)

    if (!userSrcFileExists) {
      return Files.copyPasteFile({
        source: fileInTemplatesFolder,
        destination: fileInElmLandSrcFolder
      })
    }
  }))

  // Make sure initial files are up-to-date
  await Files.copyPasteFolder({
    source: path.join(__dirname, 'templates', '_elm-land', 'server'),
    destination: path.join(process.cwd(), '.elm-land'),
  })
  await Files.copyPasteFolder({
    source: path.join(__dirname, 'templates', '_elm-land', 'src'),
    destination: path.join(process.cwd(), '.elm-land'),
  })

  // Load ENV variables
  attemptToLoadEnvVariablesFromUserConfig()

  // Generate Elm files
  await generateElmFiles()

  // Build app in dist folder 
  await Vite.build({
    configFile: false,
    root: path.join(process.cwd(), '.elm-land', 'server'),
    publicDir: path.join(process.cwd(), 'static'),
    build: {
      outDir: '../../dist'
    },
    plugins: [
      ElmVitePlugin.plugin({
        debug: false,
        optimize: true
      })
    ],
    logLevel: 'silent'
  })

  return { problem: null }
}

// Generating index.html from elm-land.json file
const generateHtml = async (config) => {

  const escapeHtml = (unsafe) => {
    return unsafe
      .split('&',).join('&amp')
      .split('<',).join('&lt')
      .split('>',).join('&gt')
      .split('"',).join('&quot')
      .split("'",).join('&#039')
  }

  const escapeQuotes = (unsafe) => {
    return unsafe
      .split('"',).join('\"')
  }

  let toAttributeString = (object) => {
    if (!object || typeof object !== 'object' || Array.isArray(object)) {
      return ''
    }

    if (Object.keys(object).length === 0) {
      return ''
    }

    let attributes = []
    for (let key in object) {
      if (typeof object[key] === 'boolean') {
        attributes.push(
          (key))
      } else if (typeof object[key] === 'string') {
        attributes.push(`${escapeHtml(key)}="${escapeQuotes(object[key])}"`)
      }
    }
    return ' ' + attributes.join(' ')
  }

  let htmlAttributes = toAttributeString(attempt(() => config.app.html.attributes.html))
  let headAttributes = toAttributeString(attempt(() => config.app.html.attributes.head))
  let bodyAttributes = toAttributeString(attempt(() => config.app.html.attributes.body))


  let toHtmlTag = (tagName, attrs, child) => {
    return `<${tagName}${toAttributeString(attrs)}>${child}</${tagName}>`
  }

  let toSelfClosingHtmlTags = (tagName, tags = []) => {
    return tags.map(attrs =>
      Object.keys(attrs).length > 0
        ? `<${tagName}${toAttributeString(attrs)}>`
        : ''
    )
  }

  let titleTags = attempt(_ => config.app.html.title)
    ? [toHtmlTag('title', {}, config.app.html.title)]
    : []
  let metaTags = toSelfClosingHtmlTags('meta', attempt(_ => config.app.html.meta))
  let linkTags = toSelfClosingHtmlTags('link', attempt(_ => config.app.html.link))

  let combinedTags = [...titleTags, ...metaTags, ...linkTags]
  let headTags = combinedTags.length > 0
    ? '\n    ' + combinedTags.join('\n    ') + '\n  '
    : ''

  let htmlContent = `<!DOCTYPE html>
  <html${htmlAttributes}>
  <head${headAttributes}>${headTags}</head>
  <body${bodyAttributes}>
    <div id="app"></div>
    <script type="module" src="./main.js"></script>
  </body>
</html>`

  try {
    await Files.create([
      {
        kind: 'file',
        name: '.elm-land/server/index.html',
        content: htmlContent
      }
    ])
    return { problem: null }
  } catch (err) {
    return { problem: `❗️ Could not create an HTML file from ./elm-land.json` }
  }
}


let run = async (effects) => {
  // 1. Perform all effects, one at a time
  let results = []
  let port = process.env.PORT || 1234

  for (let effect of effects) {
    switch (effect.kind) {
      case 'runServer':
        let result = await runServer(effect.options)
        port = result.port
        results.push(result)
        break
      case 'generateHtml':
        results.push(await generateHtml(effect.config))
        break
      case 'build':
        results.push(await build(effect.config))
        break
      case 'customize':
        results.push(await customize(effect.filepath))
        break
      default:
        results.push({ problem: `❗️ Unrecognized effect: ${effect.kind}` })
        break
    }
  }

  // 2. Report the first problem you find (if any)
  for (let result of results) {
    if (result && result.problem) {
      return Promise.reject(result.problem)
    }
  }

  // 3. If there weren't any problems, great!
  return { problem: null, port }
}

module.exports = {
  Effects: { run }
}

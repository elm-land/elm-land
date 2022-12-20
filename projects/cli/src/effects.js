const chokidar = require('chokidar')
const path = require('path')
const Vite = require('vite')
const ElmVitePlugin = require('./vite-plugins/elm/index.js')
const TypeScriptPlugin = require('./vite-plugins/typescript/index.js')
const { Codegen } = require('./codegen')
const { Files } = require('./files')
const { Utils, Terminal } = require('./commands/_utils')


let srcPagesFolderFilepath = path.join(process.cwd(), 'src', 'Pages')
let srcLayoutsFolderFilepath = path.join(process.cwd(), 'src', 'Layouts')

const mode = () =>
  (process.env.NODE_ENV === 'production')
    ? 'production'
    : 'development'

let runServer = async (options) => {
  let server

  try {
    let rawConfig = await Files.readFromUserFolder('elm-land.json')
    let config = JSON.parse(rawConfig)

    // Handle any missing '.elm-land' files
    await handleElmLandFiles()

    // Expose ENV variables explicitly allowed by the user
    handleEnvironmentVariables({ config })

    // Listen for changes to the "src" folder, so the browser
    // automatically refreshes when an Elm file is changed
    let srcFolder = `${path.join(process.cwd(), 'src')}/**/*.elm`
    let srcFolderWatcher = chokidar.watch(srcFolder, {
      ignorePermissionErrors: true,
      ignoreInitial: true
    })
    let mainElmPath = path.join(process.cwd(), '.elm-land', 'src', 'Main.elm')

    srcFolderWatcher.on('all', () => {
      Files.touch(mainElmPath)
    })

    // Listen for changes to static assets, so the browser
    // automatically shows the latest asset changes
    let staticFolder = `${path.join(process.cwd(), 'static')}/**`
    let staticFolderWatcher = chokidar.watch(staticFolder, {
      ignorePermissionErrors: true,
      ignoreInitial: true
    })
    let indexHtmlPath = path.join(process.cwd(), '.elm-land', 'server', 'index.html')

    staticFolderWatcher.on('all', () => {
      Files.touch(indexHtmlPath)
    })

    // Listen for config file changes, regenerating the index.html
    // and restart server in case there were any changes to the environment variables
    let configFilepath = path.join(process.cwd(), 'elm-land.json')
    let configFileWatcher = chokidar.watch(configFilepath, {
      ignorePermissionErrors: true,
      ignoreInitial: true
    })
    configFileWatcher.on('change', async () => {
      try {
        let oldConfig = config
        let rawConfig = await Files.readFromUserFolder('elm-land.json')
        config = JSON.parse(rawConfig)
        let result = await generateHtml(config)

        // We'll need a better way to check options that affect codegen eventually
        if (config.app.router.useHashRouting != oldConfig.app.router.useHashRouting) {
          await generateElmFiles(config)
        }

        handleEnvironmentVariables({ config })

        server.restart(true)

        if (result.problem) {
          console.info(result.problem)
        }
      } catch (_) { }
    })

    // Listen for `.env` file changes, and restart the dev server
    let envFilepath = path.join(process.cwd(), '.env')
    let envFileWatcher = chokidar.watch(envFilepath, {
      ignorePermissionErrors: true,
      ignoreInitial: true
    })
    envFileWatcher.on('change', async () => {
      handleEnvironmentVariables({ config })
      server.restart(true)
    })

    // Listen for changes to interop file, so the page is automatically
    // refreshed and can see JS changes
    let interopFilepath = path.join(process.cwd(), 'src', 'interop.js')
    let mainJsPath = path.join(process.cwd(), '.elm-land', 'server', 'main.js')
    let interopFileWatcher = chokidar.watch(interopFilepath, {
      ignorePermissionErrors: true,
      ignoreInitial: true
    })

    interopFileWatcher.on('change', async () => {
      Files.touch(mainJsPath)
    })

    // Listen for changes to src/Pages and src/Layouts folders, to prevent
    // generated code from getting out of sync
    let srcPagesAndLayoutsFolderWatcher = chokidar.watch([srcPagesFolderFilepath, srcLayoutsFolderFilepath], {
      ignorePermissionErrors: true,
      ignoreInitial: true
    })

    srcPagesAndLayoutsFolderWatcher.on('all', () => { generateElmFiles(config) })
    await generateElmFiles(config)

    // Listen for any changes to customizable files, so defaults are recreated
    // if the customized versions are deleted
    let customizableFileFilepaths =
      Object.values(Utils.customizableFiles)
        .flatMap(({ filepaths }) => filepaths.map(filepath => path.join(process.cwd(), 'src', ...filepath.split('/'))))
    let customizedFilepaths = chokidar.watch(customizableFileFilepaths, {
      ignorePermissionErrors: true,
      ignoreInitial: true
    })
    customizedFilepaths.on('all', syncCustomizableFiles)

    // Check config for Elm debugger options
    let debug = false
    try { debug = config.app.elm[mode()].debugger }
    catch (_) { }

    const hasTsConfigJson = await Files.exists(path.join(process.cwd(), 'tsconfig.json'))

    // Run the vite server on options.port
    server = await Vite.createServer({
      configFile: false,
      root: path.join(process.cwd(), '.elm-land', 'server'),
      publicDir: path.join(process.cwd(), 'static'),
      envDir: process.cwd(),
      envPrefix: 'ELM_LAND_',
      server: {
        host: options.host,
        port: options.port,
        fs: { allow: ['../..'] }
      },
      plugins: [
        ElmVitePlugin.plugin({
          debug,
          optimize: false
        }),
        TypeScriptPlugin.plugin()
      ],
      logLevel: 'silent'
    })

    server.ws.on('error', (e) => console.error(e))

    await server.listen()

    return { problem: null, port: server.httpServer.address().port }
  } catch (e) {
    console.error(e)
    console.log('')
    return { problem: `❗️ Had trouble starting the server...` }
  }

}

let generateElmFiles = async (config) => {
  try {
    let router = config.app.router
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

    let newFiles = await Codegen.generateElmLandFiles({ pages, layouts, router })

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


let handleEnvironmentVariables = ({ config }) => {
  try {
    if (config && config.app && config.app.env && Array.isArray(config.app.env)) {
      const env = Vite.loadEnv(mode(), process.cwd(), '')
      let allowed = config.app.env.reduce((obj, key) => {
        obj[key] = env[key]
        return obj
      }, {})

      // Remove all variables with `ELM_LAND_` prefix
      for (var key in process.env) {
        if (key.startsWith('ELM_LAND_')) {
          delete process.env[key]
        }
      }

      // Provide env variables with prefixes, so they are
      // available in frontend code.
      Object.keys(allowed).forEach(key => {
        if (allowed[key]) {
          process.env['ELM_LAND_' + key] = allowed[key]
        }
      })

      return allowed
    }
  } catch (_) { }

  return {}
}

const attempt = (fn) => {
  try {
    return fn()
  } catch (_) {
    return undefined
  }
}

const customize = async (filepaths) => {
  await Promise.all(
    filepaths.map(async filepath => {
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
    })
  )

  return { problem: null }
}



const syncCustomizableFiles = async () => {
  let defaultFilepaths = Object.values(Utils.customizableFiles).flatMap(obj => obj.filepaths)

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
}

const handleElmLandFiles = async () => {
  await syncCustomizableFiles()

  await Files.copyPasteFolder({
    source: path.join(__dirname, 'templates', '_elm-land', 'server'),
    destination: path.join(process.cwd(), '.elm-land'),
  })
  await Files.copyPasteFolder({
    source: path.join(__dirname, 'templates', '_elm-land', 'src'),
    destination: path.join(process.cwd(), '.elm-land'),
  })
}

const build = async (config) => {
  // Create default files in `.elm-land/src` if they aren't already 
  // defined by the user in the `src` folder
  await handleElmLandFiles()

  // Ensure environment variables work as expected
  handleEnvironmentVariables({ config })

  // Generate Elm files
  await generateElmFiles(config)

  // Typecheck any TypeScript interop
  await TypeScriptPlugin.verifyTypescriptCompiles()

  // Build app in dist folder 
  try {
    await Vite.build({
      configFile: false,
      root: path.join(process.cwd(), '.elm-land', 'server'),
      publicDir: path.join(process.cwd(), 'static'),
      build: {
        outDir: '../../dist'
      },
      envDir: process.cwd(),
      envPrefix: 'ELM_LAND_',
      plugins: [
        ElmVitePlugin.plugin({
          debug: false,
          optimize: true
        })
      ],
      logLevel: 'silent'
    })
  } catch (err) {
    return handleViteBuildErrors(err)
  }

  return { problem: null }
}

const handleViteBuildErrors = (err) => {
  let message = (err ? err.message : '') || ''

  try {
    // Provide helpful error for missing local JS dependencies
    if (message.includes('Could not resolve')) {
      let [dependencyName, fileImportingPackage] = message.split('Could not resolve \'')[1].split(`' from `)
      fileImportingPackage = fileImportingPackage.split('\n')[0]

      message = [
        `    The file ${Terminal.cyan(fileImportingPackage)} tried to import`,
        `    another file at ${Terminal.pink(`"${dependencyName}"`)}, but it wasn't found.`,
        '',
        '    Maybe the file was deleted?'
      ].join('\n')
    }

    // Provide helpful error for missing NPM dependencies
    else if (message.includes('failed to resolve import')) {
      let [dependencyName, fileImportingPackage] = message.split('failed to resolve import ')[1].split(' from "')
      fileImportingPackage = fileImportingPackage.split('".')[0]

      message = [
        `    The file ${Terminal.cyan(fileImportingPackage)} tried to import`,
        `    an NPM package named ${Terminal.pink(dependencyName)}, but it wasn't found.`,
        '',
        `    Make sure to run ${Terminal.cyan('npm install')} before running this command.`
      ].join('\n')
    }

    return Promise.reject([
      '',
      Utils.intro.error('failed to build this project.'),
      message,
      ''
    ].join('\n'))
  } catch (_) { }

  return Promise.reject([
    '',
    Utils.intro.error('failed to build this project.'),
    `    Here's the problem that was reported:`,
    '',
    message.split('\n').map(line => '    ' + line).join('\n'),
    ''
  ].join('\n'))
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

  let toHtmlTags = (tagName, tags) => {
    return tags.map(attrs =>
      Object.keys(attrs).length > 0
        ? `<${tagName}${toAttributeString(attrs)}></${tagName}>`
        : ''
    )
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
  let scriptTags = toHtmlTags('script', attempt(_ => config.app.html.script))

  let combinedTags = [...titleTags, ...metaTags, ...linkTags, ...scriptTags]
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
  let port = undefined;

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
        results.push(await customize(effect.filepaths))
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

const chokidar = require('chokidar')
const path = require('path')
const Vite = require('vite')
const ElmVitePlugin = require('vite-plugin-elm')
const { Files } = require('./files')

let runServer = async (options) => {
  try {
    // Check if `.elm-land` folder exists
    let hasElmLandJsAlready =
      await Files.exists(path.join(process.cwd(), '.elm-land', 'server', 'main.js'))

    // If not, create a new one with the initial files
    if (!hasElmLandJsAlready) {
      await Files.copyPaste({
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
      let config = {}

      try {
        let rawConfig = await Files.readFromUserFolder('elm-land.json')
        config = JSON.parse(rawConfig)
      } catch (_) { }

      let result = await generateHtml(config)
      if (result.problem) {
        console.info(result.problem)
      }
    })

    // Run the vite server on options.port 
    const server = await Vite.createServer({
      configFile: false,
      root: path.join(process.cwd(), '.elm-land', 'server'),
      publicDir: path.join(process.cwd(), 'static'),
      server: {
        port: options.port
      },
      plugins: [
        ElmVitePlugin.plugin({
          debug: false,
          optimize: false
        })
      ],
      logLevel: 'silent'
    })

    await server.listen()

    return { problem: null }
  } catch (e) {
    console.error(e)
    console.log('')
    return { problem: `❗️ Had trouble starting the server...` }
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


// Generating index.html from elm-land.json file
const generateHtml = async (config) => {

  const escapeHtml = (unsafe) => {
    return unsafe
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#039;')
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
        attributes.push(escapeHtml(key))
      } else if (typeof object[key] === 'string') {
        attributes.push(`${escapeHtml(key)}="${escapeHtml(object[key])}"`)
      }
    }
    return ' ' + attributes.join(' ')
  }

  let htmlAttributes = toAttributeString(config?.app?.html?.attributes?.html)
  let headAttributes = toAttributeString(config?.app?.html?.attributes?.head)
  let bodyAttributes = toAttributeString(config?.app?.html?.attributes?.body)


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

  let titleTags = config?.app?.html?.title
    ? [toHtmlTag('title', {}, config.app.html.title)]
    : []
  let metaTags = toSelfClosingHtmlTags('meta', config?.app?.html?.meta)
  let linkTags = toSelfClosingHtmlTags('link', config?.app?.html?.link)

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

  for (let effect of effects) {
    switch (effect.kind) {
      case 'runServer':
        results.push(await runServer(effect.options))
        break
      case 'generateHtml':
        results.push(await generateHtml(effect.config))
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
  return { problem: null }
}

module.exports = {
  Effects: { run }
}
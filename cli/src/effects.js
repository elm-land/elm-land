const path = require('path')
const Vite = require('vite')
const ElmVitePlugin = require('vite-plugin-elm')
const { Files } = require('./files')

let runServer = async (options) => {
  try {
    // Check if `.elm-land` folder exists
    let hasElmLandFolderAlready =
      await Files.exists(path.join(process.cwd(), '.elm-land', 'server'))

    // If not, create a new one with the initial files
    if (hasElmLandFolderAlready === false) {
      await Files.copyPaste({
        source: path.join(__dirname, 'templates', '_elm-land', 'server'),
        destination: path.join(process.cwd(), '.elm-land'),
      })
    }

    // Expose ENV variables to Vite explicitly allowed by the user
    attemptToLoadEnvVariablesFromUserConfig()

    // Run the vite server on options.port 
    const server = await Vite.createServer({
      configFile: false,
      root: path.join(process.cwd(), '.elm-land', 'server'),
      publicDir: path.join(process.cwd(), 'static'),
      server: {
        port: options.port,
        watch: {
          disableGlobbing: false,
          include: `${path.join(process.cwd(), 'static')}/**`,
        }
      },
      plugins: [
        ElmVitePlugin.plugin({
          debug: false,
          optimize: false
        })
      ],
      logLevel: 'silent'
    })

    // Add static folder to watch list
    addStaticFolderToWatcher(server)

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

let addStaticFolderToWatcher = ({ watcher }) => {
  watcher.on('all', (event, path) => {
    console.log('hey!', { event, path })
  })
}

let run = async (effects) => {
  // 1. Perform all effects, one at a time
  let results = []

  for (let effect of effects) {
    switch (effect.kind) {
      case 'runServer':
        let result = await runServer(effect.options)
        results.push(result)
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
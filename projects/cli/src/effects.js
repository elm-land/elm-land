import { watch } from 'chokidar'
import { join } from 'path'
import { createServer, loadEnv, build as _build } from 'vite'
import ElmVitePlugin from 'vite-plugin-elm-watch'
import * as ElmErrorJson from 'vite-plugin-elm-watch/src/elm-error-json.js'
import * as TypeScriptPlugin from './vite-plugins/typescript/index.js'
import { Codegen } from './codegen.js'
import { Files } from './files.js'
import { Utils, Terminal } from './commands/_utils.js'
import { validate } from './validate/index.js'
import path from 'path'
import url from 'url'

const isWindows = process.platform === "win32"

let __dirname = path.dirname(url.fileURLToPath(import.meta.url))
let srcPagesFolderFilepath = join(process.cwd(), 'src', 'Pages')
let srcLayoutsFolderFilepath = join(process.cwd(), 'src', 'Layouts')

process.on('uncaughtException', function (err) {
  if (err.code === 'EPERM') {
    console.error([
      '',
      Utils.intro.error('could not start the server...'),
      `    This problem can be fixed by running the ${Terminal.pink('npm init -y')} command`,
      `    from your terminal.`,
      ``,
      `    If the issue persists after running that command, please let us`,
      `    know in the Elm Land Discord (${Terminal.dim('https://join.elm.land')})`,
      ''
    ].join('\n'))
    process.exit(1)
  } else {
    throw err
  }
})


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

    if (isWindows) {
      // Listen for changes to the "src" folder, so the browser
      // automatically refreshes when an Elm file is changed
      let srcFolder = `${join(process.cwd(), 'src')}/**/*.elm`
      let srcFolderWatcher = watch(srcFolder, {
        ignorePermissionErrors: true,
        ignoreInitial: true
      })
      let mainElmPath = join(process.cwd(), '.elm-land', 'src', 'Main.elm')

      srcFolderWatcher.on('all', () => {
        Files.touch(mainElmPath)
      })
    }

    // Listen for changes to static assets, so the browser
    // automatically shows the latest asset changes
    let staticFolder = `${join(process.cwd(), 'static')}/**`
    let staticFolderWatcher = watch(staticFolder, {
      ignorePermissionErrors: true,
      ignoreInitial: true
    })
    staticFolderWatcher.on('all', () => {
      Files.touch(mainJsPath)
    })

    // Listen for config file changes, regenerating the index.html
    // and restart server in case there were any changes to the environment variables
    let configFilepath = join(process.cwd(), 'elm-land.json')
    let configFileWatcher = watch(configFilepath, {
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
          await generateElmFiles(config, server)
        }

        handleEnvironmentVariables({ config })

        server.restart(true)

        if (result.problem) {
          console.info(result.problem)
        }
      } catch (_) { }
    })

    // Listen for `.env` file changes, and restart the dev server
    let envFilepath = join(process.cwd(), '.env')
    let envFileWatcher = watch(envFilepath, {
      ignorePermissionErrors: true,
      ignoreInitial: true
    })
    envFileWatcher.on('change', async () => {
      handleEnvironmentVariables({ config })
      server.restart(true)
    })

    // Listen for changes to interop file, so the page is automatically
    // refreshed and can see JS changes
    let interopFilepath = join(process.cwd(), 'src', 'interop.js')
    let mainJsPath = join(process.cwd(), '.elm-land', 'server', 'main.js')
    let interopFileWatcher = watch(interopFilepath, {
      ignorePermissionErrors: true,
      ignoreInitial: true
    })

    interopFileWatcher.on('change', async () => {
      Files.touch(mainJsPath)
    })

    // Listen for changes to src/Pages and src/Layouts folders, to prevent
    // generated code from getting out of sync
    let srcPagesAndLayoutsAndCustomizedFileWatcher = watch([
      srcPagesFolderFilepath,
      srcLayoutsFolderFilepath,
      join(process.cwd(), 'src', 'Auth.elm'),
      join(process.cwd(), 'src', 'Shared.elm'),
      join(process.cwd(), 'src', 'Shared', 'Model.elm'),
      join(process.cwd(), 'src', 'Shared', 'Msg.elm'),
      join(process.cwd(), 'src', 'Effect.elm'),
      join(process.cwd(), 'src', 'View.elm')
    ], {
      ignorePermissionErrors: true,
      ignoreInitial: true
    })

    // srcPagesAndLayoutsFolderWatcher.on('all', () => { generateElmFiles(config, server) })
    srcPagesAndLayoutsAndCustomizedFileWatcher.on('all', () => { generateElmFiles(config, server) })

    // Listen for any changes to customizable files, so defaults are recreated
    // if the customized versions are deleted
    let customizableFileFilepaths =
      Object.values(Utils.customizableFiles)
        .flatMap(({ filepaths }) => filepaths.map(filepath => join(process.cwd(), 'src', ...filepath.target.split('/'))))
    let customizedFilepaths = watch(customizableFileFilepaths, {
      ignorePermissionErrors: true,
      ignoreInitial: true
    })
    customizedFilepaths.on('all', syncCustomizableFiles)

    // Check config for Elm debugger options
    let debug = false
    try { debug = config.app.elm[mode()].debugger }
    catch (_) { }

    // Check for optional proxy field:
    let proxy = null
    try { 
      proxy = config.app.proxy

      // Check for optional `pathRewrite` object, and use it to create a Vite-compatible `rewrite` function
      for (const target of Object.values(proxy)) {
        if (typeof target !== 'string' && target.pathRewrite != null) {
          target.rewrite = path => {
            for (const [pattern, replacement] of Object.entries(target.pathRewrite)) {
              const regExp = new RegExp(pattern)
              if (regExp.test(path)) {
                // Use only the first match
                return path.replace(regExp, replacement)
              }
            }
            return path
          }
        }
      }
    }
    catch (_) { }

    /**
     * This plugin allows me to keep the `index.html` file out of
     * the root of the repository.
     * 
     * It works by replacing the built-in 'viteIndexHtmlMiddleware' middleware
     * at runtime with one that provides a "virtual" index.html file instead.
     * 
     */
    const ElmLandIndexHtml = {
      /**
       * @returns {import('vite').Plugin}
       */
      plugin() {
        return {
          name: 'elmLandIndexHtml',
          configureServer(server_) {
            let virtualIndexHtmlHandler = async function elmLandIndexHtmlMiddleware(req, res, next) {
              let virtualIndexHtmlContents = toIndexHtmlFile(config, '/.elm-land/server/main.js')
              res.setHeader('Content-Type', 'text/html')
              res.end(virtualIndexHtmlContents)
            }

            setTimeout(() => {
              for (let index in server_.middlewares.stack) {
                let item = server_.middlewares.stack[index]
                if (item.handle.name === 'viteIndexHtmlMiddleware') {
                  let viteIndexHtmlMiddleware = item.handle
                  item.handle = async function viteIndexHtmlMiddlewareMod(req, res, next) {
                    return new Promise(async (resolve, reject) => {
                      let myNext = () => virtualIndexHtmlHandler(req, res, next).then(_ => resolve()).catch(reject)
                      await viteIndexHtmlMiddleware(req, res, myNext)
                    })
                  }
                  return
                }
              }

              // Only prints if a new version of Vite changed the name
              // "viteIndexHtmlMiddleware"
              console.error('‼️ FATAL ', 'viteIndexHtmlMiddleware was not found')
            }, 0)
          }
        }
      }
    }

    // Run the vite server on options.port
    server = await createServer({
      configFile: false,
      root: process.cwd(),
      publicDir: join(process.cwd(), 'static'),
      envDir: process.cwd(),
      envPrefix: 'ELM_LAND_',
      cacheDir: join(process.cwd(), '.elm-land', 'server', '.vite'),
      server: {
        host: options.host,
        port: options.port,
        fs: { allow: ['../..'] },
        proxy
      },
      plugins: [
        ElmVitePlugin({
          mode: debug ? 'debug' : 'standard',
          isBodyPatchEnabled: false
        }),
        ElmLandIndexHtml.plugin()
      ],
      logLevel: 'silent',
      appType: 'spa'
    })

    server.ws.on('error', (e) => console.error(e))
    server.ws.on('elm:client-ready', (client) => {
      id = client.id
      if (lastErrorSent) {
        let error = ElmErrorJson.toColoredHtmlOutput(lastErrorSent)
        server.ws.send('elm:error', {
          id,
          error
        })
      }
    })

    await generateElmFiles(config, server)

    await server.listen()

    return { problem: null, port: server.httpServer.address().port }
  } catch (e) {
    console.error(e)
    console.log('')
    return { problem: `❗️ Had trouble starting the server...` }
  }
}

let lastErrorSent = undefined
let id = null

let generateElmFiles = async (config, server = undefined) => {
  try {
    let router = config.app.router
    let pageFilepaths = Files.listElmFilepathsInFolder(srcPagesFolderFilepath)
    let layoutFilepaths = Files.listElmFilepathsInFolder(srcLayoutsFolderFilepath)

    let pages =
      await Promise.all(pageFilepaths.map(async filepath => {
        let contents = await Files.readFromUserFolder(`src/Pages/${filepath}.elm`)

        return {
          filepath: filepath.split('/'),
          contents
        }
      }))

    let layouts =
      await Promise.all(layoutFilepaths.map(async filepath => {
        let contents = await Files.readFromUserFolder(`src/Layouts/${filepath}.elm`)

        return {
          filepath: filepath.split('/'),
          contents
        }
      }))

    let view = await Files.readFromUserFolder('src/View.elm').catch(_ => null)

    let errors = await validate({
      pages,
      layouts,
      auth: await Files.readFromUserFolder('src/Auth.elm').catch(_ => null),
      shared: await Files.readFromUserFolder('src/Shared.elm').catch(_ => null),
      sharedModel: await Files.readFromUserFolder('src/Shared/Model.elm').catch(_ => null),
      sharedMsg: await Files.readFromUserFolder('src/Shared/Msg.elm').catch(_ => null),
      effect: await Files.readFromUserFolder('src/Effect.elm').catch(_ => null),
      view
    })

    // Always generate Elm Land files
    let layoutsData = layouts.map(({ filepath, contents }) => {
      const typeVariablePattern = 'type alias Props contentMsg'
      const isUsingTypeVariable = contents.includes(typeVariablePattern)

      return {
        segments: filepath,
        isUsingTypeVariable
      }
    })

    let newFiles = await Codegen.generateElmLandFiles({
      pages,
      layouts: layoutsData,
      router
    })

    await Files.create(
      newFiles.map(generatedFile => ({
        kind: 'file',
        name: `.elm-land/src/${generatedFile.filepath}`,
        content: generatedFile.contents
      }))
    )

    if (errors.length === 0) {
      if (server) {
        lastErrorSent = undefined
        server.ws.send('elm:success', { id })
      }
    } else if (server) {
      lastErrorSent = errors[0]
      server.ws.send('elm:error', {
        id,
        error: ElmErrorJson.toColoredHtmlOutput(errors[0])
      })
    } else {
      // console.log({ errors })
      return Promise.reject([
        '',
        Utils.intro.error('failed to build project'),
        errors.map(ElmErrorJson.toColoredTerminalOutput).join('\n\n'),
        ''
      ].join('\n'))
    }

  } catch (err) {
    console.error(err)
  }
}


let handleEnvironmentVariables = ({ config }) => {
  try {
    if (config && config.app && config.app.env && Array.isArray(config.app.env)) {
      const env = loadEnv(mode(), process.cwd(), '')
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
      let source = join(__dirname, 'templates', '_elm-land', 'customizable', ...filepath.src.split('/'))
      let destination = join(process.cwd(), 'src', ...filepath.target.split('/'))

      let alreadyExists = await Files.exists(destination)

      if (!alreadyExists) {
        // Copy the default into the user's `src` folder
        await Files.copyPasteFile({
          source,
          destination,
        })
      }

      try {
        await Files.remove(join(process.cwd(), '.elm-land', 'src', ...filepath.target.split('/')))
      } catch (_) {
        // If the file isn't there, no worries
      }
    })
  )

  return { problem: null }
}



const syncCustomizableFiles = async () => {
  let defaultFilepaths = Object.values(Utils.customizableFiles)
    .flatMap(obj => obj.filepaths)
    .filter(filepath => filepath.src === filepath.target)

  await Promise.all(defaultFilepaths.map(async filepath => {
    let fileInUsersSrcFolder = join(process.cwd(), 'src', ...filepath.target.split('/'))
    let fileInTemplatesFolder = join(__dirname, 'templates', '_elm-land', 'customizable', ...filepath.src.split('/'))
    let fileInElmLandSrcFolder = join(process.cwd(), '.elm-land', 'src', ...filepath.target.split('/'))

    let usersSrcFileExists = await Files.exists(fileInUsersSrcFolder)

    if (usersSrcFileExists) {
      let elmLandSrcFileExists = await Files.exists(fileInElmLandSrcFolder)

      if (elmLandSrcFileExists) {
        return Files.remove(fileInElmLandSrcFolder)
      }
    } else {
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
    source: join(__dirname, 'templates', '_elm-land', 'server'),
    destination: join(process.cwd(), '.elm-land'),
  })
  await Files.copyPasteFolder({
    source: join(__dirname, 'templates', '_elm-land', 'src'),
    destination: join(process.cwd(), '.elm-land'),
  })
}

const generate = async (config) => {
  // Create default files in `.elm-land/src` if they aren't already
  // defined by the user in the `src` folder
  await handleElmLandFiles()

  // Generate Elm files
  await generateElmFiles(config)

  return { problem: null }
}

const build = async (config) => {
  // Generates remaining Elm files in .elm-land/src
  await generate(config)

  // Ensure environment variables work as expected
  handleEnvironmentVariables({ config })

  // Typecheck any TypeScript interop
  await TypeScriptPlugin.verifyTypescriptCompiles()

  // Build app in dist folder
  try {
    await _build({
      configFile: false,
      root: join(process.cwd(), '.elm-land', 'server'),
      publicDir: join(process.cwd(), 'static'),
      build: { outDir: '../../dist' },
      envDir: process.cwd(),
      envPrefix: 'ELM_LAND_',
      plugins: [
        ElmVitePlugin({
          mode: 'minify',
          isBodyPatchEnabled: false
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
const toIndexHtmlFile = (config, pathToMainJs) => {
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

  let toHtmlTag = (tagName, attrs, child) => {
    return `<${tagName}${toAttributeString(attrs)}>${child}</${tagName}>`
  }

  let toHtmlTags = (tagName, tags = []) => {
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
  let metaTags = toSelfClosingHtmlTags('meta', [
    { name: 'elm-land', content: '0.20.1' }
  ].concat(attempt(_ => config.app.html.meta)))
  let linkTags = toSelfClosingHtmlTags('link', attempt(_ => config.app.html.link))
  let scriptTags = toHtmlTags('script', attempt(_ => config.app.html.script))

  let combinedTags = [...titleTags, ...metaTags, ...linkTags, ...scriptTags]
  let headTags = combinedTags.length > 0
    ? '\n    ' + combinedTags.join('\n    ') + '\n  '
    : ''

  let htmlContent = `<!DOCTYPE html>
<html${htmlAttributes}>
<head${headAttributes}>${headTags}</head>
<body>
  <script type="module" src="${pathToMainJs}"></script>
</body>
</html>`
  return htmlContent
}

const generateHtml = async (config) => {
  try {
    await Files.create([
      {
        kind: 'file',
        name: '.elm-land/server/index.html',
        content: toIndexHtmlFile(config, './main.js')
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
  let port = undefined

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
      case 'generate':
        results.push(await generate(effect.config))
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

export const Effects = { run }

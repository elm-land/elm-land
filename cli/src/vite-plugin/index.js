const { toESModule } = require('elm-esm')
const compiler = require('node-elm-compiler')
const { relative } = require('path')
const { injectHMR } = require('./hmrInjector')
const { acquireLock } = require('./mutex')
const { default: ElmErrorJson } = require('./elm-error-json.js')

const trimDebugMessage = (code) => code.replace(/(console\.warn\('Compiled in DEBUG mode)/, '// $1')
const viteProjectPath = (dependency) => `/${relative(process.cwd(), dependency)}`

const parseImportId = (id) => {
  const parsedId = new URL(id, 'file://')
  const pathname = parsedId.pathname
  const valid = pathname.endsWith('.elm')
  const withParams = parsedId.searchParams.getAll('with')

  return {
    valid,
    pathname,
    withParams,
  }
}

const plugin = (opts) => {
  const compilableFiles = new Map()
  const debug = opts ? opts.debug : undefined
  const optimize = opts ? opts.optimize : undefined

  let lastErrorSent = undefined
  let server = undefined

  return {
    name: 'vite-plugin-elm',
    enforce: 'pre',
    handleHotUpdate({ file, server, modules }) {
      const { valid } = parseImportId(file)
      if (!valid) return

      const modulesToCompile = []
      compilableFiles.forEach((dependencies, compilableFile) => {
        if (dependencies.has(file)) {
          const module = server.moduleGraph.getModuleById(compilableFile)
          if (module) modulesToCompile.push(module)
        }
      })

      if (modulesToCompile.length > 0) {
        server.ws.send({
          type: 'custom',
          event: 'hot-update-dependents',
          data: modulesToCompile.map(({ url }) => url),
        })
        return modulesToCompile
      } else {
        return modules
      }
    },
    configureServer(server_) {
      server = server_
      server.ws.on('connection', () => {
        if (lastErrorSent) {
          server.ws.send('elm:error', {
            error: ElmErrorJson.toColoredHtmlOutput(lastErrorSent)
          })
        }
      })
    },
    async load(id) {
      const { valid, pathname, withParams } = parseImportId(id)
      if (!valid) return

      const accompanies = await (() => {
        if (withParams.length > 0) {
          const importTree = this.getModuleIds()
          let importer = ''
          for (const moduleId of importTree) {
            if (moduleId === id) break
            importer = moduleId
          }
          const resolveAcoompany = async (accompany) => {
            let thing = await this.resolve(accompany, importer)
            return thing && thing.id ? thing.id : ''
          }
          return Promise.all(withParams.map(resolveAcoompany))
        } else {
          return Promise.resolve([])
        }
      })()

      const targets = [pathname, ...accompanies].filter((target) => target !== '')

      compilableFiles.delete(id)
      const dependencies = (
        await Promise.all(targets.map((target) => compiler.findAllDependencies(target)))
      ).flat()
      compilableFiles.set(id, new Set([...accompanies, ...dependencies]))

      const releaseLock = await acquireLock()
      const isBuild = process.env.NODE_ENV === 'production'
      try {
        const compiled = await compiler.compileToString(targets, {
          output: '.js',
          optimize: typeof optimize === 'boolean' ? optimize : !debug && isBuild,
          verbose: isBuild,
          debug: debug ?? !isBuild,
          report: 'json'
        })

        const esm = toESModule(compiled)

        // Apparently `addWatchFile` may not exist: https://github.com/hmsk/vite-plugin-elm/pull/36
        if (this.addWatchFile) {
          dependencies.forEach(this.addWatchFile.bind(this))
        }

        lastErrorSent = null
        server.ws.send('elm:success', { msg: 'Success!' })

        return {
          code: isBuild ? esm : trimDebugMessage(injectHMR(esm, dependencies.map(viteProjectPath))),
          map: null,
        }
      } catch (e) {
        if (e instanceof Error && e.message.includes('-- NO MAIN')) {
          const message = `${viteProjectPath(
            pathname,
          )}: NO MAIN .elm file is requested to transform by vite. Probably, this file is just a depending module`
          throw message
        } else {
          if (isBuild) {
            throw e
          } else {
            let elmError = ElmErrorJson.parse(e.message)
            lastErrorSent = elmError
            server.ws.send('elm:error', {
              error: ElmErrorJson.toColoredHtmlOutput(elmError)
            })


            return {
              code: `export const Elm = new Proxy({}, () => ({ init: () => {} }))`,
              map: null
            }
          }
        }
      } finally {
        releaseLock()
      }
    },
  }
}

module.exports = {
  plugin
}
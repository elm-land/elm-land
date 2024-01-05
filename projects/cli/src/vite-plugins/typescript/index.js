import path from 'path'
import fs from 'fs'
import ChildProcess from 'child_process'
import { Terminal, Utils, toDirname } from '../../commands/_utils.js'
import { Files } from '../../files.js'

// Here's where we'll expect to find the Typescript binary installed
const tscPaths = {
  // When locally installed with `npm install -D elm-land`
  // ✅ Tested with npm install -D, yarn, pnpm i
  local: path.join(toDirname(import.meta.url), '..', '..', '..', '..', 'typescript', 'bin', 'tsc'),
  // When globally installed with `npm install -g elm-land`
  // ✅ Tested with npm install -g, yarn, pnpm
  global: path.join(toDirname(import.meta.url), '..', '..', '..', 'node_modules', '.bin', 'tsc'),
}

const pathToTsc =
  fs.existsSync(tscPaths.global)
    ? tscPaths.global
    : tscPaths.local

const parseImportId = (id) => {
  const parsedId = new URL(id, 'file://')
  const pathname = parsedId.pathname
  const valid = pathname.endsWith('.ts')

  return {
    valid,
  }
}

const plugin = () => {
  return {
    name: 'vite-plugin-typescript',
    enforce: 'pre',
    async load(file) {
      const { valid } = parseImportId(file)
      if (!valid) return

      try {
        let errors = await reportTypeScriptErrors()
        if (errors) {
          throw new Error([
            `TYPESCRIPT ERROR ` + '-'.repeat(66),
            ...errors.map(formatTypeScriptError)
          ].join('\n\n'))
        }
      } catch (err) {
        if (err && typeof err.message === 'string') {
          throw new Error(err.message)
        } else if (typeof err === 'string') {
          throw new Error(err)
        } else {
          throw new Error('Failed to compile "src/interop.ts"')
        }
      }
    },
  }
}

const formatTypeScriptError = (str) => {
  if (str) {
    let [file, code, ...message] = str.split(': ')
    if (str.startsWith('src') && file && code) {
      return [
        file + ' '.repeat(Math.max(83 - file.length - code.length, 0)) + code,
        message.join(': ')
      ].join('\n\n')
    }
  }
  return str
}

const checkForTypeScriptInteropFile = () =>
  Files.exists(path.join(process.cwd(), 'src', 'interop.ts'))

const handleUnexpectedTypeScriptError = (reject) => (err) => {
  if (err.code === 'ENOENT') {
    reject(Utils.couldntFindTypeScriptBinary(pathToTsc))
  } else {
    reject(err)
  }
}

const spawnNewTypeScriptBuild = () =>
  ChildProcess.spawn(pathToTsc, argsForTypeScript())

const argsForTypeScript = () => {
  const pathToTsConfigFile = path.join(process.cwd(), 'tsconfig.json')
  const hasTsConfigFile = fs.existsSync(pathToTsConfigFile)

  if (hasTsConfigFile) {
    return ['--project', pathToTsConfigFile]
  } else {
    return ['src/interop.ts', '--noEmit', '--lib', 'es6,dom']
  }
}

// Used during `elm-land server` to report errors
// to users via the HMR overlay
const reportTypeScriptErrors = async () => {
  let hasInteropTs = await checkForTypeScriptInteropFile()

  if (hasInteropTs) {
    return new Promise((resolve, reject) => {
      let tsc = spawnNewTypeScriptBuild()
      tsc.on('error', handleUnexpectedTypeScriptError(reject))

      let compileErrors = []
      if (tsc.stdout) {
        tsc.stdout.on('data', (data) => {
          compileErrors.push(data.toString())
        })
      }

      tsc.on('close', (code) => {
        if (code !== 0) {
          if (compileErrors.length > 0) {
            resolve(compileErrors)
          }
        } else {
          resolve(undefined)
        }
      })
    })
  } else {
    return undefined
  }
}

// Used during `elm-land build` to report errors
// to users via the terminal (in full color!)
const verifyTypescriptCompiles = async (mode) => {
  const hasInteropTs = await checkForTypeScriptInteropFile()

  if (hasInteropTs) {
    return new Promise((resolve, reject) => {
      console.info('\n' + Utils.intro.info(`is compiling ${Terminal.cyan('src/interop.ts')}...`))

      let tsc = ChildProcess.spawn(pathToTsc, argsForTypeScript(), { stdio: 'inherit' })
      tsc.on('error', handleUnexpectedTypeScriptError(reject))

      tsc.on('close', (code) => {
        if (code !== 0) {
          reject(Utils.foundTypeScriptErrors)
        } else {
          resolve(true)
        }
      })
    })
  } else {
    return true
  }
}

export default {
  plugin,
  verifyTypescriptCompiles
}
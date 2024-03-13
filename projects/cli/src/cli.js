import { Init } from './commands/init.js'
import { Add } from './commands/add.js'
import { Server } from './commands/server.js'
import { Generate } from './commands/generate.js'
import { Build } from './commands/build.js'
import { Customize } from './commands/customize.js'
import { Routes } from './commands/routes.js'
import { Utils, Terminal } from './commands/_utils.js'
import fs from 'fs/promises'
import path from 'path'
import url from 'url'

let __dirname = path.dirname(url.fileURLToPath(import.meta.url))
let packageJsonContents = await fs.readFile(path.join(__dirname, '..', 'package.json'), { encoding: 'utf-8' })
let packageJson = JSON.parse(packageJsonContents)
let version = packageJson.version

let subcommandList = [
  `    Here are the available commands:`,
  ``,
  `    ✨ elm-land ${Terminal.pink('init <folder-name>')} ...... create a new project`,
  `    🚀 elm-land ${Terminal.pink('server')} ................ run a local dev server`,
  `    📦 elm-land ${Terminal.pink('build')} .......... build your app for production`,
  `    🪄 elm-land ${Terminal.pink('generate')} ............. generate Elm Land files`,
  `    📄 elm-land ${Terminal.pink('add page <url>')} ................ add a new page`,
  `    🍱 elm-land ${Terminal.pink('add layout <name>')} ........... add a new layout`,
  `    🔧 elm-land ${Terminal.pink('customize <name>')} .. customize a default module`,
  `    🔍 elm-land ${Terminal.pink('routes')} ........... list all routes in your app`,
]


let run = async (commandFromCli) => {
  // ( This function accepts a string or string[] )
  let command = typeof commandFromCli === 'string'
    ? commandFromCli.split(' ')
    : commandFromCli


  let [_npx, _elmLand, subCommand, ...args] = command

  // Elm Land will make sure these similar commands
  // still work, for users switching from other tools.
  // 
  // This means typing "elm-land new" will automatically
  // be translated to "elm-land init" so the right thing
  // happens
  // 
  let aliases = {
    'new': 'init',
    'create': 'init',
    'make': 'build',
  }

  if (aliases[subCommand]) {
    subCommand = aliases[subCommand]
  }

  let subcommandHandlers = {
    'init': ([folderName] = []) => {
      if (isHelpFlag(folderName)) {
        return Init.printHelpInfo()
      } else {
        return Init.run({ name: folderName })
      }
    },
    'add': (args = []) => {
      if (isHelpFlag(args[0])) {
        return Add.printHelpInfo()
      } else {
        return Add.run({ args })
      }
    },
    'server': (args = []) => {
      if (isHelpFlag(args[0])) {
        return Server.printHelpInfo()
      } else {
        return Server.run({})
      }
    },
    'generate': (args = []) => {
      if (isHelpFlag(args[0])) {
        return Generate.printHelpInfo()
      } else {
        return Generate.run({})
      }
    },
    'build': (args = []) => {
      if (isHelpFlag(args[0])) {
        return Build.printHelpInfo()
      } else {
        return Build.run({})
      }
    },
    'customize': ([moduleName] = []) => {
      if (isHelpFlag(moduleName)) {
        return Customize.printHelpInfo()
      } else {
        return Customize.run({ moduleName })
      }
    },
    'routes': ([url] = []) => {
      if (isHelpFlag(url)) {
        return Routes.printHelpInfo()
      } else {
        return Routes.run({ url })
      }
    }
  }

  if (['-v', 'version', '--version'].includes(subCommand)) {
    return {
      message: [
        '',
        Utils.intro.success('is currently installed.')
      ].join('\n'),
      files: [],
      effects: []
    }
  }

  if (!subCommand || isHelpFlag(subCommand)) {
    return {
      message: [
        '',
        `🌈  Welcome to Elm Land! ${Terminal.dim(`(v${version})`)}`,
        Terminal.green('    ' + '⎺'.repeat(24 + version.length)),
        ...subcommandList,
        '',
        `    Want to learn more? Visit ${Terminal.cyan('https://elm.land/guide')}`,
        ''
      ].join('\n'),
      files: [],
      effects: []
    }
  }

  let handler = subcommandHandlers[subCommand]

  if (handler) {
    return handler(args)
  } else {
    return Promise.reject(
      Utils.didNotRecognizeCommand({
        baseCommand: 'elm-land',
        subCommand,
        subcommandList
      }) + [
        '',
        `    Want to learn more? Visit ${Terminal.cyan('https://elm.land/guide')}`,
        ''
      ].join('\n')
    )
  }
}

const isHelpFlag = (str) => {
  return ['-h', '--help'].includes(str)
}

export const Cli = { run }
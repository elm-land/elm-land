const { Init } = require('./commands/init')
const { Add } = require('./commands/add')
const { Server } = require('./commands/server')
const { Generate } = require('./commands/generate')
const { Build } = require('./commands/build')
const { Customize } = require('./commands/customize')
const { Routes } = require('./commands/routes')
const { Utils, Terminal } = require('./commands/_utils')

let { version } = require('../package.json')

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
  '',
  `    📊 elm-land ${Terminal.pink('graphql')} .............. work with a GraphQL API`
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
        return Add.run({ arguments: args })
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
    },
    'graphql': ([command, ...args] = []) => {
      try {
        const { GraphQL } = require('../../graphql/src/index.js')
        if (isHelpFlag(command)) {
          return GraphQL.printHelpInfo()
        } else {
          return GraphQL.run(command, ...args)
        }
      } catch (_) {
        console.error('TODO', 'Prompt user to install @elm-land/graphql plugin')
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

module.exports = {
  Cli: { run }
}
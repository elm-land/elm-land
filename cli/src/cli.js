const { Init } = require('./commands/init')
const { Add } = require('./commands/add')
const { Server } = require('./commands/server')
const { Build } = require('./commands/build')
const { Customize } = require('./commands/customize')
const { Utils } = require('./commands/_utils')

let { version } = require('../package.json')
let intro = `🌈 Welcome to Elm Land! (v${version})`

let subcommandList = [
  'Here are the commands:',
  '✨ elm-land init <folder-name> ...... create a new project',
  '🚀 elm-land server ................ run a local dev server',
  '📦 elm-land build .......... build your app for production',
  '📄 elm-land add page <url> ................ add a new page',
  '📑 elm-land add layout <name> ........... add a new layout',
  '🔧 elm-land customize <name> .. customize a default module',
  ''
]

let run = async (commandFromCli) => {
  // ( This function accepts a string or string[] )
  let command = typeof commandFromCli === 'string'
    ? commandFromCli.split(' ')
    : commandFromCli

  let [_npx, _elmLand, subCommand, ...args] = command

  let subcommandHandlers = {
    'init': ([folderName] = []) => {
      return Init.run({ name: folderName })
    },
    'server': (args) => {
      return Server.run({})
    },
    'build': (args) => {
      return Build.run({})
    },
    'customize': ([moduleName] = []) => {
      return Customize.run({ moduleName })
    },
    'add': (args) => {
      return Add.run({ arguments: args })
    },
    'generate': (args) => {
      return Add.testElmCodegen()
    }
  }

  if (!subCommand) {
    return {
      message: [
        intro,
        '',
        ...subcommandList,
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
        subCommand,
        subcommandList
      })
    )
  }
}

module.exports = {
  Cli: { run }
}
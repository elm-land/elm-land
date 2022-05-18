const { Init } = require('./commands/init')
const { Add } = require('./commands/add')
const { Server } = require('./commands/server')
const { Utils } = require('./commands/_utils')

let { version } = require('../package.json')
let intro = `🌈 Welcome to Elm Land! (v${version})`

let subcommandList = [
  'Here are the commands:',
  '✨ elm-land init <folder-name> ...... create a new project',
  '🚀 elm-land server ................ run a local dev server',
  '📄 elm-land add page <url> ................ add a new page',
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
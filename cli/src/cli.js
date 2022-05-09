const { Init } = require('./commands/init')
const { Server } = require('./commands/server')

let { version } = require('../package.json')
let intro = `🌈 Welcome to Elm Land! (v${version})`

let subcommandList = [
  'Here are the commands:',
  '✨ elm-spa init <folder-name> ...... create a new project',
  '🚀 elm-spa server ................ run a local dev server'
]

let run = (commandFromCli) => {
  // ( This function accepts a string or string[] )
  let command = typeof commandFromCli === 'string'
    ? commandFromCli.split(' ')
    : commandFromCli

  let [_npx, _elmLand, subCommand, ...args] = command

  let subcommandHandlers = {
    'init': (args) => {
      return Init.run({ name: args[0] })
    },
    'server': (args) => {
      return Server.run({})
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
    return {
      message: [
        intro,
        '',
        `❗️ We didn't recognize the "${subCommand}" command`,
        '',
        ...subcommandList,
      ].join('\n'),
      files: [],
      effects: []
    }
  }
}

module.exports = {
  Cli: { run }
}
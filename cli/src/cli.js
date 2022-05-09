const { Init } = require('./commands/init')

let { version } = require('../package.json')
let intro = `🌈 Welcome to Elm Land! (v${version})`

let subcommandList = [
  'Here are the commands:',
  '✨ elm-spa init <folder-name> ...... create a new project'
]

let run = ([_npx, _elmLand, subCommand, ...args]) => {
  let subcommandHandlers = {
    'init': (args) => {
      return Init.run({ name: args[0] })
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
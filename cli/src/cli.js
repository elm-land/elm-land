const { Init } = require('./commands/init')

let run = (command) => {
  let [_npx, _elmLand, subCommand, ...args] = command.split(' ')

  let subcommandHandlers = {
    'init': (args) => {
      return Init.run({ name: args[0] })
    }
  }

  let handler = subcommandHandlers[subCommand]

  if (handler) {
    return handler(args)
  } else {
    return `🌈 Welcome to Elm Land!`
  }
}

module.exports = {
  Cli: { run }
}
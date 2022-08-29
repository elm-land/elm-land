const { Init } = require('./commands/init')
const { Add } = require('./commands/add')
const { Server } = require('./commands/server')
const { Build } = require('./commands/build')
const { Customize } = require('./commands/customize')
const { Utils, Terminal } = require('./commands/_utils')

let { version } = require('../package.json')

let subcommandList = [
  `    Here are the available commands:`,
  ``,
  `    ✨ elm-land ${Terminal.pink('init <folder-name>')} ...... create a new project`,
  `    🚀 elm-land ${Terminal.pink('server')} ................ run a local dev server`,
  `    📦 elm-land ${Terminal.pink('build')} .......... build your app for production`,
  `    📄 elm-land ${Terminal.pink('add page <url>')} ................ add a new page`,
  `    📑 elm-land ${Terminal.pink('add layout <name>')} ........... add a new layout`,
  `    🔧 elm-land ${Terminal.pink('customize <name>')} .. customize a default module`
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
    'new': ([folderName] = []) => {
      return Init.run({ name: folderName })
    },
    'create': ([folderName] = []) => {
      return Init.run({ name: folderName })
    },
    'add': (args) => {
      return Add.run({ arguments: args })
    },
    'server': (args) => {
      return Server.run({})
    },
    'build': (args) => {
      return Build.run({})
    },
    'customize': ([moduleName] = []) => {
      return Customize.run({ moduleName })
    }
  }

  if (['-v', '--version'].includes(subCommand)) {
    return {
      message: [
        '',
        Utils.intro.success('is currently installed.')
      ].join('\n'),
      files: [],
      effects: []
    }
  }

  if (!subCommand || ['-h', '-v', '--help', '--version'].includes(subCommand)) {
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

module.exports = {
  Cli: { run }
}
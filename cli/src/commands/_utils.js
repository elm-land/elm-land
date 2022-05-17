let { version } = require('../../package.json')
let intro = `🌈 Welcome to Elm Land! (v${version})`

let didNotRecognizeCommand = ({subCommand, subcommandList}) => [
  intro,
  '',
  `❗️ We didn't recognize the "${subCommand}" command`,
  '',
  ...subcommandList,
].join('\n')

module.exports = {
  Utils: { didNotRecognizeCommand }
}
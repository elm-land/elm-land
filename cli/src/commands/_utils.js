let { version } = require('../../package.json')
let intro = `🌈 Welcome to Elm Land! (v${version})`

let didNotRecognizeCommand = ({ subCommand, subcommandList }) => [
  intro,
  '',
  subCommand === undefined
    ? '❗️ Missing a required argument'
    : `❗️ We didn't recognize the "${subCommand}" command`,
  '',
  ...subcommandList,
].join('\n')

let notInElmLandProject = [
  `🌈 Elm Land couldn't find a "elm-land.json" file in the current folder...`,
  '',
  `If you'd like to create a new project, use this command:`,
  `✨ npx elm-land init my-project`,
].join('\n')

module.exports = {
  Utils: { didNotRecognizeCommand, notInElmLandProject }
}
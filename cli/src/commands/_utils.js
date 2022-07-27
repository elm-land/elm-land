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

let customizableFiles = {
  'shared': 'Shared.elm',
  'not-found': 'Pages/NotFound_.elm',
  'view': 'View.elm',
  'effect': 'Effect.elm',
}

module.exports = {
  Utils: {
    didNotRecognizeCommand,
    notInElmLandProject,
    customizableFiles
  }
}


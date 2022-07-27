const { Files } = require("../files")
const { Utils } = require("./_utils")

let run = async ({ moduleName } = {}) => {

  try {
    await Files.readFromUserFolder('elm-land.json')
  } catch (_) {
    return Promise.reject(Utils.notInElmLandProject)
  }

  let customizableFiles = {
    'shared': 'Shared.elm',
    'not-found': 'Pages/NotFound_.elm',
    'view': 'View.elm',
    'effect': 'Effect.elm',
  }
  let filepath = customizableFiles[moduleName]

  if (!filepath) {
    return Promise.reject(Utils.didNotRecognizeCommand({
      subCommand:
        (moduleName)
          ? `elm-land customize ${moduleName}`
          : undefined,
      subcommandList: [
        'Here are the available options:',
        ...Object.keys(customizableFiles)
          .map(key => `• elm-land customize ${key}`)
      ]
    }))
  }

  return {
    message: `🌈 File is now customizable at ./src/${filepath}`,
    files: [],
    effects: [
      { kind: 'customize', filepath },
    ]
  }
}

module.exports = {
  Customize: {
    run
  }
}
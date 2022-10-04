const { Files } = require("../files")
const { Utils, Terminal } = require("./_utils")

let run = async ({ moduleName } = {}) => {

  try {
    await Files.readFromUserFolder('elm-land.json')
  } catch (_) {
    return Promise.reject(Utils.notInElmLandProject)
  }

  let obj = Utils.customizableFiles[moduleName]


  if (!obj) {
    return Promise.reject(Utils.didNotRecognizeCommand({
      baseCommand: 'elm-land customize',
      subCommand: moduleName,
      subcommandList: [
        '   Here are the commands:',
        '',
        ...(
          Object.entries(Utils.customizableFiles)
            .map(([command, { description }]) =>
              `   elm-land customize ${Terminal.pink(command)} ${description}`
            )
        )
      ]
    }))
  }

  return {
    message: [
      '',
      Utils.intro.success(`created a file at ${Terminal.cyan(`./src/${obj.filepath}`)}`),
      '    Deleting that file will restore the default module.',
      '',
    ].join('\n'),
    files: [],
    effects: [
      { kind: 'customize', filepath: obj.filepath },
    ]
  }
}

module.exports = {
  Customize: {
    run
  }
}
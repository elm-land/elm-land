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

  let count = obj.filepaths.length
  let countWithUnits = count === 1 ? `${count} new file` : `${count} new files`

  let pathsToNewFiles = obj.filepaths.map(filepath => Terminal.cyan(`    ./src/${filepath}`))

  let helpMessage = count === 1
    ? `    If this was a mistake, you can delete that file\n    to safely restore the original version.`
    : `    If this was a mistake, delete any of those files\n    to safely restore the original versions.`

  return {
    message: [
      '',
      Utils.intro.success(`moved ${Terminal.pink(countWithUnits)} into your ${Terminal.cyan('src')} folder`),
      ...pathsToNewFiles,
      '',
      helpMessage,
      '',
    ].join('\n'),
    files: [],
    effects: [
      { kind: 'customize', filepaths: obj.filepaths },
    ]
  }
}

module.exports = {
  Customize: {
    run
  }
}
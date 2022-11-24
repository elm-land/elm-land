const { Files } = require("../files")
const { Utils, Terminal } = require("./_utils")

let run = async () => {

  let rawTextConfig = undefined
  try {
    rawTextConfig = await Files.readFromUserFolder('elm-land.json')
  } catch (_) {
    return Promise.reject(Utils.notInElmLandProject)
  }

  let config = {}
  try {
    config = JSON.parse(rawTextConfig)
  } catch (err) {
    // TODO: Warn user about invalid config JSON
  }

  return {
    message: [
      '',
      Utils.intro.success(`successfully built your project at ${Terminal.cyan('./dist')}`),
    ].join('\n'),
    files: [],
    effects: [
      { kind: 'generateHtml', config },
      { kind: 'build', config }
    ]
  }
}

module.exports = {
  Build: {
    run
  }
}
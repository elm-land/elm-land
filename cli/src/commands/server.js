const { Files } = require("../files")
const { Utils } = require("./_utils")

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
    message: '🌈 Server ready at http://localhost:1234',
    files: [],
    effects: [
      { kind: 'generateHtml', config },
      { kind: 'runServer', options: { port: 1234 } }
    ]
  }
}

module.exports = {
  Server: {
    run
  }
}
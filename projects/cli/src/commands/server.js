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

  let port = process.env.PORT || 1234
  let host = process.env.HOST || '0.0.0.0'

  let formattedHost = host === '0.0.0.0' ? 'localhost' : host

  return {
    message: ({ port }) => [
      '',
      Utils.intro.success(`is ready at http://${formattedHost}:${port}`)
    ].join('\n'),
    files: [],
    effects: [
      { kind: 'generateHtml', config },
      { kind: 'runServer', options: { host, port } }
    ]
  }
}

module.exports = {
  Server: {
    run
  }
}
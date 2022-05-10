const { Files } = require("../files")

let run = async () => {
  let rawTextConfig = await Files.readFromUserFolder('elm-land.json')

  if (!rawTextConfig) {
    return {
      message: [
        `🌈  Elm Land couldn't find a "elm-land.json" file in the current folder...`,
        '',
        `If you'd like to create a new project, use this command:`,
        `✨ npx elm-spa init`,
      ].join('\n'),
      files: [],
      effects: []
    }
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
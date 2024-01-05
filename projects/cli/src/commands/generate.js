import { Files } from "../files.js"
import { Utils, Terminal } from "./_utils.js"

let printHelpInfo = () => {
  return {
    message: [
      '',
      Utils.intro.success(`detected the ${Terminal.green('help')} command`),
      `    When you are ready to ship your app to production, the`,
      `    ${Terminal.cyan('elm-land generate')} command will generate some Elm code`,
      `    for your project in the ${Terminal.pink('./elm-land/src')} folder`,
      '',
      `    From there, you can decide how to compile it to JS, and deploy the`,
      `    app however you like. This is like elm-land build, but without the extra steps.`,
      '',
    ].join('\n'),
    files: [],
    effects: []
  }
}

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
      Utils.intro.success(`generated files successfully.`),
    ].join('\n'),
    files: [],
    effects: [
      { kind: 'generate', config }
    ]
  }
}

export const Generate = {
  run,
  printHelpInfo
}
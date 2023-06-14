const { Files } = require("../files")
const { Utils, Terminal } = require("./_utils")

let printHelpInfo = () => {
  return {
    message: [
      '',
      Utils.intro.success(`detected the ${Terminal.green('help')} command`),
      `    When you are ready to ship your app to production, the`,
      `    ${Terminal.cyan('elm-land build')} command will compile your app, minify the JS,`,
      `    and output the resulting code in the ${Terminal.pink('./dist')} folder`,
      '',
      `    Check out ${Terminal.cyan('https://elm.land/guide/deploying')} to learn how to`,
      `    host your new application for ${Terminal.green('free')} with Netlify or Vercel`,
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
      Utils.intro.success(`build was successful.`),
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
    run, printHelpInfo
  }
}

import { Files } from "../files.js"
import { Utils, Terminal } from "./_utils.js"
import { projectElmVersionProblem } from "../elm-version.js"
import { hostFromEnv, displayHost, isNetworkExposed } from "../dev-server-options.js"

let printHelpInfo = () => {
  return {
    message: [
      '',
      Utils.intro.success(`detected the ${Terminal.green('help')} command`),
      `    Elm Land comes with a built-in development server powered`,
      `    by ${Terminal.cyan('Vite')}. ⚡️`,
      '',
      `    By design, the dev server doesn't have many configuration `,
      `    options, but you can provide the ${Terminal.pink('HOST')} or ${Terminal.pink('PORT')} environment`,
      `    variables for more advanced use cases.`,
      '',
      `    The server only accepts connections from this machine. To let`,
      `    other devices on your network reach it, run it with ${Terminal.pink('HOST=0.0.0.0')}`,
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

  let elmVersionProblem = projectElmVersionProblem({ intro: Utils.intro, colors: Terminal })
  if (elmVersionProblem) {
    return Promise.reject(elmVersionProblem)
  }

  let port = process.env.PORT || 1234
  let host = hostFromEnv(process.env)

  return {
    message: ({ port }) => [
      '',
      Utils.intro.success(`is ready at http://${displayHost(host)}:${port}`),
      ...(isNetworkExposed(host)
        ? [`    ${Terminal.dim(`Listening on ${host}: other machines on your network can reach this server.`)}`]
        : [])
    ].join('\n'),
    files: [],
    effects: [
      { kind: 'generateHtml', config },
      { kind: 'runServer', options: { host, port } }
    ]
  }
}

export const Server = {
  run, printHelpInfo
}
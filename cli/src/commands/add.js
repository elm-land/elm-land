const { Files } = require("../files")
const { Utils } = require("./_utils")
const path = require('path')

let addNewPage = async ([ url ]) => {
  if (!url) {
    return {
      message: [
        `🌈 This command is missing a URL...`,
        '',
        'Here are some examples:',
        '1️⃣  elm-land add page /sign-in',
        '2️⃣  elm-land add page /users/:id'
      ].join('\n'),
      files: [],
      effects: []
    }
  }

  let relativeFilepath = `src/Pages/${toNewPageFilename({ url })}`

  return {
    message: [
      `🌈 New page added at ${url}`,
      '',
      'You can edit your new page here:',
      `👉 ./${relativeFilepath}`
    ].join('\n'),
    files: [
      { 
        kind: 'file', 
        name: relativeFilepath,
        content: toNewPageContentString({ url })
      }
    ],
    effects: []
  }
}

let toPascalCaseFromKebabCase = (str) => {
  return str.split('-')
    .map(str => str.length > 0 ? str[0].toUpperCase() + str.slice(1) : str)
    .join('')
}

let toNewPageModuleNamePiece = (str) => {
  if (str.startsWith(':')) {
    return toPascalCaseFromKebabCase(str.slice(1)) + '_'
  } else {
    return toPascalCaseFromKebabCase(str)
  }
}

let toNewPageModuleNamePieces = ({ url }) => {
  return url
    .split('/')
    .filter(a => a)
    .map(toNewPageModuleNamePiece)
}

let toNewPageFilename = ({ url }) =>
  `${toNewPageModuleNamePieces({ url }).join('/')}.elm`

let toNewPageContentString = ({ url }) => `
module Pages.${toNewPageModuleNamePieces({ url }).join('.')} exposing (page)

import Html exposing (Html)


page : Html msg
page =
    Html.text "${url}"
`.trimStart()

let run = async ({ arguments }) => {
  let [ subCommand, ...otherArgs ] = arguments
  let subCommandHandlers = {
    'page': addNewPage
  }

  let handler = subCommandHandlers[subCommand]

  if (handler) {
    return handler(otherArgs)
  } else {
    return {
      message: Utils.didNotRecognizeCommand({
        subCommand,
        subcommandList: [
          '📄 elm-land add page <url> ...... create a new page'
        ]
      }),
      files: [],
      effects: []
    }
  }
}


let testElmCodegen = async () => {
  let worker = undefined
  try {
    // Import worker, silence Elm warning while testing
    let originalWarnFn = console.warn
    console.warn = () => {}
    worker = require('../../dist/elm/add-page-worker')
    console.warn = originalWarnFn
  } catch (_) {}

  if (!worker) {
    return {
      message: '❗ Could not find Elm worker file...',
      files: [],
      effects: []
    }
  }

  let output = await new Promise((resolve, reject) => {
    let pagesFolder = path.join(process.cwd(), 'src', 'Pages')
    let app = worker.Elm.AddPageWorker.init({
      flags: { pageFilepaths: Files.listElmFilepathsInFolder(pagesFolder) }
    })

    if (app.ports.onSuccess) {
      app.ports.onSuccess.subscribe(resolve)
    }
    if (app.ports.onFailure) {
      app.ports.onFailure.subscribe(reject)
    }
  })


  return {
    message: '🧪 Testing codegen... \n\n' + JSON.stringify(output, null, 2),
    files: [],
    effects: []
  }
}

module.exports = {
  Add: {
    run,
    testElmCodegen
  }
}
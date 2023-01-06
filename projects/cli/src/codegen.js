const path = require('path')
const { Files } = require('./files')

let generateElmLandFiles = async ({ pages, layouts, router }) => {
  let { Elm } = require('../dist/codegen-worker.js')

  let newFiles = await new Promise((resolve, reject) => {
    // Insert not found page if it hasn't been customized yet
    if (isMissingNotFoundPage(pages)) {
      pages = pages.concat([hardcodedNotFoundPage])
    }

    let app = Elm.Worker.init({
      flags: {
        tag: 'generate',
        data: { pages, layouts, router }
      }
    })
    app.ports.onComplete.subscribe(resolve)
  })

  return newFiles
}

let addNewPage = async ({ kind, url, filepath }) => {
  let { Elm } = require('../dist/codegen-worker.js')

  let hasViewBeenCustomized = await Files.exists(path.join(process.cwd(), 'src', 'View.elm'))

  let newFiles = await new Promise((resolve, reject) => {
    let app = Elm.Worker.init({
      flags: {
        tag: 'add-page',
        data: {
          hasViewBeenCustomized,
          kind,
          page: { filepath, contents: '' },
          url
        }
      }
    })
    app.ports.onComplete.subscribe(resolve)
  })

  return newFiles
}

let addNewLayout = async ({ moduleSegments }) => {
  let { Elm } = require('../dist/codegen-worker.js')

  let newFiles = await new Promise((resolve, reject) => {
    let app = Elm.Worker.init({
      flags: {
        tag: 'add-layout',
        data: { moduleSegments }
      }
    })
    app.ports.onComplete.subscribe(resolve)
  })

  return newFiles
}

module.exports = {
  Codegen: {
    generateElmLandFiles,
    addNewPage,
    addNewLayout
  }
}

// Not found page

const isMissingNotFoundPage = (pages = []) => {
  let hasNotFoundPage = pages.some(page => page.filepath && page.filepath.length === 1 && page.filepath[0] === 'NotFound_')
  return !hasNotFoundPage
}


const hardcodedNotFoundPage = {
  filepath: ['NotFound_'],
  contents: `module Pages.NotFound_ exposing (page)

import View exposing (View)


page : View msg
page =
    View.fromString "Page not found."
`
}
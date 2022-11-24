const path = require('path')
const { Files } = require('./files')

let generateElmLandFiles = async ({ pages, layouts, options }) => {
  let { Elm } = require('../dist/worker.js')

  let newFiles = await new Promise((resolve, reject) => {
    let app = Elm.Worker.init({
      flags: {
        tag: 'generate',
        data: { pages, layouts, options }
      }
    })
    app.ports.onComplete.subscribe(resolve)
  })

  return newFiles
}

let addNewPage = async ({ kind, url, filepath }) => {
  let { Elm } = require('../dist/worker.js')

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
  let { Elm } = require('../dist/worker.js')

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
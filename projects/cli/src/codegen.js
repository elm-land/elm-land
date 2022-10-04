const path = require('path')
const { Files } = require('./files')

let generateElmLandFiles = async ({ pages, layouts }) => {
  let { Elm } = require('../dist/worker.js')

  let newFiles = await new Promise((resolve, reject) => {
    let app = Elm.Worker.init({
      flags: {
        tag: 'generate',
        data: { pages, layouts }
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
          filepath,
          url
        }
      }
    })
    app.ports.onComplete.subscribe(resolve)
  })

  return newFiles
}

let addNewLayout = async ({ kind, name }) => {
  let { Elm } = require('../dist/worker.js')

  let newFiles = await new Promise((resolve, reject) => {
    let app = Elm.Worker.init({
      flags: {
        tag: 'add-layout',
        data: { kind, name }
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
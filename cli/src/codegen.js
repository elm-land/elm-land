let generateElmLandFiles = async ({ filepaths }) => {
  let { Elm } = require('../dist/worker.js')

  let newFiles = await new Promise((resolve, reject) => {
    let app = Elm.Worker.init({
      flags: {
        tag: 'generate',
        data: { filepaths }
      }
    })
    app.ports.onComplete.subscribe(resolve)
  })

  return newFiles
}

let addNewPage = async ({ url, filepath }) => {
  let { Elm } = require('../dist/worker.js')

  let newFiles = await new Promise((resolve, reject) => {
    let app = Elm.Worker.init({
      flags: {
        tag: 'add-page',
        data: { filepath, url }
      }
    })
    app.ports.onComplete.subscribe(resolve)
  })

  return newFiles
}

module.exports = {
  Codegen: {
    generateElmLandFiles,
    addNewPage
  }
}
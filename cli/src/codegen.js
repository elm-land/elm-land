let generateElmLandFiles = async ({ pageRoutePaths }) => {
  let { Elm } = require('../dist/worker.js')

  let newFiles = await new Promise((resolve, reject) => {
    let app = Elm.Worker.init({
      flags: {
        tag: 'generate-elm-land-files',
        data: {
          pageRoutePaths
        }
      }
    })
    app.ports.onSuccessSend.subscribe(resolve)
    app.ports.onFailureSend.subscribe(reject)
  })

  return newFiles
}

let addNewPage = async ({ url, routePath }) => {
  let { Elm } = require('../dist/worker.js')

  let newFiles = await new Promise((resolve, reject) => {
    let app = Elm.Worker.init({
      flags: {
        tag: 'add-page',
        data: { routePath, url }
      }
    })
    app.ports.onSuccessSend.subscribe(resolve)
    app.ports.onFailureSend.subscribe(reject)
  })

  return newFiles
}

module.exports = {
  Codegen: {
    generateElmLandFiles,
    addNewPage
  }
}
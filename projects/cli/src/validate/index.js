const path = require('path')
const { toColoredTerminalOutput } = require('../vite-plugins/elm/elm-error-json.js')

let validate = async ({ pages, layouts }) => {
  let { Elm } = require('../../dist/validate-worker.js')

  let elmLandErrors = await new Promise((resolve, reject) => {
    let app = Elm.Worker.init({
      flags: { pages, layouts }
    })
    app.ports.onComplete.subscribe(errors => {
      errors.forEach(error => {
        error.path = path.join(process.cwd(), error.path)
      })
      resolve(errors)
    })
  })

  return elmLandErrors
}

module.exports = {
  validate
}
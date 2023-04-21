const path = require('path')

let validate = async (flags) => {
  let { Elm } = require('../../dist/validate-worker.js')

  let elmLandErrors = await new Promise((resolve) => {
    let app = Elm.Worker.init({ flags })
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
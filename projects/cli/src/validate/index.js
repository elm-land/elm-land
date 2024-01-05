import path from 'path'
import { createRequire } from 'module';
const require = createRequire(import.meta.url)

export let validate = async (flags) => {
  let { Elm } = require('../../dist/validate-worker.cjs')

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

import { join } from 'path'

export const validate = async (flags) => {
  let result = await import('../../dist/validate-worker.cjs')
  let Elm = result.default.Elm

  let elmLandErrors = await new Promise((resolve) => {
    let app = Elm.Worker.init({ flags })
    app.ports.onComplete.subscribe(errors => {
      errors.forEach(error => {
        error.path = join(process.cwd(), error.path)
      })
      resolve(errors)
    })
  })

  return elmLandErrors
}

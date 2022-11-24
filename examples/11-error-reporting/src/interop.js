import * as ErrorReporting from './interop/error-reporting.js'

// Called before your Elm application starts up
// The return value is passed as JSON to `Shared.init`
export const flags = ({ env }) => {
  ErrorReporting.init({ env })
}

// Called after your Elm application starts up
export const onReady = ({ app, env }) => {
  ErrorReporting.handlePorts(app.ports)
}
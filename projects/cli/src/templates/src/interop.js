// These are the flags passed into your Elm application
export const flags = ({ env }) => {
  return {}
}

// This function is called once your Elm app is running
export const onReady = ({ app, env }) => {
  console.log(`Elm app is ready!`, { app, env })
}
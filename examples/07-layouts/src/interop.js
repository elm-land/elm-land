export const flags = ({ env }) => {
  let username = localStorage.getItem('username')

  return {
    username
  }
}

export const onReady = ({ app, env }) => {
  if (app.ports && app.ports.onSaveUser) {
    app.ports.onSaveUser.subscribe(({ username }) => {
      localStorage.setItem('username', username)
    })
  }
}
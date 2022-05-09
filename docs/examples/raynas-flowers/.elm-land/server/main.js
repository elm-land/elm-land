import { Elm } from '../src/Main.elm'

let startApp = ({ Interop }) => {
  // Only keep variables starting with VITE_ prefix
  let env = {}
  for (let variable in import.meta.env) {
    if (variable.startsWith('VITE_')) {
      env[variable.slice('VITE_'.length)] = import.meta.env[variable]
    }
  }

  let flags = Interop.flags
    ? Interop.flags({ env })
    : undefined

  let app = Elm.Main.init({
    node: document.getElementById('app'),
    flags
  })

  if (Interop.onReady) {
    Interop.onReady({ app, env })
  }
}

// If user has an interop file, use it!
try {
  let Interop = import.meta.globEager('../../src/interop.js')['../../src/interop.js'] || {}
  startApp({ Interop })
} catch (_) {
  startApp({ Interop: {} })
}
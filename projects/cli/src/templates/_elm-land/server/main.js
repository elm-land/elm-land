import Main from '../src/Main.elm'

let startApp = async ({ Interop }) => {
  // Grab environment variables, but remove the "ELM_LAND_" prefix
  let env = Object.keys(import.meta.env).reduce((env, key) => {
    if (key.startsWith('ELM_LAND_')) {
      env[key.slice('ELM_LAND_'.length)] = import.meta.env[key]
    }
    return env
  }, {})

  let flags = undefined

  if (Interop.flags) {
    flags = await Interop.flags({ env })
  }

  if (Main && Main.init) {
    let app = Main.init({
      node: document.getElementById('app'),
      flags
    })

    if (Interop.onReady) {
      Interop.onReady({ app, env })
    }
  }

}


const main = async () => {
  try {
    // Attempt to find "interop.ts" file
    let interopFiles = import.meta.glob('../../src/interop.ts', { eager: true })
    await startApp({ Interop: interopFiles['../../src/interop.ts'] })
  } catch (_) {
    try {
      // Attempt to find "interop.js" file
      let interopFiles = import.meta.glob('../../src/interop.js', { eager: true })
      await startApp({ Interop: interopFiles['../../src/interop.js'] })
    } catch (_) {
      // Run application without an interop file
      await startApp({ Interop: {} })
    }
  }
}

main()
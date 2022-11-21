import { Elm } from '../src/Main.elm'

// client side
if (import.meta.hot) {
  class ElmErrorOverlay extends HTMLElement {
    constructor() {
      super()
      this.attachShadow({ mode: 'open' })
    }

    onContentChanged(html) {
      this.shadowRoot.querySelector('.elm-error').innerHTML = html
    }

    connectedCallback() {
      this.shadowRoot.innerHTML = `
        <style>
          .elm-error__background {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            opacity: 0.5;
            background: black;
          }

          .elm-error {
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(calc(-50% + 0.5px), calc(-50% + 0.5px));
            background: linear-gradient(#333, #303030);
            color: white;
            font-weight: 400;
            font-family: Consolas, "Andale Mono WT", "Andale Mono", "Lucida Console", "Lucida Sans Typewriter", "DejaVu Sans Mono", "Bitstream Vera Sans Mono", "Liberation Mono", "Nimbus Mono L", Monaco, "Courier New", Courier, monospace;
            padding: 2rem;
            border-radius: 0.25rem;
            box-shadow: 0 1rem 1rem rgba(0, 0, 0, 0.125);
            border-top: solid 0.5rem indianred;
            max-height: calc(100vh - 8rem);
            overflow: auto;
            max-width: 100vw;
            box-sizing: border-box;
          }
        </style>
        <div class="elm-error__background"></div>
        <div class="elm-error"></div>
      `
    }
  }

  import.meta.hot.on('elm:error', (data) => {

    if (!customElements.get('elm-error-overlay')) {
      customElements.define('elm-error-overlay', ElmErrorOverlay)
    }

    let existingOverlay = document.querySelector('elm-error-overlay')

    if (existingOverlay) {
      existingOverlay.onContentChanged(data.error)
    } else {
      document.body.innerHTML += '<elm-error-overlay></elm-error-overlay>'
      document.querySelector('elm-error-overlay').onContentChanged(data.error)
    }

  })

  import.meta.hot.on('elm:success', () => {
    let existingOverlay = document.querySelector('elm-error-overlay')
    if (existingOverlay) {
      existingOverlay.remove()
    }
  })

}

let startApp = ({ Interop }) => {
  // Grab environment variables, but remove the "ELM_LAND_" prefix
  let env = Object.keys(import.meta.env).reduce((env, key) => {
    if (key.startsWith('ELM_LAND_')) {
      env[key.slice('ELM_LAND_'.length)] = import.meta.env[key]
    }
    return env
  }, {})

  let flags = undefined

  if (Interop.flags) {
    flags = Interop.flags({ env })
  }

  if (Elm && Elm.Main && Elm.Main.init) {
    let app = Elm.Main.init({
      node: document.getElementById('app'),
      flags
    })

    if (Interop.onReady) {
      Interop.onReady({ app, env })
    }
  }

  if (import.meta.env.DEV) {
    import.meta.hot.send('elm:client-ready')
  }

}

try {
  // Attempt to find "interop.ts" file
  let interopFiles = import.meta.glob('../../src/interop.ts', { eager: true })
  startApp({ Interop: interopFiles['../../src/interop.ts'] })
} catch (_) {
  try {
    // Attempt to find "interop.js" file
    let interopFiles = import.meta.glob('../../src/interop.js', { eager: true })
    startApp({ Interop: interopFiles['../../src/interop.js'] })
  } catch (_) {
    // Run application without an interop file
    startApp({ Interop: {} })
  }
}
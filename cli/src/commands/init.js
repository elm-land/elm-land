const { Docs } = require("../docs")

let run = async (options = {}) => {
  let { name } = options

  if (name) {

    let message = [
      `🌈 New project created in "./${name}"`,
      '',
      '📄  elm.json',
      '📂  src/'
    ].join('\n')

    return {
      message,
      files: [
        {
          kind: 'file',
          name: `${name}/elm.json`,
          content: await Docs.read('examples/02-elm-land-app/elm.json')
        },
        { kind: 'folder', name: `${name}/src` },
      ]
    }
  } else {
    return {
      message: '⚰️ TODO',
      files: []
    }
  }
}

module.exports = {
  Init: { run }
}
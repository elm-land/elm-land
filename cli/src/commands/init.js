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
      ],
      effects: [
        { kind: 'changeFolder', folder: name }
      ]
    }
  } else {
    return {
      message: [
        `🌈 Please provide a folder name for your new project.`,
        '',
        `💁 Here\'s an example:`,
        '',
        'npx elm-land init my-project'
      ].join('\n'),
      files: [],
      effects: []
    }
  }
}

module.exports = {
  Init: { run }
}
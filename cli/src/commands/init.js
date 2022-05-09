const { Docs } = require("../docs")

let run = async (options = {}) => {
  let { name } = options

  if (name) {
    let message = [
      `🌈 New project created in ./${name}`,
      '',
      'Here are some next steps:',
      `📂 cd ${name}`,
      '🚀 npx elm-land server'
    ].join('\n')

    return {
      message,
      files: [
        {
          kind: 'file',
          name: `${name}/elm.json`,
          content: await Docs.read('examples/01-hello-world/elm.json')
        },
        {
          kind: 'file',
          name: `${name}/.gitignore`,
          content: await Docs.read('examples/01-hello-world/.gitignore')
        },
        {
          kind: 'file',
          name: `${name}/src/Pages/Home_.elm`,
          content: await Docs.read('examples/01-hello-world/src/Pages/Home_.elm')
        },
        {
          kind: 'file',
          name: `${name}/.elm-land/src/Main.elm`,
          content: await Docs.read('../cli/src/commands/.elm-land/src/Main.elm')
        }
      ],
      effects: []
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
const path = require('path')
const { Files } = require("../files")

let run = async (options = {}) => {
  let { name } = options

  if (name) {

    let isNonEmptyFolder = await Files.isNonEmptyFolder(path.join(process.cwd(), name))

    if (isNonEmptyFolder) {
      return Promise.reject([
        `🌈 It looks like ./${name} is a non-empty folder`,
        '',
        'I don\'t want to delete anything important, so',
        'please run this command when that folder is empty.',
      ].join('\n'))
    }

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
          content: await Files.readFromCliFolder('src/templates/elm.json')
        },
        {
          kind: 'file',
          name: `${name}/elm-land.json`,
          content: await Files.readFromCliFolder('src/templates/elm-land.json')
        },
        {
          kind: 'file',
          name: `${name}/.gitignore`,
          content: await Files.readFromCliFolder('src/templates/_gitignore')
        },
        {
          kind: 'file',
          name: `${name}/src/Pages/Home_.elm`,
          content: await Files.readFromCliFolder('src/templates/src/Pages/Home_.elm')
        },
        {
          kind: 'file',
          name: `${name}/.elm-land/src/Main.elm`,
          content: await Files.readFromCliFolder('src/templates/_elm-land/src/Main.elm')
        },
        {
          kind: 'file',
          name: `${name}/.elm-land/src/View.elm`,
          content: await Files.readFromCliFolder('src/templates/_elm-land/src/View.elm')
        },
        {
          kind: 'file',
          name: `${name}/.elm-land/src/ElmLand/Page.elm`,
          content: await Files.readFromCliFolder('src/templates/_elm-land/src/ElmLand/Page.elm')
        }
      ],
      effects: []
    }
  } else {
    return Promise.reject([
      `🌈 Please provide a folder name for your new project.`,
      '',
      `💁 Here\'s an example:`,
      '',
      'npx elm-land init my-project'
    ].join('\n'))
  }
}

module.exports = {
  Init: { run }
}
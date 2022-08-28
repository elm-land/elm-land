const path = require('path')
const { Files } = require("../files")
const { Utils, Terminal } = require('./_utils')

let run = async (options = {}) => {
  let { name } = options

  if (name) {

    let isNonEmptyFolder = await Files.isNonEmptyFolder(path.join(process.cwd(), name))

    if (isNonEmptyFolder) {
      return Promise.reject([
        '',
        Utils.intro.error(`detected a ${Terminal.cyan('non-empty folder')}`),
        `    I don't want to delete anything important in ${Terminal.cyan(`./${name}`)}`,
        '    so no changes have been made.',
        '',
        '    Please try again with an empty folder.',
        ''
      ].join('\n'))
    }

    let message = [
      '',
      Utils.intro.success(`created a new project in ${Terminal.cyan(`./${name}`)}`),
      '    Here are some next steps:',
      '',
      `    📂 cd ${name}`,
      '    🚀 elm-land server',
      ''
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
          name: `${name}/.elm-land/src/Pages/NotFound_.elm`,
          content: await Files.readFromCliFolder('src/templates/_elm-land/customizable/Pages/NotFound_.elm')
        },
        {
          kind: 'file',
          name: `${name}/.elm-land/src/Main.elm`,
          content: await Files.readFromCliFolder('src/templates/_elm-land/src/Main.elm')
        },
        {
          kind: 'file',
          name: `${name}/.elm-land/src/View.elm`,
          content: await Files.readFromCliFolder('src/templates/_elm-land/customizable/View.elm')
        },
        {
          kind: 'file',
          name: `${name}/.elm-land/src/Effect.elm`,
          content: await Files.readFromCliFolder('src/templates/_elm-land/customizable/Effect.elm')
        },
        {
          kind: 'file',
          name: `${name}/.elm-land/src/Shared.elm`,
          content: await Files.readFromCliFolder('src/templates/_elm-land/customizable/Shared.elm')
        },
        {
          kind: 'file',
          name: `${name}/.elm-land/src/Auth.elm`,
          content: await Files.readFromCliFolder('src/templates/_elm-land/customizable/Auth.elm')
        },
        {
          kind: 'file',
          name: `${name}/.elm-land/src/Page.elm`,
          content: await Files.readFromCliFolder('src/templates/_elm-land/src/Page.elm')
        },
        {
          kind: 'file',
          name: `${name}/.elm-land/src/Route.elm`,
          content: await Files.readFromCliFolder('src/templates/_elm-land/src/Route.elm')
        },
        {
          kind: 'file',
          name: `${name}/.elm-land/src/Route/Query.elm`,
          content: await Files.readFromCliFolder('src/templates/_elm-land/src/Route/Query.elm')
        }
      ],
      effects: []
    }
  } else {
    return Promise.reject([
      '',
      Utils.intro.error(`expected ${Terminal.red('a folder name')} for your project`),
      `    For example, if your project was called "${Terminal.cyan('my-cool-app')}"`,
      `    you'd run this command to get started:`,
      '',
      `    elm-land ${Terminal.pink('init my-cool-app')}`,
      '',
    ].join('\n'))
  }
}

module.exports = {
  Init: { run }
}
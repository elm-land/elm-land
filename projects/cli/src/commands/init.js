import path from 'path'
import { Files } from "../files.js"
import { Utils, Terminal } from './_utils.js'

let helpMessage = [
  `    For example, if your project was called "${Terminal.cyan('my-cool-app')}"`,
  `    you'd run this command to get started:`,
  '',
  `    elm-land ${Terminal.pink('init my-cool-app')}`,
  '',
].join('\n')

let printHelpInfo = () => {
  return {
    message: [
      '',
      Utils.intro.success(`detected the ${Terminal.green('help')} command`),
      `    The ${Terminal.cyan('elm-land init')} command needs a folder name to`,
      `    create a new Elm Land project.`,
      '',
      helpMessage
    ].join('\n'),
    files: [],
    effects: []
  }
}

let run = async (options = {}) => {
  let { name } = options

  if (name) {
    if (name.includes(' ')) {
      const modifiedFolderName = name.split(' ').filter(a => a).join('-').toLowerCase()
      return Promise.reject([
        '',
        Utils.intro.error(`detected a ${Terminal.cyan('folder name with spaces')}`),
        `    To prevent issues when running ${Terminal.cyan('elm-land build')}`,
        '    your project folder should not contain spaces.',
        '',
        '    Please try again with a folder name like this:',
        '',
        `    ${Terminal.pink(`elm-land init ${modifiedFolderName}`)}`,
        ''
      ].join('\n'))
    }

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
          name: `${name}/README.md`,
          content: toReadmeFileWithName({ name })
        },
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
          name: `${name}/.elm-land/src/Shared/Model.elm`,
          content: await Files.readFromCliFolder('src/templates/_elm-land/customizable/Shared/Model.elm')
        },
        {
          kind: 'file',
          name: `${name}/.elm-land/src/Shared/Msg.elm`,
          content: await Files.readFromCliFolder('src/templates/_elm-land/customizable/Shared/Msg.elm')
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
        }
      ],
      effects: []
    }
  } else {
    return Promise.reject([
      '',
      Utils.intro.error(`expected ${Terminal.red('a folder name')} for your project`),
      helpMessage
    ].join('\n'))
  }
}

const toReadmeFileWithName = ({ name }) => `
# ${name}
> Built with [Elm Land](https://elm.land) 🌈

## Local development

\`\`\`bash
# Requires Node.js v18+ (https://nodejs.org)
npx elm-land server
\`\`\`

## Deploying to production

Elm Land projects are most commonly deployed as static websites. 

Please visit [the "Deployment" guide](https://elm.land/guide/deploying) to learn more
about deploying your app for free using Netlify or Vercel.
`.trim()

export const Init = {
  run,
  printHelpInfo
}
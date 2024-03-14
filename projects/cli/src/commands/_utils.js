import fs from 'fs/promises'
import path from 'path'
import url from 'url'

let __dirname = path.dirname(url.fileURLToPath(import.meta.url))
let packageJsonContents = await fs.readFile(path.join(__dirname, '..', '..', 'package.json'), { encoding: 'utf-8' })
let packageJson = JSON.parse(packageJsonContents)
let version = packageJson.version

export const Terminal = {
  bold: (str) => '\x1b[1m' + str + '\x1b[0m',
  dim: (str) => '\x1b[2m' + str + '\x1b[0m',
  red: (str) => '\x1b[31m' + str + '\x1b[0m',
  green: (str) => '\x1b[32m' + str + '\x1b[0m',
  yellow: (str) => '\x1b[33m' + str + '\x1b[0m',
  pink: (str) => '\x1b[35m' + str + '\x1b[0m',
  cyan: (str) => '\x1b[36m' + str + '\x1b[0m',
}

const stripAnsi = (str) =>
  str.replace(/[\u001b\u009b][[()#;?]*(?:[0-9]{1,4}(?:;[0-9]{0,4})*)?[0-9A-ORZcf-nqry=><]/g, '')

let name =
  `Elm Land ${Terminal.dim(`(v${version})`)}`

const intro = {

  // Show header with green underline
  success: (message) => [
    `🌈  ${name} ${message}`,
    Terminal.green('    ' + '⎺'.repeat(stripAnsi(message).length + stripAnsi(name).length + 1))
  ].join('\n'),

  // Show header with red underline
  error: (message) => [
    `🌈  ${name} ${message}`,
    Terminal.red('    ' + '⎺'.repeat(stripAnsi(message).length + stripAnsi(name).length + 1))
  ].join('\n'),

  // Show header with red underline
  info: (message) => [
    `🌈  ${name} ${message}`,
    Terminal.cyan('    ' + '⎺'.repeat(stripAnsi(message).length + stripAnsi(name).length + 1))
  ].join('\n')
}

let didNotRecognizeCommand = ({ baseCommand, subCommand, subcommandList }) => [
  '',
  subCommand === undefined
    ? intro.error(`needs more details for ${Terminal.cyan(baseCommand)}`)
    : intro.error(`couldn't find an ${Terminal.cyan(`${baseCommand} ${subCommand}`)} command`),
  ...subcommandList,
  '',
].join('\n')

let notInElmLandProject = [
  '',
  intro.error(`${Terminal.cyan('couldn\'t find a project')} in this folder`),
  `    Please try again in the folder with your ${Terminal.cyan('elm-land.json')} file`,
  '',
  `    If you'd like to start a new project, run this command: `,
  '',
  `    elm-land ${Terminal.pink('init <folder>')} .... create a new project`,
  '',
].join('\n')

let foundTypeScriptErrors = [
  '',
  intro.error(`found a ${Terminal.cyan('TypeScript')} error...`),
  `    When compiling your "${Terminal.pink('src/interop.ts')}" file, the TypeScript compiler`,
  '    reported some issues. Please review the errors above.',
  '',
].join('\n')

let couldntFindTypeScriptBinary = (filepath) => [
  '',
  intro.error(`found a ${Terminal.cyan('TypeScript')} error...`),
  `    When compiling your "${Terminal.pink('src/interop.ts')}" file, the TypeScript`,
  '    compiler couldn\'t be detected on this computer.',
  '',
  '    This is likely a problem with Elm Land, please help us fix it:',
  `    ${Terminal.cyan('https://github.com/elm-land/elm-land/issues')}`,
  '',
].join('\n')

let customizableFiles = {
  'shared': {
    filepaths: [
      { src: 'Shared.elm', target: 'Shared.elm' },
      { src: 'Shared/Model.elm', target: 'Shared/Model.elm' },
      { src: 'Shared/Msg.elm', target: 'Shared/Msg.elm' }
    ],
    description: '.................... share data across pages'
  },
  'not-found': {
    filepaths: [{ src: 'Pages/NotFound_.elm', target: 'Pages/NotFound_.elm' }],
    description: '... the 404 page shown for unknown routes'
  },
  'view': {
    filepaths: [{ src: 'View.elm', target: 'View.elm' }],
    description: '......... use whatever Elm UI package you like'
  },
  'view:elm-ui': {
    filepaths: [{ src: 'ViewElmUi.elm', target: 'View.elm' }],
    description: '............................ use Elm UI'
  },
  'view:elm-css': {
    filepaths: [{ src: 'ViewElmCss.elm', target: 'View.elm' }],
    description: '.......................... use Elm CSS'
  },
  'effect': {
    filepaths: [{ src: 'Effect.elm', target: 'Effect.elm' }],
    description: '............. send custom effects from pages'
  },
  'auth': {
    filepaths: [{ src: 'Auth.elm', target: 'Auth.elm' }],
    description: '................... handle user authentication'
  },
  'js': {
    filepaths: [{ src: 'interop.js', target: 'interop.js' }],
    description: '......... work with JavaScript, flags, and ports'
  },
  'ts': {
    filepaths: [{ src: 'interop.ts', target: 'interop.ts' }],
    description: '......... work with TypeScript, flags, and ports'
  },
}

export const Utils = {
  intro,
  didNotRecognizeCommand,
  notInElmLandProject,
  foundTypeScriptErrors,
  couldntFindTypeScriptBinary,
  customizableFiles
}
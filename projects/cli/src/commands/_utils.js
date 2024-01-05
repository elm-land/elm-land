import fs from 'fs'
import path, { dirname } from 'path'
import { fileURLToPath } from 'url'

export const toDirname = (importMetaUrl) =>
  dirname(fileURLToPath(importMetaUrl))

const { version } = JSON.parse(fs.readFileSync(
  path.join(toDirname(import.meta.url), '..', '..', 'package.json'),
  { encoding: 'utf-8' })
)


export const Terminal = {
  bold: (str) => '\u001b[1m' + str + '\u001b[0m',
  dim: (str) => '\u001b[2m' + str + '\u001b[0m',
  red: (str) => '\u001b[31m' + str + '\u001b[0m',
  green: (str) => '\u001b[32m' + str + '\u001b[0m',
  pink: (str) => '\u001b[35m' + str + '\u001b[0m',
  cyan: (str) => '\u001b[36m' + str + '\u001b[0m',
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
    filepaths: ['Shared.elm', 'Shared/Model.elm', 'Shared/Msg.elm'],
    description: '.................... share data across pages'
  },
  'not-found': {
    filepaths: ['Pages/NotFound_.elm'],
    description: '... the 404 page shown for unknown routes'
  },
  'view': {
    filepaths: ['View.elm'],
    description: '................ use Elm UI, Elm CSS, and more'
  },
  'effect': {
    filepaths: ['Effect.elm'],
    description: '............. send custom effects from pages'
  },
  'auth': {
    filepaths: ['Auth.elm'],
    description: '................... handle user authentication'
  },
  'js': {
    filepaths: ['interop.js'],
    description: '......... work with JavaScript, flags, and ports'
  },
  'ts': {
    filepaths: ['interop.ts'],
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


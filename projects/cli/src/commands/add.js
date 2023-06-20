const { Files } = require("../files")
const { Utils, Terminal } = require("./_utils")
const path = require('path')
const { Codegen } = require("../codegen")

let addNewLayout = () => async ([name]) => {
  if (name === '-h' || name === '--help') {
    return {
      message: [
        '',
        Utils.intro.success(`detected the ${Terminal.green('help')} command`),
        `    The ${Terminal.cyan('elm-land add layout')} command, you'll need to provide`,
        `    the module names for the new layouts you'd like to add.`,
        '',
        '    Here are some examples:',
        '',
        `    elm-land add layout ${Terminal.pink(`Default`)}`,
        `    elm-land add layout ${Terminal.pink(`Sidebar.Header`)}`,
        ''
      ].join('\n'),
      files: [],
      effects: []
    }
  }

  if (!name) {
    return Promise.reject([
      '',
      Utils.intro.error(`expected a ${Terminal.cyan(`<module-name>`)} argument`),
      '    Here are some examples:',
      '',
      `    elm-land add layout ${Terminal.pink(`Default`)}`,
      `    elm-land add layout ${Terminal.pink(`Sidebar.Header`)}`,
      ''
    ].join('\n'))
  }

  let inFolderWithElmLandJson =
    await Files.exists(path.join(process.cwd(), 'elm-land.json'))

  if (!inFolderWithElmLandJson) {
    return Promise.reject(Utils.notInElmLandProject)
  }

  // Capitalize the name if needed
  if (name.match(/^[a-z]/)) {
    name = name[0].toUpperCase() + name.slice(1)
  }

  if (!name.match(/[A-Z][a-zA-Z0-9]*/)) {
    return Promise.reject([
      '',
      Utils.intro.error('couldn\'t create a layout with that name'),
      '    Layout names need to start with a letter, and can only contain letters and numbers',
      '',
      '    Here are some examples:',
      '',
      `    elm-land add layout ${Terminal.pink(`Sidebar`)}`,
      `    elm-land add layout ${Terminal.pink(`Sidebar.Header`)}`,
      ''
    ].join('\n'))
  }

  const moduleSegments = name.split('.')
  const hasDuplicateNames = new Set(moduleSegments).size < moduleSegments.length

  if (hasDuplicateNames) {
    return Promise.reject([
      '',
      Utils.intro.error('can\'t create layouts with repeated names'),
      '    This lead to issues later on when passing in `Props`, because',
      '    the repeated names will be ambiguous.',
      '',
      '    Here are some examples:',
      '',
      `    elm-land add layout ${Terminal.pink(`Sidebar.Tabs`)}`,
      `    elm-land add layout ${Terminal.pink(`Sidebar.Header`)}`,
      ''
    ].join('\n'))
  }

  let [generatedFile] = await Codegen.addNewLayout({
    moduleSegments
  })

  let relativeFilepath = `src/${generatedFile.filepath}`

  return {
    message: [
      '',
      Utils.intro.success(`added a new layout!`),
      '    You can edit your layout here:',
      `    ./${relativeFilepath}`,
      ''
    ].join('\n'),
    files: [
      {
        kind: 'file',
        name: relativeFilepath,
        content: generatedFile.contents
      }
    ],
    effects: []
  }
}

let addNewPage = (kind) => async ([originalUrl]) => {
  let pageAddExamples = [
    '    Here are some examples:',
    '',
    `    elm-land add ${kind === 'new' ? 'page' : `page:${kind}`} ${Terminal.pink(`/sign-in`)}`,
    `    elm-land add ${kind === 'new' ? 'page' : `page:${kind}`} ${Terminal.pink(`/users/:id`)}`,
    `    elm-land add ${kind === 'new' ? 'page' : `page:${kind}`} ${Terminal.pink(`'/users/*'`)}`,
    ''
  ]


  if (originalUrl === '-h' || originalUrl === '--help') {
    return {
      message: [
        '',
        Utils.intro.success(`detected the ${Terminal.green('help')} command`),
        `    The ${Terminal.cyan('elm-land add page')} command, you'll need to provide`,
        `    the new URLs for the pages you'd like to add.`,
        '',
        ...pageAddExamples,
        ''
      ].join('\n'),
      files: [],
      effects: []
    }
  }

  if (!originalUrl || originalUrl === '-h' || originalUrl === '--help') {
    return Promise.reject([
      '',
      Utils.intro.error(`expected a ${Terminal.cyan('<url>')} argument`),
      ...pageAddExamples
    ].join('\n'))
  } else {

    const urlValidationError = [
      originalUrl.startsWith('/')
        ? undefined
        : 'expected the URL to start with a "/"',
      originalUrl === '/' || originalUrl.slice(1).split('/').every(startsWithLowercaseLetterColonOrAsterisk)
        ? undefined
        : 'found a non lowercase letter',
      doesntHaveAsteriskBeforeTheEnd(originalUrl)
        ? undefined
        : 'found an asterisk before the last segment'
    ].find(x => x !== undefined)

    if (urlValidationError) {
      return Promise.reject([
        '',
        Utils.intro.error(urlValidationError),
        ...pageAddExamples
      ].join('\n'))
    }
    let inFolderWithElmLandJson = await Files.exists(path.join(process.cwd(), 'elm-land.json'))

    if (!inFolderWithElmLandJson) {
      return Promise.reject(Utils.notInElmLandProject)
    }

    // Don't want to generate filenames like "Blog/*.elm", so we 
    // replace the asterisk here:
    const newUrl = originalUrl.split('*').join('ALL_')

    let filepath = toNewPageModuleNamePieces({ url: newUrl })

    let [generatedFile] = await Codegen.addNewPage({
      kind,
      url: newUrl,
      filepath
    })

    let relativeFilepath = `src/${generatedFile.filepath}`

    let newFile = {
      kind: 'file',
      name: relativeFilepath,
      content: generatedFile.contents
    }

    return {
      message: [
        '',
        Utils.intro.success(`added a new page at ${Terminal.cyan(originalUrl)}`),
        '    You can edit your new page here:',
        Terminal.pink(`    ./${relativeFilepath}`),
        ''
      ].join('\n'),
      files: [newFile],
      effects: []
    }
  }
}

let toPascalCaseFromKebabCase = (str) => {
  return str.split('-')
    .map(str => str.length > 0 ? str[0].toUpperCase() + str.slice(1) : str)
    .join('')
}

let toNewPageModuleNamePiece = (str) => {
  if (str.startsWith(':')) {
    return toPascalCaseFromKebabCase(str.slice(1)) + '_'
  } else {
    return toPascalCaseFromKebabCase(str)
  }
}

let toNewPageModuleNamePieces = ({ url }) => {
  return url
    .split('/')
    .filter(a => a)
    .map(toNewPageModuleNamePiece)
}

let subcommandList = [
  '    Here are the commands:',
  '',
  `    elm-land add ${Terminal.pink('page <url>')} ....................... add a new page`,
  `    elm-land add ${Terminal.pink('layout <module-name>')} ........... add a new layout`,
  ``,
  ``,
  `    🌱 If you are following the guide at ${Terminal.cyan('https://elm.land/guide')}`,
  `    here are some other commands for folks learning the framework:`,
  ``,
  `    elm-land add ${Terminal.pink('page:view <url>')} ...... add a new read-only page`,
  `    elm-land add ${Terminal.pink('page:sandbox <url>')} ...... add a new stateful page`,
  `    elm-land add ${Terminal.pink('page:element <url>')} ... add a new side-effect page`,
]

let printHelpInfo = () => {
  return {
    message: [
      '',
      Utils.intro.success(`detected the ${Terminal.green('help')} command`),
      `    To use ${Terminal.cyan('elm-land add')}, you'll need to provide one of two`,
      `    subcommands, depending on what you'd like to add:`,
      '',
      ...subcommandList,
      '',
    ].join('\n'),
    files: [],
    effects: []
  }
}

let run = async ({ arguments }) => {
  let [subCommand, ...otherArgs] = arguments
  let subCommandHandlers = {
    'page': addNewPage('new'),
    'page:view': addNewPage('static'),
    'page:sandbox': addNewPage('sandbox'),
    'page:element': addNewPage('element'),
    'layout': addNewLayout()
  }

  let handler = subCommandHandlers[subCommand]

  if (handler) {
    return handler(otherArgs)
  } else {
    return Promise.reject(Utils.didNotRecognizeCommand({
      baseCommand: 'elm-land add',
      subCommand: subCommand,
      subcommandList: subcommandList
    }))
  }
}

module.exports = {
  Add: {
    run, printHelpInfo
  }
}

// Return true if the string starts with a lowercase letter between a-z,
// starts with a ":", or is the special "*" character
// 
// If the string is empty, return false
const a = 'a'.charCodeAt(0)
const z = 'z'.charCodeAt(0)

const startsWithLowercaseLetterColonOrAsterisk = (str) => {
  if (!str) return false
  if (str === '*') return true
  if (str[0] === ':') return true

  const firstLetter = str.charCodeAt(0)
  return (firstLetter >= a && firstLetter <= z)
}

const doesntHaveAsteriskBeforeTheEnd = (originalUrl) => {
  let segments = originalUrl.split('/')

  for (let index = 0; index < segments.length - 1; index++) {
    if (segments[index].includes('*')) {
      return false
    }
  }
  return true
}
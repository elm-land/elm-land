const { Files } = require("../files")
const { Utils, Terminal } = require("./_utils")
const path = require('path')
const { Codegen } = require("../codegen")

let addNewLayout = (kind) => async ([name]) => {
  if (!name) {
    return Promise.reject([
      '',
      Utils.intro.error(`expected a ${Terminal.cyan(`<module-name>`)} argument`),
      '    Here are some examples:',
      '',
      `    elm-land add ${kind === 'new' ? 'layout' : `layout:${kind}`} ${Terminal.pink(`Default`)}`,
      `    elm-land add ${kind === 'new' ? 'layout' : `layout:${kind}`} ${Terminal.pink(`Sidebar`)}`,
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
    name = name[0].toUpperCase() + name.slice(1);
  }
  
  if (!name.match(/[A-Z][a-zA-Z0-9]*/)) {
    return Promise.reject([
      '',
      Utils.intro.error('couldn\'t create a layout with that name'),
      '    Layout names need to start with a letter, and can only contain letters and numbers',
      '',
      '    Here are some examples:',
      '',
      `    elm-land add ${kind === 'new' ? 'layout' : `layout:${kind}`} ${Terminal.pink(`Sidebar`)}`,
      `    elm-land add ${kind === 'new' ? 'layout' : `layout:${kind}`} ${Terminal.pink(`HeaderWithTabs`)}`,
    ].join('\n'))
  }

  let [generatedFile] = await Codegen.addNewLayout({
    kind,
    name
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

let addNewPage = (kind) => async ([url]) => {
  if (!url) {
    return Promise.reject([
      '',
      Utils.intro.error(`expected a ${Terminal.cyan('<url>')} argument`),
      '    Here are some examples:',
      '',
      `    elm-land add ${kind === 'new' ? 'page' : `page:${kind}`} ${Terminal.pink(`/sign-in`)}`,
      `    elm-land add ${kind === 'new' ? 'page' : `page:${kind}`} ${Terminal.pink(`/users/:id`)}`,
      ''
    ].join('\n'))
  }

  let inFolderWithElmLandJson = await Files.exists(path.join(process.cwd(), 'elm-land.json'))

  if (!inFolderWithElmLandJson) {
    return Promise.reject(Utils.notInElmLandProject)
  }

  let filepath = toNewPageModuleNamePieces({ url })


  let [generatedFile] = await Codegen.addNewPage({
    kind,
    url,
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
      Utils.intro.success(`added a new page at ${Terminal.cyan(url)}`),
      '    You can edit your new page here:',
      Terminal.pink(`    ./${relativeFilepath}`),
      ''
    ].join('\n'),
    files: [newFile],
    effects: []
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


let run = async ({ arguments }) => {
  let [subCommand, ...otherArgs] = arguments
  let subCommandHandlers = {
    'page': addNewPage('new'),
    'page:static': addNewPage('static'),
    'page:sandbox': addNewPage('sandbox'),
    'page:element': addNewPage('element'),
    'layout:static': addNewLayout('static')
  }

  let handler = subCommandHandlers[subCommand]

  if (handler) {
    return handler(otherArgs)
  } else {
    return Promise.reject(Utils.didNotRecognizeCommand({
      baseCommand: 'elm-land add',
      subCommand: subCommand,
      subcommandList: [
        '    Here are the commands:',
        '',
        `    elm-land add ${Terminal.pink('page <url>')} ......................... add a new page`,
        ``,
        ``,
        `    🌱 If you are learning with the guide at ${Terminal.cyan('https://elm.land/guide')}`,
        `    here are some other commands you'll see in the examples:`,
        ``,
        `    elm-land add ${Terminal.pink('page:static <url>')} ........ add a new read-only page`,
        `    elm-land add ${Terminal.pink('page:sandbox <url>')} ........ add a new stateful page`,
        `    elm-land add ${Terminal.pink('page:element <url>')} ..... add a new side-effect page`,
        ``,
        `    elm-land add ${Terminal.pink('layout:static <name>')} ... add a new read-only layout`,
      ]
    }))
  }
}

module.exports = {
  Add: {
    run
  }
}
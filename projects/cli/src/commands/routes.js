const path = require('path')
const { Files } = require("../files")
const { Utils, Terminal } = require("./_utils")

let run = async ({ url } = {}) => {
  try {
    await Files.readFromUserFolder('elm-land.json')
  } catch (_) {
    return Promise.reject(Utils.notInElmLandProject)
  }

  let pages = []

  try {
    pages = await Files.listElmFilepathsInFolder(path.join(process.cwd(), 'src', 'Pages'))
  } catch (_) {
    return Promise.reject([
      '',
      Utils.intro.error(`could not list routes for this project`),
      ''
    ].join('\n'))
  }

  let toKebabCase = (pascalCase) => {
    return pascalCase.split('').map((char = '') => {
      if (char.toUpperCase() == char) {
        return `-${char.toLowerCase()}`
      } else {
        return char
      }
    }).join('').slice(1)
  }
  let toUrl = (segments) => {
    let isHomepage = segments.length === 1 && segments[0] === 'Home_'
    let isNotFound = segments.length === 1 && segments[0] === 'NotFound_'
    let toUrlSegment = (piece = '') => {
      if (piece === 'ALL_') return '*'
      else if (piece.endsWith('_')) return `:${toKebabCase(piece.slice(0, -1))}`
      else return toKebabCase(piece)
    }

    let urlPath =
      (isHomepage)
        ? '/'
        : (isNotFound)
          ? '/*'
          : `/${segments.map(toUrlSegment).join('/')}`

    return `http://localhost:1234${urlPath}`
  }

  let lines = pages
    .map(segments => `    ${Terminal.cyan(`src/Pages/${segments}.elm`)} ... ${Terminal.pink(toUrl(segments.split(path.sep)))}`)
    .sort((a, b) => a.length - b.length)

  let lengthOfFilepath = (str) => str.split('...')[0].length

  let lineWithLongestFilepath = lines.reduce((longest, line) => (lengthOfFilepath(longest) > lengthOfFilepath(line)) ? longest : line, '')

  if (lineWithLongestFilepath) {
    lines = lines.map(line => line.split('...').join('.'.repeat(lengthOfFilepath(lineWithLongestFilepath) - lengthOfFilepath(line) + 3)))
  }

  let pageCount = pages.length
  let pageCountWithUnits = pageCount === 1 ? `${pageCount} page` : `${pageCount} pages`

  return {
    message: [
      '',
      Utils.intro.success(`found ${Terminal.cyan(pageCountWithUnits)} in your application`),
      ...lines,
      '',
    ].join('\n'),
    files: [],
    effects: []
  }
}

module.exports = {
  Routes: {
    run
  }
}
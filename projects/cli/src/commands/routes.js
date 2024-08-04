import { join, sep } from 'path'
import { Files } from "../files.js"
import { Utils, Terminal } from "./_utils.js"

let printHelpInfo = () => {
  return {
    message: [
      '',
      Utils.intro.success(`detected the ${Terminal.green('help')} command`),
      `    The ${Terminal.cyan('elm-land routes')} command is a way for you to see`,
      `    all the URL routes in your Elm application.`,
      ``,
      `    ( This is inspired by the ${Terminal.cyan('Ruby on Rails')} community )`,
      ''
    ].join('\n'),
    files: [],
    effects: []
  }
}

let run = async ({ url } = {}) => {
  try {
    await Files.readFromUserFolder('elm-land.json')
  } catch (_) {
    return Promise.reject(Utils.notInElmLandProject)
  }

  let pages = []

  try {
    pages = await Files.listElmFilepathsInFolder(join(process.cwd(), 'src', 'Pages'))
  } catch (_) {
    return Promise.reject([
      '',
      Utils.intro.error(`could not list routes for this project`),
      ''
    ].join('\n'))
  }

  let toKebabCaseFromPascalCase = (str) => {
    const re = /([A-Z][a-z0-9_]*)/g;
    const groups = str.match(re);
    if (groups === null) {
      return str;
    }
    return groups.join("-").toLowerCase();
  }

  let toUrl = (segments) => {
    let isHomepage = segments.length === 1 && segments[0] === 'Home_'
    let isNotFound = segments.length === 1 && segments[0] === 'NotFound_'
    let toUrlSegment = (piece = '') => {
      if (piece === 'ALL_') return '*'
      else if (piece.endsWith('_')) return `:${toKebabCaseFromPascalCase(piece.slice(0, -1))}`
      else return toKebabCaseFromPascalCase(piece)
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
    .sort(sortRoutes)
    .map(segments => `    ${Terminal.cyan(`src/Pages/${segments}.elm`)} ... ${Terminal.pink(toUrl(segments.split(sep)))}`)

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

const sortRoutes = (a, b) => {
  // Always put Home_.elm first, and NotFound_ last
  if (a == 'Home_' || b == 'NotFound_') return -1
  if (a == 'NotFound_' || b == 'Home_') return 1

  // Attempt to sort by folder depth
  let sortByFolderDepth = a.split('/').length - b.split('/').length

  // If two items have the same folder depth, sort them alphabetically
  if (sortByFolderDepth === 0) {
    let sortAlphabetically = (a < b) ? -1 : (a > b) ? 1 : 0
    return sortAlphabetically
  } else {
    return sortByFolderDepth
  }
}


export const Routes = {
  run, printHelpInfo
}
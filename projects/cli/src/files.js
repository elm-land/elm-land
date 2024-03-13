import { rmSync, access, mkdir, existsSync, lstatSync, writeFileSync, readFileSync, mkdirSync, readdirSync, writeFile, utimesSync, statSync } from 'fs'
import { sep, join, basename } from 'path'
import path from 'path'
import url from 'url'

let __dirname = path.dirname(url.fileURLToPath(import.meta.url))

let create = async (filesAndFolders) => {
  await Promise.all(filesAndFolders.map(item => {
    switch (item.kind) {
      case 'file':
        return createFile(item)
      case 'folder':
        return createFolder(item)
      default:
        return Promise.reject(`⚰️ That ain't no file.`)
    }
  }))
}

let remove = async (filepath) => {
  rmSync(filepath)
}

// Determines if a file or folder exists
let exists = async (filepath) => {
  try {
    return new Promise((resolve, reject) => {
      access(filepath, (err) => {
        if (err) { resolve(false) } else { resolve(true) }
      })
    })
  } catch (e) {
    return false
  }
}

// Copy the contents of one folder into another
let copyPasteFolder = async ({ source, destination }) => {
  // Make sure destination folder exists first!
  await new Promise((resolve, reject) => {
    mkdir(destination, { recursive: true }, (err, path) => {
      if (err) {
        reject(err)
      } else {
        resolve(path)
      }
    })
  })
  copyFolderRecursiveSync(source, destination)
}

let copyPasteFile = async ({ source, destination }) => {

  // Ensure folder exists before pasting file
  let destinationFolder = destination.split(sep).slice(0, -1).join(sep)
  await new Promise((resolve, reject) => {
    mkdir(destinationFolder, { recursive: true }, (err, path) => {
      if (err) {
        reject(err)
      } else {
        resolve(path)
      }
    })
  })

  return copyFileSync(source, destination)
}

function copyFileSync(source, target) {

  var targetFile = target

  // If target is a directory, a new file with the same name will be created
  if (existsSync(target)) {
    if (lstatSync(target).isDirectory()) {
      targetFile = join(target, basename(source))
    }
  }

  writeFileSync(targetFile, readFileSync(source))
}

function copyFolderRecursiveSync(source, target) {
  var files = []

  // Check if folder needs to be created or integrated
  var targetFolder = join(target, basename(source))
  if (!existsSync(targetFolder)) {
    mkdirSync(targetFolder)
  }

  // Copy
  if (lstatSync(source).isDirectory()) {
    files = readdirSync(source)
    files.forEach(function (file) {
      var curSource = join(source, file)
      if (lstatSync(curSource).isDirectory()) {
        copyFolderRecursiveSync(curSource, targetFolder)
      } else {
        copyFileSync(curSource, targetFolder)
      }
    })
  }
}

let createFile = async ({ name, content }) => {
  let pieces = name.split('/')
  let folderPieces = pieces.slice(0, -1)
  let containingFolder = folderPieces.join('/')

  await createFolder({ name: containingFolder })
  await new Promise((resolve, reject) => {
    writeFile(
      join(process.cwd(), ...pieces),
      content, { encoding: 'utf-8' },
      (err) => {
        if (err) {
          reject(err)
        } else {
          resolve(true)
        }
      }
    )
  })
}

let createFolder = async ({ name }) => {
  return new Promise((resolve, reject) => {
    mkdir(
      join(process.cwd(), ...name.split('/')),
      { recursive: true },
      (err, path) => {
        if (err) {
          reject(err)
        } else {
          resolve(path)
        }
      })
  })
}

let readFromCliFolder = async (filepath) => {
  let pieces = filepath.split('/')
  let content = readFileSync(
    join(__dirname, '..', ...pieces),
    { encoding: 'utf-8' }
  )
  return content.split('\r').join('')
}

let readFromUserFolder = async (filepath) => {
  let pieces = filepath.split('/')
  let content = readFileSync(
    join(process.cwd(), ...pieces),
    { encoding: 'utf-8' }
  )
  return content.split('\r').join('')
}

// Pokes a file to trigger any related file-watchers
let touch = (filepath) => {
  let now = new Date()
  utimesSync(filepath, now, now)
}

// Read all the files in the current folder, recursively
let listElmFilepathsInFolder = (filepath) => {
  let folderExists = existsSync(filepath)

  if (folderExists) {
    let fullFilepaths = walk(filepath)
      // Exclude temporary files saved by code editors, such as 'Foo.elm~'.
      .filter(str => str.endsWith('.elm'))
    let relativeFilepaths = fullFilepaths.map(str => str.slice(filepath.length + 1, -'.elm'.length))

    return relativeFilepaths
  } else {
    return []
  }
}

var walk = function (dir) {
  var results = []
  var list = readdirSync(dir)
  list.forEach(function (file) {
    file = dir + '/' + file
    var stat = statSync(file)
    if (stat && stat.isDirectory()) {
      /* Recurse into a subdirectory */
      results = results.concat(walk(file))
    } else {
      /* Is a file */
      results.push(file)
    }
  })
  return results
}

let isNonEmptyFolder = async (filepath) => {
  try {
    return readdirSync(filepath).length > 0
  } catch (_) {
    // Crashes if folder does not exist, in which
    // case it is NOT an non-empty folder
    return false
  }
}

export const Files = {
  isNonEmptyFolder,
  readFromCliFolder,
  readFromUserFolder,
  create,
  remove,
  exists,
  copyPasteFolder,
  copyPasteFile,
  touch,
  listElmFilepathsInFolder
}
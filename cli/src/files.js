const fs = require('fs/promises')
const fsOld = require('fs')
const path = require('path')

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

// Determines if a file or folder exists
let exists = async (filepath) => {
  try {
    await fs.access(filepath)
    return true
  } catch (e) {
    return false
  }
}

// Copy the contents of one folder into another
let copyPaste = async ({ source, destination }) => {
  // Make sure destination folder exists first!
  await fs.mkdir(destination, { recursive: true })
  copyFolderRecursiveSync(source, destination)
}

function copyFileSync(source, target) {

  var targetFile = target;

  // If target is a directory, a new file with the same name will be created
  if (fsOld.existsSync(target)) {
    if (fsOld.lstatSync(target).isDirectory()) {
      targetFile = path.join(target, path.basename(source));
    }
  }

  fsOld.writeFileSync(targetFile, fsOld.readFileSync(source));
}

function copyFolderRecursiveSync(source, target) {
  var files = [];

  // Check if folder needs to be created or integrated
  var targetFolder = path.join(target, path.basename(source));
  if (!fsOld.existsSync(targetFolder)) {
    fsOld.mkdirSync(targetFolder);
  }

  // Copy
  if (fsOld.lstatSync(source).isDirectory()) {
    files = fsOld.readdirSync(source);
    files.forEach(function (file) {
      var curSource = path.join(source, file);
      if (fsOld.lstatSync(curSource).isDirectory()) {
        copyFolderRecursiveSync(curSource, targetFolder);
      } else {
        copyFileSync(curSource, targetFolder);
      }
    });
  }
}

let createFile = async ({ name, content }) => {
  let pieces = name.split('/')
  let folderPieces = pieces.slice(0, -1)
  let containingFolder = folderPieces.join('/')

  await createFolder({ name: containingFolder })
  await fs.writeFile(
    path.join(process.cwd(), ...pieces),
    content, { encoding: 'utf-8' }
  )
}

let createFolder = async ({ name }) => {
  await fs.mkdir(
    path.join(process.cwd(), ...name.split('/')),
    { recursive: true }
  )
}

module.exports = {
  Files: { create, exists, copyPaste }
}
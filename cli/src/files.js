const fs = require('fs/promises')
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
  Files: { create }
}
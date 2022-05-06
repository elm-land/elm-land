const fs = require('fs/promises')
const path = require('path')

let read = async (filepath) => {
  let pieces = filepath.split('/')
  return fs.readFile(
    path.join(__dirname, '..', '..', 'docs', ...pieces),
    { encoding: 'utf-8' }
  )
}

module.exports = {
  Docs: { read }
}
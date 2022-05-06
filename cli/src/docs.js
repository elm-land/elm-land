const fs = require('fs/promises')
const path = require('path')

let read = async (filepath) => {
  let pieces = filepath.split('/')
  let content = await fs.readFile(
    path.join(__dirname, '..', '..', 'docs', ...pieces),
    { encoding: 'utf-8' }
  )
  return content.split('\r').join('')
}

module.exports = {
  Docs: { read }
}
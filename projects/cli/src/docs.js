import { toDirname } from './commands/_utils'

const fs = require('fs')
const path = require('path')

let read = async (filepath) => {
  let pieces = filepath.split('/')
  let content = await new Promise((resolve, reject) => fs.readFile(
    path.join(toDirname(import.meta.url), '..', '..', 'docs', ...pieces),
    { encoding: 'utf-8' },
    (err, data) => {
      if (err) { reject(err) } else { resolve(data) }
    }
  ))
  return content.split('\r').join('')
}

export const Docs = { read }
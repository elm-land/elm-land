import { readFile } from 'fs'
import { join } from 'path'
import path from 'path'
import url from 'url'

let __dirname = path.dirname(url.fileURLToPath(import.meta.url))

let read = async (filepath) => {
  let pieces = filepath.split('/')
  let content = await new Promise((resolve, reject) => readFile(
    join(__dirname, '..', '..', 'docs', ...pieces),
    { encoding: 'utf-8' },
    (err, data) => {
      if (err) { reject(err) } else { resolve(data) }
    }
  ))
  return content.split('\r').join('')
}

export const Docs = { read }
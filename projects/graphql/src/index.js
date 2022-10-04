const { version } = require('../package.json')
const fs = require('fs')
const https = require('https')
const graphql = require('graphql')
const path = require('path')

const Problem = {
  create: (lines) => Promise.reject(lines.join('\n'))
}

const replaceWithEnvVariables = async (headers) => {
  const replacer = (varName) => {
    let value = process.env[varName.substring(1)]
    if (!value) {
      throw new Error([
        '',
        `🌈 Elm Land could not find a ${varName} environment variable...`,
        ''
      ].join('\n'))
    } else {
      return value
    }
  }
  let newHeaders = {}
  Object.keys(headers).forEach((key) => {
    newHeaders[key] = headers[key].replace(/\$[A-Z_-]+/, replacer)
  })
  return newHeaders
}

const commands = {
  init: async () => {
    return [
      '',
      `🌈 Welcome to Elm Land GraphQL (v${version})`,
      ''
    ].join('\n')
  },
  generate: async () => {
    let config = undefined

    try {
      let contents = fs.readFileSync(path.join(process.cwd(), 'elm-land.json'), { encoding: 'utf8' })
      config = JSON.parse(contents)
    } catch (_) { }
    if (!config) {
      return Problem.create([
        '',
        '🌈 Elm Land could not find an elm-land.json file in this folder...',
        ''
      ])
    }

    // Attempt to read URL
    let url = undefined
    try {
      url = config.graphql.schema.url
    } catch (_) { }
    if (!url) {
      return Problem.create([
        '',
        '🌈 Elm Land did not find a URL at "graphql.schema.url" in your elm-land.json file'
      ])
    }

    // Attempt to read method
    let method = undefined
    try {
      method = config.graphql.schema.method
    } catch (_) { }
    if (!method) {
      return Problem.create([
        '',
        '🌈 Elm Land did not find GET or POST at "graphql.schema.method" in your elm-land.json file'
      ])
    }

    // Attempt to read headers
    let headers = undefined
    try {
      headers = config.graphql.schema.headers || {}
    } catch (_) { }

    if (!headers) {
      return Problem.create([
        '',
        '🌈 Elm Land did not find HTTP headers at "graphql.schema.headers" in your elm-land.json file',
        ''
      ])
    }

    if (url && method && headers) {

      // Replace $VAR_NAME with actual environment variable values
      try {
        headers = await replaceWithEnvVariables(headers)
      } catch (reason) {
        return Promise.reject(reason.message)
      }

      console.log(`• Fetching schema from ${url}`)
      let introspectionJsonString = await new Promise((resolve, reject) => {
        let body = JSON.stringify({
          operationName: 'IntrospectionQuery',
          query: graphql.getIntrospectionQuery(),
          variables: {}
        })
        headers['Content-Type'] = 'application/json'
        headers['Content-Length'] = body.length

        let req = https.request(url, { method, headers, body }, (res) => {
          let result = []
          res.on('data', (chunk) => result.push(chunk))
          res.on('end', () => {
            const resString = Buffer.concat(result).toString()
            resolve(resString)
          })
        })

        req.on('error', (reason) => {
          reject(Problem.create([
            '',
            `🌈 Elm Land couldn't request the schema at ${url}`,
            ''
          ]))
        })

        req.write(body)
        req.end()
      })

      console.log(`• Saving introspection schema file...`)

      // Make folder if it doesn't exist
      try {
        fs.mkdirSync(path.join(process.cwd(), '.elm-land', 'graphql'), { recursive: true })
      } catch (_) { }

      // Create new introspection file for future requests
      fs.writeFileSync(
        path.join(process.cwd(), '.elm-land', 'graphql', 'introspection.json'),
        introspectionJsonString,
        { encoding: 'utf8' }
      )

      return `• Schema saved!`
    }
  },
  watch: async () => {

  },
}

const main = async (command, ...args) => {
  if (commands[command]) {
    return commands[command]()
  } else {
    return Promise.reject(`Command not found: ${command}`)
  }
}

// Run the program
main(...process.argv.slice(2))
  .then(console.log)
  .catch(console.error)
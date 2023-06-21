const { version } = require('../package.json')
const fs = require('fs')
const https = require('https')
const graphql = require('graphql')
const path = require('path')
const { Utils, Terminal } = require('../../cli/src/commands/_utils')

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
  build: async () => {
    const config = await attemptToReadElmJson()
    const schema = await attemptToFetchIntrospectionJson(config)
    const { queries, mutations, fragments } = await attemptToLoadLocalGraphQLFiles()
    const flags = { schema, queries, mutations, fragments }

    console.dir(flags.queries[0])

    return ''
  },
  watch: async () => {

  },
}

const run = async (command, ...args) => {
  if (commands[command]) {
    let message = await commands[command](...args)
    return {
      message,
      files: [],
      effects: []
    }
  } else {
    if (command === undefined) {
      return {
        message: helpText,
        files: [],
        effects: []
      }
    }
    return Promise.reject(`Command not found: ${command}`)
  }
}


/**
 * 
 * @returns {Promise<unknown>}
 */
const attemptToReadElmJson = () => {
  try {
    let contents = fs.readFileSync(path.join(process.cwd(), 'elm-land.json'), { encoding: 'utf8' })
    return JSON.parse(contents)
  } catch (_) { }

  return Promise.reject(Problem.create([
    '',
    '🌈 Elm Land could not find an elm-land.json file in this folder...',
    ''
  ]))
}

/**
 * 
 * @param {unknown} config 
 * @returns {Promise<graphql.IntrospectionSchema>}
 */
const attemptToFetchIntrospectionJson = async (config) => {
  let introspectionJsonString = undefined

  console.info([
    '',
    Utils.intro.success(`is building your ${Terminal.green('GraphQL')} files...`),
  ].join('\n'))

  // 1️⃣ Attempt to read schema from local file
  if (config && config.graphql && typeof config.graphql.schema === 'string') {
    try {
      const localFilepath = path.join(process.cwd(), ...config.graphql.schema.split('/'))
      const filename = config.graphql.schema.split('/').slice(-1)[0]
      const localFileContents = await fs.promises.readFile(localFilepath, { encoding: 'utf-8' })

      let schema = graphql.buildSchema(localFileContents)
      console.info(`    ${Terminal.green('✔')} Read local ${Terminal.pink(filename)} file`)

      let result = await graphql.graphql({ schema, source: graphql.getIntrospectionQuery() })
      introspectionJsonString = JSON.stringify(result, null, 2)
    } catch (problem) {
      console.error(problem)
    }
  }
  // 2️⃣ Attempt to read schema from GraphQL API endpoint
  else {

    let url = undefined
    try {
      url = config.graphql.schema.url
    } catch (_) { }
    if (!url) {
      return Problem.create([
        '',
        '🌈 Elm Land did not find a URL at "graphql.schema.url" in your elm-land.json file',
        ''
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
        '🌈 Elm Land did not find GET or POST at "graphql.schema.method" in your elm-land.json file',
        ''
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

      introspectionJsonString = await new Promise((resolve, reject) => {
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
      console.info(`    ${Terminal.green('✔')} Fetched schema from ${Terminal.pink(url)}`)
    }
  }

  if (introspectionJsonString) {
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

    console.info(`    ${Terminal.green('✔')} Saved ${Terminal.pink('introspection.json')} file`)

    return JSON.parse(introspectionJsonString)
  } else {
    return Promise.reject(Problem.create([
      '',
      `🌈 Elm Land failed to fetch the GraphQL schema`,
      ''
    ]))
  }
}

/**
 * @typedef {{ filename: string, contents: string, ast: graphql.DocumentNode }} File
 * 
 * @returns {Promise<{ queries: File[], mutations: File[], fragments: File[] }}
 */
const attemptToLoadLocalGraphQLFiles = async () => {
  let [queries, mutations, fragments] = await Promise.all([
    loadGraphQLFilesFrom({ folder: 'queries' }),
    loadGraphQLFilesFrom({ folder: 'mutations' }),
    loadGraphQLFilesFrom({ folder: 'fragments' }),
  ])
  const printCount = (array, singular, plural) => {
    if (array.length === 1) {
      return `${Terminal.pink(array.length)} ${singular}`
    } else {
      return `${Terminal.pink(array.length)} ${plural}`
    }
  }
  console.info(`    ${Terminal.green('✔')} Found ${printCount(queries, 'query', 'queries')}, ${printCount(mutations, 'mutation', 'mutations')}, and ${printCount(fragments, 'fragment', 'fragments')}`)

  return { queries, mutations, fragments }
}

/**
 * 
 * @param {{ folder: string }} args
 * @returns {Promise<File>}
 */
const loadGraphQLFilesFrom = ({ folder }) =>
  fs.promises.readdir(path.join(process.cwd(), 'graphql', folder))
    .then(filenames => Promise.all(
      filenames.map(async filename => {
        const filepath = path.join(process.cwd(), 'graphql', folder, filename)
        try {
          if (filename.endsWith('.graphql') || filename.endsWith('.gql')) {
            const contents = await fs.promises.readFile(filepath, { encoding: 'utf-8' })
            return { filename, contents, ast: graphql.parse(contents) }
          }
        } catch (parsingError) {
          const relativeFilepath = './' + filepath.split('/').slice(-3).join('/')
          console.error('')
          console.error(`    ${Terminal.red('!')} Ran into a problem with ${Terminal.pink(relativeFilepath)}:`)
          console.error([
            '',
            parsingError,
            ''
          ].join('\n').split('\n').map(Terminal.yellow).join(`\n    ${Terminal.dim('>')}  `))
          console.error('')

          console.error(`    Once that problem is fixed, please run this command again.`)
          console.error('')

          process.exit(1)
        }
      }).filter(a => a)
    ))
    .catch(_ => [])

const helpText = [
  '',
  Utils.intro.success(`detected the ${Terminal.green('help')} command`),
  `    The ${Terminal.cyan('elm-land graphql')} plugin expected one of these commands:`,
  '',
  `    elm-land graphql ${Terminal.pink(`init`)} ............................ create a new project`,
  `    elm-land graphql ${Terminal.pink(`build`)} ..... generate Elm code from .graphql files once`,
  `    elm-land graphql ${Terminal.pink(`watch`)} ... watches .graphql files, rebuilding as needed`,
  ''
].join('\n')

module.exports = {
  GraphQL: {
    run,
    printHelpInfo: () => ({
      message: helpText,
      files: [],
      effects: []
    })
  }
}


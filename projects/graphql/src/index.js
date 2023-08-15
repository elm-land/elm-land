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
    const introspection = await attemptToFetchIntrospectionJson(config)
    const schema = graphql.buildClientSchema(introspection.data)
    const { queries, mutations } = await attemptToLoadLocalGraphQLFiles(schema)
    const flags = { introspection, queries, mutations }

    // Run Elm codegen worker
    const { files } = await attemptToGenerateElmFiles(flags).catch(reason => {
      console.error(reason)
      process.exit(1)
    })

    // Save generated Elm files
    try {
      await fs.promises.rm(path.join(process.cwd(), '.elm-land', 'src', 'GraphQL'), { recursive: true })
    } catch (_) {}
    try {
      await fs.promises.mkdir(path.join(process.cwd(), '.elm-land', 'src', 'GraphQL', 'Queries'), { recursive: true })
      await fs.promises.mkdir(path.join(process.cwd(), '.elm-land', 'src', 'GraphQL', 'Mutations'), { recursive: true })
    } catch (_) {}
    await Promise.all(files.map(saveFileInElmLandSrcFolder))

    console.info(`    ${Terminal.green('✔')} Successfully generated ${printCount(files, 'file', 'files')}`)
    return ''
  },
  watch: async () => {

  },
}

/**
 * 
 * @param {ElmFile} file 
 * @returns {Promise<void>}
 */
const saveFileInElmLandSrcFolder = async (file) => {
  await fs.promises.writeFile(
    path.join(process.cwd(), '.elm-land', 'src', ...file.filepath), 
    file.contents,
    { encoding: 'utf-8' }
  )
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
    Utils.intro.success(`${Terminal.cyan('GraphQL')} build started...`),
  ].join('\n'))

  // 1️⃣ Attempt to read schema from local file
  if (config && config.graphql && typeof config.graphql.schema === 'string') {
    try {
      const localFilepath = path.join(process.cwd(), ...config.graphql.schema.split('/'))
      const filename = config.graphql.schema.split('/').slice(-1)[0]
      const localFileContents = await fs.promises.readFile(localFilepath, { encoding: 'utf-8' })

      let schema = graphql.buildSchema(localFileContents)
      console.info(`    ${Terminal.green('✔')} Found ${Terminal.pink(filename)} file`)

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
 * @param {graphql.GraphQLSchema} schema
 * @returns {Promise<{ queries: File[], mutations: File[] }}
 */
const attemptToLoadLocalGraphQLFiles = async (schema) => {
  let [queries, mutations] = await Promise.all([
    loadGraphQLFilesFrom({ schema, folder: 'queries' }),
    loadGraphQLFilesFrom({ schema, folder: 'mutations' }),
  ])
  console.info(`    ${Terminal.green('✔')} Validated ${printCount(queries, 'query', 'queries')} and ${printCount(mutations, 'mutation', 'mutations')}`)

  return { queries, mutations }
}

/**
 * 
 * @param {unknown[]} array 
 * @param {string} singular 
 * @param {string} plural 
 * @returns {string}
 */
const printCount = (array, singular, plural) => {
  if (array.length === 1) {
    return Terminal.pink(`${array.length} ${singular}`)
  } else {
    return Terminal.pink(`${array.length} ${plural}`)
  }
}

/**
 * 
 * @param {{ schema: graphql.GraphQLSchema, folder: string }} args
 * @returns {Promise<File>}
 */
const loadGraphQLFilesFrom = ({ schema, folder }) =>
  fs.promises.readdir(path.join(process.cwd(), 'graphql', folder))
    .then(filenames => Promise.all(
      filenames.map(async filename => {
        const filepath = path.join(process.cwd(), 'graphql', folder, filename)
        try {
          if (filename.endsWith('.graphql') || filename.endsWith('.gql')) {
            const contents = await fs.promises.readFile(filepath, { encoding: 'utf-8' })
            const ast = graphql.parse(contents)
            const errors = graphql.validate(schema, ast)
            
            if (errors.length === 0) {
              return { filename, contents, ast }
            } else {
              const relativeFilepath = './' + filepath.split('/').slice(-3).join('/')
              console.error('')
              console.error(`    ${Terminal.red('!')} Ran into a problem with ${Terminal.pink(relativeFilepath)}:`)
              console.error([
                '',
                '',
                ...errors,
                ''
              ].join('\n').split('\n').map(Terminal.yellow).join(`\n    ${Terminal.dim('>')}  `))
              console.error('')

              console.error(`    Once that problem is fixed, please run this command again.`)
              console.error('')

              process.exit(1)
            }
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


/**
 * @typedef {{ filename: string, contents: string, ast: graphql.DocumentNode }} ClientOperation
 * @typedef {{ filepath: string[], contents: string }} ElmFile
 * @param {{ introspection: graphql.IntrospectionSchema, queries:  ClientOperation[], mutations: ClientOperation[] }} flags 
 * @returns {Promise<ElmFile[]>}
 */
const attemptToGenerateElmFiles = async (flags) => {
  return new Promise((resolve, reject) => {
    try {
      // Load worker, ignore Debug mode errors
      let warn = console.warn
      console.warn = () => null
      const { Elm } = require('./worker/dist/elm.worker.js')
      const app = Elm.Main.init({ flags })
      console.warn = warn

      app.ports.success.subscribe(resolve)
      app.ports.failure.subscribe(reject)
    } catch (reason) {
      console.error('')
      console.error(`    ${Terminal.red('!')} Failed to run the ${Terminal.pink('code generation')} program...`)
      console.error('')
      console.error(`      ${reason}`)
      console.error('')
      process.exit(1)
    }
  })
}

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


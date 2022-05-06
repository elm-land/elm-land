#! /usr/bin/env node
const { Cli } = require('./cli')
const { Files } = require('./files')

let main = async () => {
  try {
    let command = ['npx elm-land', ...process.argv.slice(2)].join(' ')
    let output = await Cli.run(command)

    await Files.create(output.files)

    console.log(output.message)

  } catch (err) {
    console.error(err)
  }
}

main()
#! /usr/bin/env node
const { Cli } = require('./cli')
const { Effects } = require('./effects')
const { Files } = require('./files')

let main = async () => {
  try {
    let output = await Cli.run(process.argv)

    await Files.create(output.files)
    await Effects.run(output.effects)

    console.log(output.message)

  } catch (err) {
    console.error(err)
    process.exit(1)
  }
}

main()
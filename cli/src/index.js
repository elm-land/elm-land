#! /usr/bin/env node
const { Cli } = require('./cli')
const { Effects } = require('./effects')
const { Files } = require('./files')

let main = async () => {
  try {
    let output = await Cli.run(process.argv)

    await Files.create(output.files)
    let data = await Effects.run(output.effects)

    if (typeof output.message === 'string') {
      console.log(output.message)
    } else {
      console.log(output.message(data))
    }
  } catch (err) {
    console.error(err)
    process.exit(1)
  }
}

main()
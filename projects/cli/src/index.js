#! /usr/bin/env node
import { Cli } from './cli.js'
import { Effects } from './effects.js'
import { Files } from './files.js'

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
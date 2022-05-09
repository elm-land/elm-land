const path = require('path')
const child = require('child_process')

let changeFolder = ({ name }) => {
  try {
    let command = `cd ${path.join(process.cwd(), ...name.split('/'))}`
    console.log({ command })
    child.execSync(command)
    return {
      problem: null
    }
  } catch (e) {
    return {
      problem: [
        `❗️ Elm Land wasn't able to automatically enter the ${name} folder`,
        '',
        `  Please run "cd ${name}" before running more elm-land commands`
      ].join('\n')
    }
  }
}

let run = (effects) => {
  // 1. Perform all effects, one at a time
  let results = effects.map(effect => {
    switch (effect.kind) {
      case 'changeFolder':
        return changeFolder({ name: effect.folder })
      default:
        return { problem: `❗️ Unrecognized effect: ${effect.kind}` }
    }
  })

  // 2. Report the first problem you find (if any)
  for (let result of results) {
    if (result.problem) {
      return result
    }
  }

  // 3. If there weren't any problems, great!
  return { problem: null }
}

module.exports = {
  Effects: { run }
}
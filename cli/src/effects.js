let runServer = (options) => {
  console.log(options)
  return { problem: `❗️ TODO: Implement server` }
}

let run = (effects) => {
  // 1. Perform all effects, one at a time
  let results = effects.map(effect => {
    switch (effect.kind) {
      case 'runServer':
        return runServer(effect.options)
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
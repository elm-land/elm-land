let { default: ElmErrorOutput } = require('../../dist/index.js')
let fs = require('fs')

let main = async () => {
  let elmError = await ElmErrorOutput.compile('src/Main.elm')

  if (elmError) {
    fs.mkdirSync('./dist', { recursive: true })
    fs.writeFileSync(
      './dist/index.html',
      ElmErrorOutput.toColoredHtmlOutput(elmError),
      { encoding: 'utf-8' }
    )
  }

  return 'Done!'
}

main()
  .then(console.info)
  .catch(console.error)
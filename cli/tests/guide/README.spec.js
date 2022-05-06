const { Cli } = require('../../src/cli.js')
const { Docs } = require('../../src/docs.js')


let files = {
  initInputSnippet: async () => await Docs.read('snippets/init-input.sh'),
  initOutputSnippet: async () => await Docs.read('snippets/init-output.txt'),
  initOutputElmJson: async () => await Docs.read('examples/02-elm-land-app/elm.json')
}

describe('/guide', () => {
  describe('elm-land init intro', () => {

    test('prints expected message',
      async () => {
        let commandFromTheGuide = await files.initInputSnippet()
        let expectedMessage = await files.initOutputSnippet()
        let actual = await Cli.run(commandFromTheGuide)

        expect(actual.message).toEqual(expectedMessage)
      })

    test('creates expected files',
      async () => {
        let commandFromTheGuide = await files.initInputSnippet()

        let expectedFiles = [
          {
            kind: 'file',
            name: 'elm-land-twitter/elm.json',
            content: await files.initOutputElmJson()
          },
          {
            kind: 'folder',
            name: 'elm-land-twitter/src'
          }
        ]

        let actual = await Cli.run(commandFromTheGuide)

        expect(actual.files).toEqual(expectedFiles)
      })
  })
})
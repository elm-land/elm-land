const { Cli } = require('../../src/cli.js')
const { Docs } = require('../../src/docs.js')


let files = {
  initInputSnippet: async () => Docs.read('snippets/guide/init-input.sh'),
  initOutputSnippet: async () => Docs.read('snippets/guide/init-output.txt'),
  initOutputElmJson: async () => Docs.read('examples/01-hello-world/elm.json'),
  initOutputGitignore: async () => Docs.read('examples/01-hello-world/.gitignore'),
  initOutputHomepage: async () => Docs.read('examples/01-hello-world/src/Pages/Home_.elm'),
  serverInputSnippet: async () => Docs.read('snippets/guide/server-input.sh'),
  serverOutputSnippet: async () => Docs.read('snippets/guide/server-output.txt'),
}

describe('/guide', () => {
  describe('elm-land init', () => {

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
            name: `hello-world/elm.json`,
            content: await files.initOutputElmJson()
          },
          {
            kind: 'file',
            name: `hello-world/.gitignore`,
            content: await files.initOutputGitignore()
          },
          {
            kind: 'file',
            name: `hello-world/src/Pages/Home_.elm`,
            content: await files.initOutputHomepage()
          },
          {
            kind: 'file',
            name: `hello-world/.elm-land/src/Main.elm`,
            content: await Docs.read('../cli/src/templates/.elm-land/src/Main.elm')
          }
        ]

        let actual = await Cli.run(commandFromTheGuide)

        expect(actual.files).toEqual(expectedFiles)
      })
  })
  describe('elm-land server', () => {

    test('prints expected message',
      async () => {
        let commandFromTheGuide = await files.serverInputSnippet()
        let expectedMessage = await files.serverOutputSnippet()
        let actual = await Cli.run(commandFromTheGuide)

        expect(actual.message).toEqual(expectedMessage)
      })

    test('starts a server on port 1234', async () => {

      let commandFromTheGuide = await files.serverInputSnippet()
      let expectedPort = 1234
      let actual = await Cli.run(commandFromTheGuide)

      expect(actual.effects).toHaveLength(1)
      expect(actual.effects[0].options.port).toEqual(expectedPort)
    })
  })
})
import path from 'path'
import ElmErrorJson, { ElmError } from  '../../src/index'

let rawJson : string | undefined
let parsedError : ElmError | undefined

beforeAll(async () => {
  let filepath = path.join(__dirname, 'src', 'Main.elm')
  process.chdir(__dirname)
  rawJson = await ElmErrorJson.toRawJsonString(filepath)
  parsedError = await ElmErrorJson.compile(filepath)  
})

describe('02-typo', () => {
  test("raw error is what we expect", () => {
    expect(rawJson).toBe("{\"type\":\"compile-errors\",\"errors\":[{\"path\":\"/home/ryan/code/elm-land/elm-land/elm-error-json/tests/02-typo/src/Main.elm\",\"name\":\"Main\",\"problems\":[{\"title\":\"NAMING ERROR\",\"region\":{\"start\":{\"line\":8,\"column\":5},\"end\":{\"line\":8,\"column\":13}},\"message\":[\"I cannot find a `Html.tet` variable:\\n\\n8|     Html.tet \\\"Hello, world!\\\"\\n       \",{\"bold\":false,\"underline\":false,\"color\":\"RED\",\"string\":\"^^^^^^^^\"},\"\\nThe `Html` module does not expose a `tet` variable. These names seem close\\nthough:\\n\\n    \",{\"bold\":false,\"underline\":false,\"color\":\"yellow\",\"string\":\"Html.text\"},\"\\n    \",{\"bold\":false,\"underline\":false,\"color\":\"yellow\",\"string\":\"Html.del\"},\"\\n    \",{\"bold\":false,\"underline\":false,\"color\":\"yellow\",\"string\":\"Html.dt\"},\"\\n    \",{\"bold\":false,\"underline\":false,\"color\":\"yellow\",\"string\":\"Html.em\"},\"\\n\\n\",{\"bold\":false,\"underline\":true,\"color\":null,\"string\":\"Hint\"},\": Read <https://elm-lang.org/0.19.1/imports> to see how `import`\\ndeclarations work in Elm.\"]}]}]}")
  })

  test('error can be parsed', () => {
    expect(parsedError).toBeDefined()

    if (parsedError) {
      console.log(ElmErrorJson.toColoredTerminalOutput(parsedError))
    }
  })

})
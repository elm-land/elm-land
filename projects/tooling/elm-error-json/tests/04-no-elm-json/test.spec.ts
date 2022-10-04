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

describe('04-no-elm-json', () => {
  test("raw error is what we expect", () => {
    expect(rawJson).toBe("{\"type\":\"error\",\"path\":null,\"title\":\"NO elm.json FILE\",\"message\":[\"It looks like you are starting a new Elm project. Very exciting! Try running:\\n\\n    \",{\"bold\":false,\"underline\":false,\"color\":\"GREEN\",\"string\":\"elm init\"},\"\\n\\nIt will help you get set up. It is really simple!\"]}")
  })

  test('error can be parsed', () => {
    expect(parsedError).toBeDefined()

    if (parsedError) {
      console.log(ElmErrorJson.toColoredTerminalOutput(parsedError))
    }
  })

})
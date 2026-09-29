import { beforeAll, describe, expect, test } from "@jest/globals";
import path from "path";
import ElmErrorJson, { ElmError } from "../../src/index";

let rawJson: string | undefined;
let parsedError: ElmError | undefined;

beforeAll(async () => {
  let filepath = path.join(__dirname, "src", "Main.elm");
  process.chdir(__dirname);
  rawJson = await ElmErrorJson.toRawJsonString(filepath);
  parsedError = await ElmErrorJson.compile(filepath);
}, 30000);

describe("03-missing-import", () => {
  test("raw error is what we expect", () => {
    if (rawJson === undefined) {
      throw Error("rawJson is undefined");
    }
    const expected = JSON.parse(
      `{"type":"compile-errors","errors":[{"path":"${__dirname}/src/Main.elm","name":"Main","problems":[{"title":"NAMING ERROR","region":{"start":{"line":4,"column":4},"end":{"line":4,"column":13}},"message":["I cannot find a \`Html.text\` variable:\\n\\n5|     Html.text \\"Hello, world!\\"\\n       ",{"bold":false,"underline":false,"color":"RED","string":"^^^^^^^^^"},"\\nI cannot find a \`Html\` import. These names seem close though:\\n\\n    ",{"bold":false,"underline":false,"color":"yellow","string":"Cmd.map"},"\\n    ",{"bold":false,"underline":false,"color":"yellow","string":"Cmd.none"},"\\n    ",{"bold":false,"underline":false,"color":"yellow","string":"List.head"},"\\n    ",{"bold":false,"underline":false,"color":"yellow","string":"List.sort"},"\\n\\n",{"bold":false,"underline":true,"color":null,"string":"Hint"},": Read <https://elm-lang.org/0.19.2/imports> to see how \`import\`\\ndeclarations work in Elm."]}]}]}`,
    );
    const actual = JSON.parse(rawJson);
    expect(actual).toStrictEqual(expected);
  }, 30000);

  test("error can be parsed", () => {
    expect(parsedError).toBeDefined();

    if (parsedError) {
      console.log(ElmErrorJson.toColoredTerminalOutput(parsedError));
    }
  }, 30000);
});


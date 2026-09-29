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

describe("02-typo", () => {
  test("raw error is what we expect", () => {
    if (rawJson === undefined) {
      throw Error("rawJson is undefined");
    }
    const expected = JSON.parse(
      `{"type":"compile-errors","errors":[{"path":"${__dirname}/src/Main.elm","name":"Main","problems":[{"title":"NAMING ERROR","region":{"start":{"line":7,"column":4},"end":{"line":7,"column":12}},"message":["I cannot find a \`Html.tet\` variable:\\n\\n8|     Html.tet \\"Hello, world!\\"\\n       ",{"bold":false,"underline":false,"color":"RED","string":"^^^^^^^^"},"\\nThe \`Html\` module does not expose a \`tet\` variable. These names seem close\\nthough:\\n\\n    ",{"bold":false,"underline":false,"color":"yellow","string":"Html.text"},"\\n    ",{"bold":false,"underline":false,"color":"yellow","string":"Html.del"},"\\n    ",{"bold":false,"underline":false,"color":"yellow","string":"Html.dt"},"\\n    ",{"bold":false,"underline":false,"color":"yellow","string":"Html.em"},"\\n\\n",{"bold":false,"underline":true,"color":null,"string":"Hint"},": Read <https://elm-lang.org/0.19.2/imports> to see how \`import\`\\ndeclarations work in Elm."]}]}]}`,
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


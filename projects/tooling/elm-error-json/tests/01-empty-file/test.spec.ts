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

describe("01-empty-file", () => {
  test("raw error is what we expect", () => {
    if (rawJson === undefined) {
      throw Error("rawJson is undefined");
    }
    const expected = JSON.parse(
      `{"type":"compile-errors","errors":[{"path":"${__dirname}/src/Main.elm","name":"Main","problems":[{"title":"UNFINISHED MODULE DECLARATION","region":{"start":{"line":0,"column":11},"end":{"line":0,"column":11}},"message":["I am parsing an \`module\` declaration, but I got stuck here:\\n\\n1| module Main\\n              ",{"bold":false,"underline":false,"color":"RED","string":"^"},"\\nHere are some examples of valid \`module\` declarations:\\n\\n    ",{"bold":false,"underline":false,"color":"CYAN","string":"module"}," Main ",{"bold":false,"underline":false,"color":"CYAN","string":"exposing"}," (..)\\n    ",{"bold":false,"underline":false,"color":"CYAN","string":"module"}," Dict ",{"bold":false,"underline":false,"color":"CYAN","string":"exposing"}," (Dict, empty, get)\\n\\nI generally recommend using an explicit exposing list. I can skip compiling a\\nbunch of files when the public interface of a module stays the same, so exposing\\nfewer values can help improve compile times!"]}]}]}`,
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


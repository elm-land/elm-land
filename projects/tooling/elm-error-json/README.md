# @elm-land/elm-error-json

> Convert Elm compiler JSON into formatted HTML or terminal output

```sh
# Note: not published yet!
npm install @elm-land/tooling
```

```js
import { ElmErrorJson } from '@elm-land/tooling'

let error = ElmErrorJson.compile('src/Main.elm')

if (error) {
  let message = ElmErrorJson.toTerminalOutput(error)
  console.error(message)
} else {
  console.info('Woohoo!!')
}
```
# @elm-land/codegen
> An Elm package for generating Elm code

## __Installation__

```
elm install elm-land/codegen
```

( See [notable alternatives](#notable-alternatives) below! )

## __Basic usage__

Here's a basic example of how you might generate an Elm file with this package.

### 1. __Add a __`./src/Worker.elm`__ file__

```elm
port module Worker exposing (main)

import CodeGen
import CodeGen.Annotation
import CodeGen.Declaration
import CodeGen.Expression
import CodeGen.Import
import CodeGen.Module


port onComplete : List CodeGen.File -> Cmd msg


main : CodeGen.Program ()
main =
    CodeGen.program
        { onComplete = onComplete
        , modules =
            [ mainElmModule
            ]
        }


mainElmModule : CodeGen.Module
mainElmModule =
    CodeGen.Module.new
        { name = [ "Main" ]
        , exposing_ = [ "main" ]
        , imports =
            [ CodeGen.Import.new [ "Html" ]
                |> CodeGen.Import.withExposing [ "Html" ]
            ]
        , declarations =
            [ CodeGen.Declaration.function
                { name = "main"
                , annotation = CodeGen.Annotation.type_ "Html msg"
                , arguments = []
                , expression =
                    CodeGen.Expression.function
                        { name = "Html.text"
                        , arguments = [ CodeGen.Expression.string "Hello, world!" ]
                        }
                }
            ]
        }
```

### 2. __Add a `./src/index.js` file__

```javascript
const fs = require('fs')
const { Elm } = require('../dist/elm-worker.js')

// 1. Run the Elm worker
let app = Elm.Worker.init()

// 2. Save those new files
app.ports.onSuccess(files => {
  files.forEach(file => {
    fs.writeFileSync(
      file.filepath,
      file.contents,
      { encoding: 'utf8' }
    )
    console.log(`✅ Created ${file.filepath}!`)
  })
})
```


### 3. __Running the Node.js program__

1. __Compile__ the Elm worker to JavaScript

    ```txt
    $ elm make src/Worker --output=dist/elm-worker.js
    ```

2. __Run__ your Node.js program

    ```txt
    $ node src/index.js
    ✅ Created Main.elm!
    ```

3. __See__ the generated file at `./Main.elm`

```elm
module Main exposing (main)

import Html exposing (Html)


main : Html msg
main = 
    Html.text "Hello, world!"
```

## __Notable alternatives__

This package was designed for use in [Elm Land](https://elm.land). Our use case prioritized:
- _Ease-of-use_ over _type-safety_
- _Fine-grained control_ over _concise code_

However, you might prefer one of these more powerful solutions for use in your next codegen project:

1. [the-sett/elm-syntax-dsl](https://package.elm-lang.org/packages/the-sett/elm-syntax-dsl/latest) 
    - __Benefits:__
      - More type-safe than this package
      - Aims to be compatable with elm-format
2. [mdgriffith/elm-codegen](https://github.com/mdgriffith/elm-codegen)
    - __Benefits:__
      - Automatic imports
      - Inferred type annotations
      - Built-in CLI tool for getting started
      - More type-safe than this package
      - Aims to be compatable with elm-format
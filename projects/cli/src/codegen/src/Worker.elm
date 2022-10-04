port module Worker exposing (main)

import CodeGen
import Commands.AddPage
import Commands.AddLayout
import Commands.Generate
import Json.Decode


port onComplete : List CodeGen.File -> Cmd msg


type alias Flags =
    { tag : String
    , data : Json.Decode.Value
    }


main : CodeGen.Program Flags
main =
    CodeGen.program
        { onComplete = onComplete
        , modules =
            \flags ->
                case flags.tag of
                    "generate" ->
                        Commands.Generate.run flags.data

                    "add-page" ->
                        Commands.AddPage.run flags.data

                    "add-layout" ->
                        Commands.AddLayout.run flags.data

                    _ ->
                        []
        }

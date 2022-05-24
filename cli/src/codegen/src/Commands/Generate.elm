module Commands.Generate exposing (run)

import CodeGen
import Json.Decode


run : Json.Decode.Value -> List CodeGen.Module
run _ =
    []

module Filepath exposing
    ( Filepath(..), decoder
    , toRelativeFilepath, toModuleName
    )

{-|

@docs Filepath, decoder
@docs toRelativeFilepath, toModuleName

-}

import Json.Decode


type Filepath
    = Filepath ( String, List String )


{-| Create a Filepath from a JSON response. Expects a list of strings

    Json """ [ "Pages", "Home_"] """ == Ok Filepath

-}
decoder : { folder : String } -> Json.Decode.Decoder Filepath
decoder options =
    Json.Decode.list Json.Decode.string
        |> Json.Decode.andThen
            (\filepathStrings ->
                case filepathStrings of
                    [] ->
                        Json.Decode.fail "Filepath cannot be empty"

                    _ ->
                        Json.Decode.succeed
                            (Filepath ( options.folder, filepathStrings ))
            )


{-|

    Filepath [ "Pages", "Home_" ]
        |> toRelativeFilepath
        == "src/Pages/Home_.elm"

-}
toRelativeFilepath : Filepath -> String
toRelativeFilepath (Filepath ( first, rest )) =
    "src/" ++ first ++ "/" ++ String.join "/" rest ++ ".elm"


{-|

    Filepath [ "Pages", "Home_" ]
        |> toModuleName
        == "Pages.Home_"

-}
toModuleName : Filepath -> String
toModuleName (Filepath ( first, rest )) =
    first ++ "." ++ String.join "." rest

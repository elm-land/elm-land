module Error.Format exposing
    ( block
    , cyan, yellow, green, red, grey
    )

{-|

@docs block

@docs cyan, yellow, green, red, grey

-}


{-| An indented block with a newline above and below
-}
block : List String -> String
block lines =
    "\n    " ++ String.join "\n    " lines ++ "\n"



{-
   If more colors are wanted, this is a good reference:
   https://github.com/chalk/chalk/blob/main/source/vendor/ansi-styles/index.js
-}


{-| -}
cyan : String -> String
cyan str =
    color 36 39 str


{-| -}
yellow : String -> String
yellow str =
    color 33 39 str


{-| -}
green : String -> String
green str =
    color 32 39 str


{-| -}
red : String -> String
red str =
    color 31 39 str


{-| -}
grey : String -> String
grey str =
    color 90 39 str


{-| -}
color : Int -> Int -> String -> String
color openCode closeCode content =
    let
        delim code =
            --"\\u001B[" ++ String.fromInt code ++ "m"
            "\u{001B}[" ++ String.fromInt code ++ "m"
    in
    delim openCode ++ content ++ delim closeCode

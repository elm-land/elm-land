module Error exposing
    ( Error, new, toJson
    , ErrorMessage, text
    , bold, underline
    , red, yellow, green, cyan
    )

{-|

@docs Error, new, toJson
@docs ErrorMessage, text
@docs bold, underline
@docs red, yellow, green, cyan

-}

import Json.Encode


type Error
    = Error
        { path : String
        , title : String
        , message : List ErrorMessage
        }


new :
    { path : String
    , title : String
    , message : List ErrorMessage
    }
    -> Error
new options =
    Error options


toJson : Error -> Json.Encode.Value
toJson (Error error) =
    Json.Encode.object
        [ ( "type", Json.Encode.string "error" )
        , ( "path", Json.Encode.string error.path )
        , ( "title", Json.Encode.string (String.toUpper error.title) )
        , ( "message", Json.Encode.list fromMessageToJson error.message )
        ]


text : String -> ErrorMessage
text str =
    PlainText str


bold : String -> ErrorMessage
bold str =
    StyledText
        { bold = True
        , underline = False
        , color = Nothing
        , string = str
        }


underline : String -> ErrorMessage
underline str =
    StyledText
        { bold = False
        , underline = True
        , color = Nothing
        , string = str
        }


red : String -> ErrorMessage
red str =
    StyledText
        { bold = False
        , underline = False
        , color = Just RED
        , string = str
        }


cyan : String -> ErrorMessage
cyan str =
    StyledText
        { bold = False
        , underline = False
        , color = Just CYAN
        , string = str
        }


yellow : String -> ErrorMessage
yellow str =
    StyledText
        { bold = False
        , underline = False
        , color = Just YELLOW
        , string = str
        }


green : String -> ErrorMessage
green str =
    StyledText
        { bold = False
        , underline = False
        , color = Just GREEN
        , string = str
        }


type ErrorMessage
    = PlainText String
    | StyledText
        { bold : Bool
        , underline : Bool
        , color : Maybe Color
        , string : String
        }


fromMessageToJson : ErrorMessage -> Json.Encode.Value
fromMessageToJson message =
    case message of
        PlainText str ->
            Json.Encode.string str

        StyledText item ->
            Json.Encode.object
                [ ( "bold", Json.Encode.bool item.bold )
                , ( "underline", Json.Encode.bool item.underline )
                , ( "color"
                  , case item.color of
                        Just someColor ->
                            Json.Encode.string (fromColorToString someColor)

                        Nothing ->
                            Json.Encode.null
                  )
                , ( "string", Json.Encode.string item.string )
                ]


type Color
    = RED
    | MAGENTA
    | YELLOW
    | GREEN
    | CYAN
    | BLUE
    | BLACK
    | WHITE


fromColorToString : Color -> String
fromColorToString color =
    case color of
        RED ->
            "RED"

        MAGENTA ->
            "MAGENTA"

        YELLOW ->
            "YELLOW"

        GREEN ->
            "GREEN"

        CYAN ->
            "CYAN"

        BLUE ->
            "BLUE"

        BLACK ->
            "BLACK"

        WHITE ->
            "WHITE"

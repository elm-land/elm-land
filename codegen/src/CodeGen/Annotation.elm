module CodeGen.Annotation exposing
    ( Annotation
    , string
    , record, multilineRecord
    , function, type_, genericType
    , toString
    )

{-|

@docs Annotation
@docs string
@docs record, multilineRecord
@docs function, type_, genericType

@docs toString

-}

import Util.String


{-| Represents a type annotation in your Elm module.
-}
type Annotation
    = TypeAnnotation String
    | GenericTypeAnnotation String (List Annotation)
    | FunctionAnnotation (List Annotation)
    | RecordAnnotation (List ( String, Annotation ))
    | MultilineRecordAnnotation (List ( String, Annotation ))


{-| A type alias, custom type, or a type from another module.

    -- Person
    CodeGen.Annotation.type_ "Person"

    -- Html msg
    CodeGen.Annotation.type_ "Html msg"

    -- Html.Attribute msg
    CodeGen.Annotation.type_ "Html.Attribute msg"

-}
type_ : String -> Annotation
type_ str =
    TypeAnnotation str


{-| A type alias, custom type, or a type from another module.

    -- Person
    CodeGen.Annotation.genericType "Person" []

    -- Html msg
    CodeGen.Annotation.genericType "Html"
        [ CodeGen.Annotation.type_ "msg"
        ]

    -- Request { username : String }
    CodeGen.Annotation.genericType "Request"
        [ CodeGen.Annotation.record
            [ ( "username", CodeGen.Annotation.string )
            ]
        ]

-}
genericType : String -> List Annotation -> Annotation
genericType str annotations =
    GenericTypeAnnotation str annotations


{-| A function annotation, where each piece is joined together by the `->` symbol

    -- String -> Html msg
    CodeGen.Annotation.function
        [ CodeGen.Annotation.string
        , CodeGen.Annotation.type_ "Html msg"
        ]

-}
function : List Annotation -> Annotation
function options =
    FunctionAnnotation options


{-| A record annotation in your Elm code

    -- {}
    CodeGen.Annotation.record []

    -- { username : String }
    CodeGen.Annotation.record
        [ ( "username", CodeGen.Annotation.string )
        ]

    -- { id : String, view : Html msg }
    CodeGen.Annotation.record
        [ ( "id", CodeGen.Annotation.string )
        , ( "view", CodeGen.Annotation.type_ "Html msg" )
        ]

-}
record : List ( String, Annotation ) -> Annotation
record options =
    RecordAnnotation options


{-| A record annotation in your Elm code

    -- {}
    CodeGen.Annotation.multilineRecord []

    {-

       { username : String
       }

    -}
    CodeGen.Annotation.multilineRecord
        [ ( "username", CodeGen.Annotation.string )
        ]

    {-

       { id : String
       , view : Html msg
       }

    -}
    CodeGen.Annotation.multilineRecord
        [ ( "id", CodeGen.Annotation.string )
        , ( "view", CodeGen.Annotation.type_ "Html msg" )
        ]

-}
multilineRecord : List ( String, Annotation ) -> Annotation
multilineRecord options =
    MultilineRecordAnnotation options


{-| The type annotation for Elm's `String` type

    -- String
    CodeGen.Annotation.string

-}
string : Annotation
string =
    TypeAnnotation "String"


{-| Render an `Annotation` value to a `String`

( Used internally by `CodeGen.Module` )

-}
toString : Annotation -> String
toString annotation =
    case annotation of
        TypeAnnotation str ->
            str

        GenericTypeAnnotation str annotations ->
            str ++ " " ++ String.join " " (List.map toString annotations)

        FunctionAnnotation annotations ->
            String.join " -> " (List.map toString annotations)

        RecordAnnotation items ->
            Util.String.toRecord
                { joinWith = ":"
                , toKey = \( key, _ ) -> key
                , toValue = \( _, annotation_ ) -> toString annotation_
                , items = items
                }

        MultilineRecordAnnotation items ->
            Util.String.toMultilineRecord
                { joinWith = ":"
                , toKey = \( key, _ ) -> key
                , toValue = \( _, annotation_ ) -> toString annotation_
                , items = items
                }

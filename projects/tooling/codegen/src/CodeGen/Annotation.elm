module CodeGen.Annotation exposing
    ( Annotation
    , string
    , record, multilineRecord, extensibleRecord
    , function, type_, genericType
    , parens
    , toString
    )

{-|

@docs Annotation
@docs string
@docs record, multilineRecord, extensibleRecord
@docs function, type_, genericType
@docs parens

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
    | ExtensibleRecordAnnotation String (List ( String, Annotation ))
    | Parens Annotation


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

    -- Route { username : String }
    CodeGen.Annotation.genericType "Route"
        [ CodeGen.Annotation.record
            [ ( "username", CodeGen.Annotation.string )
            ]
        ]

-}
genericType : String -> List Annotation -> Annotation
genericType str annotations =
    GenericTypeAnnotation str annotations


{-| Wraps an annotation in parentheses
-}
parens : Annotation -> Annotation
parens annotation =
    Parens annotation


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


{-| An extensible record annotation in your Elm code

    {-

       { a | path : String, hash : Maybe String }

    -}
    CodeGen.Annotation.extensibleRecord "a"
        [ ( "path", CodeGen.Annotation.string )
        , ( "hash", CodeGen.Annotation.type_ "Maybe String" )
        ]

-}
extensibleRecord : String -> List ( String, Annotation ) -> Annotation
extensibleRecord baseType fields =
    ExtensibleRecordAnnotation baseType fields


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

        ExtensibleRecordAnnotation baseType items ->
            "{ {{baseType}} | {{fields}} }"
                |> String.replace "{{baseType}}" baseType
                |> String.replace "{{fields}}"
                    (List.map fieldToString items
                        |> String.join ", "
                    )

        Parens anno ->
            Util.String.wrapInParentheses (toString anno)


fieldToString : ( String, Annotation ) -> String
fieldToString ( name, annotation ) =
    name ++ " : " ++ toString annotation

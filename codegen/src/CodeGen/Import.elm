module CodeGen.Import exposing
    ( Import, new
    , withAlias, withExposing
    , toString
    )

{-|

@docs Import, new
@docs withAlias, withExposing

@docs toString

-}


{-| Represents a single import statement in your Elm module.
-}
type Import
    = Import
        { name : List String
        , alias : Maybe String
        , exposing_ : List String
        }


{-| Create an `Import` from a module name, without any aliases or exposed types/values.

    -- import Html
    CodeGen.Import.new [ "Html" ]

    -- import Html.Attributes
    CodeGen.Import.new [ "Html", "Attributes" ]

-}
new : List String -> Import
new name =
    Import { name = name, alias = Nothing, exposing_ = [] }


{-| Add an `alias` you'd like this import statement to use.

    -- import Html.Attributes as Attr
    CodeGen.Import.new [ "Html", "Attributes" ]
        |> CodeGen.Import.withAlias "Attr"

-}
withAlias : List String -> Import -> Import
withAlias exposing_ (Import options) =
    Import { options | exposing_ = exposing_ }


{-| Add a list of values or types you'd like this module to expose.

    -- import Html exposing (Html, text)
    CodeGen.Import.new [ "Html" ]
        |> CodeGen.Import.withExposing [ "Html", "text" ]

-}
withExposing : List String -> Import -> Import
withExposing exposing_ (Import options) =
    Import { options | exposing_ = exposing_ }


{-| Render an `Import` value as a `String`.

( This is used internally by `CodeGen.Module.toString` )

-}
toString : Import -> String
toString (Import options) =
    "import {{name}}{{alias}}{{exposing}}"
        |> String.replace "{{name}}" (String.join "." options.name)
        |> String.replace "{{alias}}"
            (case options.alias of
                Nothing ->
                    ""

                Just aliasName ->
                    " as " ++ aliasName
            )
        |> String.replace "{{exposing}}"
            (case options.exposing_ of
                [] ->
                    ""

                items ->
                    " exposing (" ++ String.join ", " items ++ ")"
            )

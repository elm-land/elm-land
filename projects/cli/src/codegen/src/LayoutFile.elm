module LayoutFile exposing
    ( LayoutFile, decoder
    , sorter
    , toList
    , toModuleName, toVariantName
    , toLayoutTypeDeclaration
    , toLayoutsModelTypeDeclaration, toLayoutsMsgTypeDeclaration
    )

{-|

@docs LayoutFile, decoder
@docs sorter

@docs toList

@docs toModuleName, toVariantName

@docs toLayoutTypeDeclaration
@docs toLayoutsModelTypeDeclaration, toLayoutsMsgTypeDeclaration

-}

import CodeGen
import CodeGen.Annotation
import CodeGen.Declaration
import Extras.String
import Json.Decode


{-| Represents an item in the "src/Layouts" folder
-}
type LayoutFile
    = LayoutFile (List String)


{-| Attempts to convert a raw JSON array of strings into a `LayoutFile`
-}
decoder : Json.Decode.Decoder LayoutFile
decoder =
    Json.Decode.map LayoutFile
        (Json.Decode.list Json.Decode.string)


{-| Returns a list of filepath segments.

For example, the layout file at `src/Layouts/Sidebar/WithHeader.elm` would return:

    [ "Sidebar", "WithHeader" ]

-}
toList : LayoutFile -> List String
toList (LayoutFile list) =
    list


{-| Return the Elm module name for this layout:

    -- `src/Layouts/Sidebar.elm`
    toModuleName layout
        == "Layouts.Sidebar"

    -- `src/Layouts/Sidebar/WithHeader.elm`
    toModuleName layout
        == "Layouts.Sidebar.WithHeader"

-}
toModuleName : LayoutFile -> String
toModuleName (LayoutFile list) =
    "Layouts." ++ String.join "." list


{-| Generates the type declaration used in `Layouts.elm`, used with `Page.withLayout`
to select the layout for a given page. Here's an example:

    type Layout
        = Default Layouts.Default.Settings
        | Sidebar Layouts.Sidebar.Settings
        | Sidebar__WithHeader
            { sidebar : Layouts.Sidebar.Settings
            , withHeader : Layouts.Sidebar.WithHeader.Settings
            }

-}
toLayoutTypeDeclaration : List LayoutFile -> CodeGen.Declaration
toLayoutTypeDeclaration layouts =
    if List.isEmpty layouts then
        CodeGen.Declaration.typeAlias
            { name = "Layout"
            , annotation = CodeGen.Annotation.type_ "Never"
            }

    else
        CodeGen.Declaration.customType
            { name = "Layout"
            , variants =
                layouts
                    |> List.map (toLayoutRouteVariant { prefix = Nothing, typeName = "Settings" })
            }


{-| Generates the type declaration used in `Main.elm` to track the current state of
the active layout. Here's an example:

    type LayoutModel
        = Default Layouts.Default.Model
        | Sidebar Layouts.Sidebar.Model
        | Sidebar__WithHeader
            { sidebar : Layouts.Sidebar.Model
            , withHeader : Layouts.Sidebar.WithHeader.Model
            }

-}
toLayoutsModelTypeDeclaration : List LayoutFile -> CodeGen.Declaration
toLayoutsModelTypeDeclaration layouts =
    if List.isEmpty layouts then
        CodeGen.Declaration.typeAlias
            { name = "LayoutModel"
            , annotation = CodeGen.Annotation.type_ "Never"
            }

    else
        CodeGen.Declaration.customType
            { name = "LayoutModel"
            , variants =
                layouts
                    |> List.map
                        (toLayoutRouteVariant
                            { prefix = Just "LayoutModel_"
                            , typeName = "Model"
                            }
                        )
            }


toLayoutsMsgTypeDeclaration : List LayoutFile -> CodeGen.Declaration
toLayoutsMsgTypeDeclaration layouts =
    let
        toLayoutMsgCustomType : List LayoutFile -> List ( String, List CodeGen.Annotation )
        toLayoutMsgCustomType pages =
            let
                toCustomType : LayoutFile -> ( String, List CodeGen.Annotation.Annotation )
                toCustomType filepath =
                    ( "LayoutMsg_" ++ toVariantName filepath
                    , [ CodeGen.Annotation.type_ (toModuleName filepath ++ ".Msg") ]
                    )
            in
            List.map toCustomType pages
    in
    if List.isEmpty layouts then
        CodeGen.Declaration.typeAlias
            { name = "LayoutMsg"
            , annotation = CodeGen.Annotation.type_ "Never"
            }

    else
        CodeGen.Declaration.customType
            { name = "LayoutMsg"
            , variants = toLayoutMsgCustomType layouts
            }


{-| Layouts are sorted alphabetically when generated, so that nested layouts
appear near their parents. The order doesn't impact correctness, but it helps folks
reading the generated code.

    List.sortWith sorter [ "Sidebar__WithHeader", "Default", "Sidebar" ]
        == [ "Default"
           , "Sidebar"
           , "Sidebar__WithHeader"
           ]

-}
sorter : LayoutFile -> LayoutFile -> Basics.Order
sorter (LayoutFile list1) (LayoutFile list2) =
    Basics.compare
        (String.join "_" list1)
        (String.join "_" list2)



-- INTERNALS


{-| A helper function used by `Main.LayoutsModel` and `Layouts.Layout` to make
sure we correctly use record arguments when dealing with nested layouts
-}
toLayoutRouteVariant :
    { typeName : String
    , prefix : Maybe String
    }
    -> LayoutFile
    -> ( String, List CodeGen.Annotation )
toLayoutRouteVariant options layoutFile =
    let
        (LayoutFile list) =
            layoutFile

        baseVariantName : String
        baseVariantName =
            toVariantName layoutFile

        toLayoutRouteVariantAnnotation : CodeGen.Annotation
        toLayoutRouteVariantAnnotation =
            let
                isNestedLayout : Bool
                isNestedLayout =
                    List.length list > 1
            in
            if isNestedLayout then
                toNestedLayoutRecordAnnotation

            else
                CodeGen.Annotation.type_ (toModuleName layoutFile ++ "." ++ options.typeName)

        toNestedLayoutRecordAnnotation : CodeGen.Annotation
        toNestedLayoutRecordAnnotation =
            let
                toNestedLayoutRecordField : Int -> String -> ( String, CodeGen.Annotation )
                toNestedLayoutRecordField index pathSegment =
                    ( Extras.String.fromPascalCaseToCamelCase pathSegment
                    , CodeGen.Annotation.type_ (toModuleName (LayoutFile (List.take (index + 1) list)) ++ "." ++ options.typeName)
                    )
            in
            CodeGen.Annotation.record (List.indexedMap toNestedLayoutRecordField list)
    in
    ( case options.prefix of
        Just prefix ->
            prefix ++ baseVariantName

        Nothing ->
            baseVariantName
    , [ toLayoutRouteVariantAnnotation ]
    )


{-| A helper function used in custom type variants like `Main.LayoutMsg`,
`Main.LayoutModel`, `Layouts.Layout`, etc. Here are some examples:

    -- `src/Layouts/Sidebar.elm`
    toVariantName layout
        == "Sidebar"

    -- `src/Layouts/Sidebar/WithHeader.elm`
    toVariantName layout
        == "Sidebar__WithHeader"

-}
toVariantName : LayoutFile -> String
toVariantName (LayoutFile list) =
    String.join "__" list

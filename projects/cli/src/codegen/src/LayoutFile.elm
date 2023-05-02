module LayoutFile exposing
    ( LayoutFile, decoder
    , sorter
    , toList
    , toModuleName, toVariantName
    , toLayoutTypeDeclaration
    , toLayoutsModelTypeDeclaration, toLayoutsMsgTypeDeclaration
    , toInitBranches
    , toLastPartFieldName
    , toListOfSelfAndParents
    )

{-|

@docs LayoutFile, decoder
@docs sorter

@docs toList

@docs toModuleName, toVariantName

@docs isNestedLayout, toParentLayoutFiles

@docs toLayoutTypeDeclaration
@docs toLayoutsModelTypeDeclaration, toLayoutsMsgTypeDeclaration

@docs toInitBranches
@docs toLastPartFieldName

-}

import CodeGen
import CodeGen.Annotation
import CodeGen.Argument
import CodeGen.Declaration
import CodeGen.Expression
import Extras.String
import Html.Attributes exposing (target)
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

For example, the layout file at `src/Layouts/Sidebar/Header.elm` would return:

    [ "Sidebar", "Header" ]

-}
toList : LayoutFile -> List String
toList (LayoutFile list) =
    list


{-| Return the Elm module name for this layout:

    -- `src/Layouts/Sidebar.elm`
    toModuleName layout
        == "Layouts.Sidebar"

    -- `src/Layouts/Sidebar/Header.elm`
    toModuleName layout
        == "Layouts.Sidebar.Header"

-}
toModuleName : LayoutFile -> String
toModuleName (LayoutFile list) =
    "Layouts." ++ String.join "." list


{-| Generates the type declaration used in `Layouts.elm`, used with `Page.withLayout`
to select the layout for a given page. Here's an example:

    type Layout
        = Default Layouts.Default.Settings
        | Sidebar Layouts.Sidebar.Settings
        | Sidebar_WithHeader
            { sidebar : Layouts.Sidebar.Settings
            , header : Layouts.Sidebar.Header.Settings
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


{-| Generates the type declaration used in `Main/Layouts/Model.elm` to track the current state of
the active layout. Here's an example:

    type Model
        = Default Layouts.Default.Model
        | Sidebar Layouts.Sidebar.Model
        | Sidebar_WithHeader
            { sidebar : Layouts.Sidebar.Model
            , header : Layouts.Sidebar.Header.Model
            }

-}
toLayoutsModelTypeDeclaration : List LayoutFile -> CodeGen.Declaration
toLayoutsModelTypeDeclaration layouts =
    if List.isEmpty layouts then
        CodeGen.Declaration.typeAlias
            { name = "Model"
            , annotation = CodeGen.Annotation.type_ "Never"
            }

    else
        CodeGen.Declaration.customType
            { name = "Model"
            , variants =
                layouts
                    |> List.map
                        (toLayoutRouteVariant
                            { prefix = Nothing
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
                    ( toVariantName filepath
                    , [ CodeGen.Annotation.type_ (toModuleName filepath ++ ".Msg") ]
                    )
            in
            List.map toCustomType pages
    in
    if List.isEmpty layouts then
        CodeGen.Declaration.typeAlias
            { name = "Msg"
            , annotation = CodeGen.Annotation.type_ "Never"
            }

    else
        CodeGen.Declaration.customType
            { name = "Msg"
            , variants = toLayoutMsgCustomType layouts
            }


{-| Layouts are sorted alphabetically when generated, so that nested layouts
appear near their parents. The order doesn't impact correctness, but it helps folks
reading the generated code.

    List.sortWith sorter [ "Sidebar_WithHeader", "Default", "Sidebar" ]
        == [ "Default"
           , "Sidebar"
           , "Sidebar_WithHeader"
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
            toNestedLayoutRecordAnnotation

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


{-| A helper function used in custom type variants like `Main.Layouts.Msg.Msg`,
`Main.Layouts.Model.Model`, `Layouts.Layout`, etc. Here are some examples:

    -- `src/Layouts/Sidebar.elm`
    toVariantName layout
        == "Sidebar"

    -- `src/Layouts/Sidebar/Header.elm`
    toVariantName layout
        == "Sidebar_WithHeader"

-}
toVariantName : LayoutFile -> String
toVariantName (LayoutFile list) =
    String.join "_" list


isNestedLayout : LayoutFile -> Bool
isNestedLayout (LayoutFile list) =
    List.length list > 1


{-| In order to preserve layout state when switching from one layout to another,
we'll need to reuse any existing `Layout.Model` values, and initialize any we don't
already have state for.

For example, imagine our app has the following layouts:

  - Default
  - Sidebar
  - Sidebar.WithModal
  - Sidebar.Header
  - Sidebar.Header.WithTabs

Because layouts can be nested, we want to make sure that we handle each case correctly:

  - `Sidebar.Header -> Sidebar.WithModal`
      - Preserve the existing `sidebar` model, but initialize a new `withModal` layout state
  - `Sidebar.Header -> Sidebar`
      - Preserve the existing `sidebar` model
  - `Sidebar -> Sidebar.Header`
      - Preserve the existing `sidebar` model, and initialize a new `header` layout state
  - `Default -> Sidebar.WithModal`
      - Because these are two completely different layouts, we'll need to initialize `sidebar` and `withModal`

This is super tedious to handle by hand, so I'm glad we can add this to the framework so things
just work automatically for all Elm Land users!

-}
toInitBranches :
    { target : LayoutFile
    , layouts : List LayoutFile
    }
    -> List CodeGen.Expression.Branch
toInitBranches input =
    let
        {-
           Example: [ "Sidebar", "Header" ]  -> "Sidebar:Header"
        -}
        toStringForComparison : LayoutFile -> String
        toStringForComparison (LayoutFile list) =
            String.join ":" list

        targetAndParents : List LayoutFile
        targetAndParents =
            toListOfSelfAndParents input.target

        isSubset : LayoutFile -> LayoutFile -> Bool
        isSubset targetFile layoutFile =
            String.startsWith
                (toStringForComparison targetFile)
                (toStringForComparison layoutFile)

        foundSubmatchFor : LayoutFile -> Maybe LayoutFile
        foundSubmatchFor layoutFile =
            targetAndParents
                |> List.filter (\existingFile -> isSubset existingFile layoutFile)
                |> List.head

        determineWhatStateCanBeReused : LayoutFile -> Maybe { ifTheExistingModelHas : LayoutFile, weCanReuse : LayoutFile }
        determineWhatStateCanBeReused layoutFile =
            let
                currentString : String
                currentString =
                    toStringForComparison layoutFile
            in
            case foundSubmatchFor layoutFile of
                Just match ->
                    Just { ifTheExistingModelHas = layoutFile, weCanReuse = match }

                Nothing ->
                    Nothing

        targetVariantName : String
        targetVariantName =
            toVariantName input.target

        toBranch : { ifTheExistingModelHas : LayoutFile, weCanReuse : LayoutFile } -> CodeGen.Expression.Branch
        toBranch options =
            { name =
                "( Layouts.{{targetVariantName}} settings, Just (Main.Layouts.Model.{{modelVariantName}} existing) )"
                    |> String.replace "{{targetVariantName}}" targetVariantName
                    |> String.replace "{{modelVariantName}}" (toVariantName options.ifTheExistingModelHas)
            , arguments = []
            , expression =
                toBranchExpression
                    { target = input.target
                    , existing = options.ifTheExistingModelHas
                    , weCanReuse = options.weCanReuse
                    }
            }

        toBranchExpression : { target : LayoutFile, existing : LayoutFile, weCanReuse : LayoutFile } -> CodeGen.Expression
        toBranchExpression { target, existing, weCanReuse } =
            let
                isSubsetOfExisting : Bool
                isSubsetOfExisting =
                    isSubset target existing

                recordMappingAllFromExistingModel : CodeGen.Expression
                recordMappingAllFromExistingModel =
                    CodeGen.Expression.record
                        (toList weCanReuse
                            |> List.map Extras.String.fromPascalCaseToCamelCase
                            |> List.map (\field -> ( field, CodeGen.Expression.value ("existing." ++ field) ))
                        )

                notAvailableForReuse : LayoutFile -> Bool
                notAvailableForReuse layoutFile =
                    not (isSubset layoutFile weCanReuse)

                layoutsNeedingInitialization : List LayoutFile
                layoutsNeedingInitialization =
                    toListOfSelfAndParents target
                        |> List.filter notAvailableForReuse
            in
            if target == existing then
                CodeGen.Expression.multilineTuple
                    [ CodeGen.Expression.function
                        { name = "Main.Layouts.Model.{{targetVariantName}}" |> String.replace "{{targetVariantName}}" targetVariantName
                        , arguments = [ CodeGen.Expression.value "existing" ]
                        }
                    , CodeGen.Expression.value "Cmd.none"
                    ]

            else if isSubsetOfExisting then
                CodeGen.Expression.multilineTuple
                    [ CodeGen.Expression.function
                        { name = "Main.Layouts.Model.{{targetVariantName}}" |> String.replace "{{targetVariantName}}" targetVariantName
                        , arguments = [ recordMappingAllFromExistingModel ]
                        }
                    , CodeGen.Expression.value "Cmd.none"
                    ]

            else
                -- some values can be reused, but not all of them
                toExpressionNeedingToInitializeSomeLayouts
                    { target = target
                    , layoutsNeedingInitialization = layoutsNeedingInitialization
                    , weCanReuse = Just weCanReuse
                    }

        toExpressionNeedingToInitializeSomeLayouts :
            { target : LayoutFile
            , weCanReuse : Maybe LayoutFile
            , layoutsNeedingInitialization : List LayoutFile
            }
            -> CodeGen.Expression.Expression
        toExpressionNeedingToInitializeSomeLayouts options =
            let
                toLetExpression : LayoutFile -> CodeGen.Expression.LetDeclaration
                toLetExpression layoutFile =
                    let
                        lastPartFieldName : String
                        lastPartFieldName =
                            toLastPartFieldName layoutFile
                    in
                    { argument =
                        "( {{lastPartFieldName}}LayoutModel, {{lastPartFieldName}}LayoutEffect )"
                            |> String.replace "{{lastPartFieldName}}" lastPartFieldName
                            |> CodeGen.Argument.new
                    , annotation = Nothing
                    , expression =
                        "Layout.init ({{moduleName}}.layout settings.{{lastPartFieldName}} model.shared route) ()"
                            |> String.replace "{{lastPartFieldName}}" lastPartFieldName
                            |> String.replace "{{moduleName}}" (toModuleName layoutFile)
                            |> CodeGen.Expression.value
                    }

                recordWithPartialMappingFromExisting : CodeGen.Expression
                recordWithPartialMappingFromExisting =
                    let
                        newlyInitializedLayoutModels : List ( String, CodeGen.Expression )
                        newlyInitializedLayoutModels =
                            toList options.target
                                |> (case options.weCanReuse of
                                        Just weCanReuse ->
                                            List.drop (List.length (toList weCanReuse))

                                        Nothing ->
                                            identity
                                   )
                                |> List.map Extras.String.fromPascalCaseToCamelCase
                                |> List.map toRecordField

                        toRecordField : String -> ( String, CodeGen.Expression )
                        toRecordField field =
                            ( field, CodeGen.Expression.value (field ++ "LayoutModel") )
                    in
                    CodeGen.Expression.record
                        ((options.weCanReuse
                            |> Maybe.map toList
                            |> Maybe.withDefault []
                            |> List.map Extras.String.fromPascalCaseToCamelCase
                            |> List.map (\field -> ( field, CodeGen.Expression.value ("existing." ++ field) ))
                         )
                            ++ newlyInitializedLayoutModels
                        )

                toInitialCmds : List LayoutFile -> CodeGen.Expression
                toInitialCmds layoutFiles =
                    case layoutFiles of
                        [] ->
                            CodeGen.Expression.value "Cmd.none"

                        single :: [] ->
                            toInitialLayoutCmd single

                        _ ->
                            CodeGen.Expression.function
                                { name = "Cmd.batch"
                                , arguments = [ CodeGen.Expression.multilineList (List.map toInitialLayoutCmd layoutFiles) ]
                                }

                toInitialLayoutCmd : LayoutFile -> CodeGen.Expression
                toInitialLayoutCmd layoutFile =
                    "fromLayoutEffect model (Effect.map Main.Layouts.Msg.{{variantName}} {{lastPartFieldName}}LayoutEffect)"
                        |> String.replace "{{variantName}}" (toVariantName layoutFile)
                        |> String.replace "{{lastPartFieldName}}" (toLastPartFieldName layoutFile)
                        |> CodeGen.Expression.value
            in
            CodeGen.Expression.letIn
                { let_ =
                    List.concat
                        [ [ { argument = CodeGen.Argument.new "route"
                            , annotation = Just (CodeGen.Annotation.type_ "Route ()")
                            , expression = CodeGen.Expression.value "Route.fromUrl () model.url"
                            }
                          ]
                        , options.layoutsNeedingInitialization |> List.map toLetExpression
                        ]
                , in_ =
                    CodeGen.Expression.multilineTuple
                        [ CodeGen.Expression.function
                            { name = "Main.Layouts.Model.{{targetVariantName}}" |> String.replace "{{targetVariantName}}" targetVariantName
                            , arguments =
                                [ recordWithPartialMappingFromExisting
                                ]
                            }
                        , toInitialCmds options.layoutsNeedingInitialization
                        ]
                }

        defaultBranch : CodeGen.Expression.Branch
        defaultBranch =
            { name =
                "( Layouts.{{targetVariantName}} settings, _ )"
                    |> String.replace "{{targetVariantName}}" targetVariantName
            , arguments = []
            , expression =
                toExpressionNeedingToInitializeSomeLayouts
                    { target = input.target
                    , layoutsNeedingInitialization = targetAndParents
                    , weCanReuse = Nothing
                    }
            }
    in
    (input.layouts
        |> List.filterMap determineWhatStateCanBeReused
        |> List.map toBranch
    )
        ++ [ defaultBranch ]


{-| Enumerate all subsets of the target layout:

    toListOfSelfAndParents (LayoutFile [ "Sidebar", "Header" ])
        == [ LayoutFile [ "Sidebar", "Header" ]
           , LayoutFile [ "Sidebar" ]
           ]

-}
toListOfSelfAndParents : LayoutFile -> List LayoutFile
toListOfSelfAndParents (LayoutFile list) =
    List.range 0 (List.length list - 1)
        |> List.foldr (\offset layoutFiles -> LayoutFile (dropRight offset list) :: layoutFiles) []


dropRight : Int -> List a -> List a
dropRight amount list =
    List.reverse list
        |> List.drop amount
        |> List.reverse


toLastPartFieldName : LayoutFile -> String
toLastPartFieldName (LayoutFile list) =
    case List.reverse list of
        [] ->
            "unknown"

        first :: _ ->
            Extras.String.fromPascalCaseToCamelCase first

module LayoutFile exposing
    ( LayoutFile, decoder
    , sorter
    , toList
    , toModuleName, toVariantName
    , toLayoutTypeDeclaration
    , toLayoutsModelTypeDeclaration, toLayoutsMsgTypeDeclaration
    , toInitBranches
    , toLayoutVariableName, toLastPartFieldName
    , toLastPartFieldNameFilepath, toListOfSelfAndParents, toMapFunction, toModuleNameFilepath, toVariantNameFilepath
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
@docs toLayoutVariableName, toLastPartFieldName

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
    = LayoutFile
        { filepath : List String
        , isUsingTypeVariable : Bool
        }


{-| Attempts to convert a raw JSON array of strings into a `LayoutFile`
-}
decoder : Json.Decode.Decoder LayoutFile
decoder =
    Json.Decode.map
        (\filepath ->
            LayoutFile
                { filepath = filepath
                , isUsingTypeVariable = False --|> Debug.log "TODO: Learn if parent is using type variable"
                }
        )
        (Json.Decode.list Json.Decode.string)


{-| Returns a list of filepath segments.

For example, the layout file at `src/Layouts/Sidebar/Header.elm` would return:

    [ "Sidebar", "Header" ]

-}
toList : LayoutFile -> List String
toList (LayoutFile { filepath }) =
    filepath


{-| Return the Elm module name for this layout:

    -- `src/Layouts/Sidebar.elm`
    toModuleName layout
        == "Layouts.Sidebar"

    -- `src/Layouts/Sidebar/Header.elm`
    toModuleName layout
        == "Layouts.Sidebar.Header"

-}
toModuleName : LayoutFile -> String
toModuleName (LayoutFile { filepath }) =
    toModuleNameFilepath filepath


toModuleNameFilepath : Filepath -> String
toModuleNameFilepath filepath =
    "Layouts." ++ String.join "." filepath


{-| Generates the type declaration used in `Layouts.elm`, used with `Page.withLayout`
to select the layout for a given page. Here's an example:

    type Layout msg
        = Default Layouts.Default.Settings
        | Sidebar Layouts.Sidebar.Settings
        | Sidebar_Header (Layouts.Sidebar.Header.Settings msg)

-}
toLayoutTypeDeclaration : List LayoutFile -> CodeGen.Declaration
toLayoutTypeDeclaration layouts =
    if List.isEmpty layouts then
        CodeGen.Declaration.customType
            { name = "Layout msg"
            , variants =
                [ ( "None", [] )
                ]
            }

    else
        let
            toLayoutVariant : LayoutFile -> ( String, List CodeGen.Annotation )
            toLayoutVariant (LayoutFile { filepath }) =
                ( String.join "_" filepath
                , [ CodeGen.Annotation.type_ ("Layouts." ++ String.join "." filepath ++ ".Settings") ]
                )
        in
        CodeGen.Declaration.customType
            { name = "Layout msg"
            , variants =
                layouts
                    |> List.map toLayoutVariant
            }


toMapFunction : List LayoutFile -> CodeGen.Declaration
toMapFunction layouts =
    let
        toBranch :
            LayoutFile
            ->
                { name : String
                , arguments : List CodeGen.Argument.Argument
                , expression : CodeGen.Expression
                }
        toBranch (LayoutFile { filepath, isUsingTypeVariable }) =
            if isUsingTypeVariable then
                { name = String.join "_" filepath
                , arguments = [ CodeGen.Argument.new "data" ]
                , expression = CodeGen.Expression.value (String.join "_" filepath ++ " data")
                }

            else
                { name = String.join "_" filepath
                , arguments = [ CodeGen.Argument.new "data" ]
                , expression = CodeGen.Expression.value (String.join "_" filepath ++ " data")
                }
    in
    CodeGen.Declaration.function
        { name = "map"
        , annotation = CodeGen.Annotation.type_ "(msg1 -> msg2) -> Layout msg1 -> Layout msg2"
        , arguments = [ CodeGen.Argument.new "fn", CodeGen.Argument.new "layout" ]
        , expression =
            if List.isEmpty layouts then
                CodeGen.Expression.value "None"

            else
                CodeGen.Expression.caseExpression
                    { value = CodeGen.Argument.new "layout"
                    , branches =
                        List.map toBranch layouts
                    }
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
sorter (LayoutFile layout1) (LayoutFile layout2) =
    Basics.compare
        (String.join "_" layout1.filepath)
        (String.join "_" layout2.filepath)



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
        (LayoutFile { filepath }) =
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
                    , CodeGen.Annotation.type_
                        ("Layouts."
                            ++ (filepath
                                    |> dropRight (List.length filepath - index - 1)
                                    |> String.join "."
                               )
                            ++ "."
                            ++ options.typeName
                        )
                    )
            in
            CodeGen.Annotation.record (List.indexedMap toNestedLayoutRecordField filepath)
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
toVariantName (LayoutFile { filepath }) =
    toVariantNameFilepath filepath


toVariantNameFilepath : Filepath -> String
toVariantNameFilepath filepath =
    String.join "_" filepath


isNestedLayout : LayoutFile -> Bool
isNestedLayout (LayoutFile { filepath }) =
    List.length filepath > 1


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
        toStringForComparison (LayoutFile { filepath }) =
            String.join ":" filepath

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
                toLayoutDefinition : LayoutFile -> Maybe LayoutFile -> CodeGen.Expression.LetDeclaration
                toLayoutDefinition current parent =
                    { argument =
                        toLayoutVariableName current
                            |> withSuffix "Layout"
                            |> CodeGen.Argument.new
                    , annotation = Nothing
                    , expression =
                        "{{layoutName}}.layout {{settings}} model.shared route"
                            |> String.replace "{{layoutName}}" (toModuleName current)
                            |> String.replace "{{settings}}"
                                (case parent of
                                    Just parentLayout ->
                                        "(Layout.parentSettings {{parentLayoutName}})"
                                            |> String.replace "{{parentLayoutName}}"
                                                (toLayoutVariableName parentLayout
                                                    |> withSuffix "Layout"
                                                )

                                    Nothing ->
                                        "settings"
                                )
                            |> CodeGen.Expression.value
                    }

                toLayoutInitialization : LayoutFile -> CodeGen.Expression.LetDeclaration
                toLayoutInitialization layoutFile =
                    { argument =
                        "( {{lastPartName}}LayoutModel, {{lastPartName}}LayoutEffect )"
                            |> String.replace "{{lastPartName}}" (toLastPartFieldName layoutFile)
                            |> CodeGen.Argument.new
                    , annotation = Nothing
                    , expression =
                        "Layout.init {{layoutName}}Layout ()"
                            |> String.replace "{{layoutName}}" (toLayoutVariableName layoutFile)
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
                    "fromLayoutEffect model (Effect.map Main.Layouts.Msg.{{variantName}} {{lastPartName}}LayoutEffect)"
                        |> String.replace "{{variantName}}" (toVariantName layoutFile)
                        |> String.replace "{{lastPartName}}" (toLastPartFieldName layoutFile)
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
                        , List.map2 toLayoutDefinition
                            options.layoutsNeedingInitialization
                            (Nothing
                                :: (options.layoutsNeedingInitialization
                                        |> List.reverse
                                        |> List.drop 1
                                        |> List.reverse
                                        |> List.map Just
                                   )
                            )
                        , options.layoutsNeedingInitialization |> List.map toLayoutInitialization
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


type alias Filepath =
    List String


{-| Enumerate all subsets of the target layout:

    toListOfSelfAndParents (LayoutFile [ "Sidebar", "Header" ])
        == [ LayoutFile [ "Sidebar", "Header" ]
           , LayoutFile [ "Sidebar" ]
           ]

-}
toListOfSelfAndParents : LayoutFile -> List LayoutFile
toListOfSelfAndParents (LayoutFile { filepath }) =
    List.range 0 (List.length filepath - 1)
        |> List.foldr
            (\offset layoutFiles ->
                LayoutFile
                    { filepath = dropRight offset filepath
                    , isUsingTypeVariable = False --|> Debug.log "TODO: Learn if parent is using type variable"
                    }
                    :: layoutFiles
            )
            []


dropRight : Int -> List a -> List a
dropRight amount list =
    List.reverse list
        |> List.drop amount
        |> List.reverse


{-|

    toLayoutVariableName Layouts.Sidebar
        == "sidebar"

    toLayoutVariableName Layouts.Sidebar.Header
        == "sidebarHeader"

-}
toLayoutVariableName : LayoutFile -> String
toLayoutVariableName (LayoutFile { filepath }) =
    toLayoutName filepath


withSuffix : String -> String -> String
withSuffix suffix base =
    base ++ suffix


toLayoutName : Filepath -> String
toLayoutName filepath =
    case filepath of
        [] ->
            "unknown"

        first :: rest ->
            String.join "" (Extras.String.fromPascalCaseToCamelCase first :: rest)


{-| Create a camel case variable name (used for layout model record
fields names).

    toLastPartFieldName Layouts.Sidebar
        == "sidebar"

    toLastPartFieldName Layouts.Sidebar.Header
        == "header"

-}
toLastPartFieldName : LayoutFile -> String
toLastPartFieldName (LayoutFile { filepath }) =
    toLastPartFieldNameFilepath filepath


toLastPartFieldNameFilepath : Filepath -> String
toLastPartFieldNameFilepath filepath =
    case List.reverse filepath of
        [] ->
            "unknown"

        first :: _ ->
            Extras.String.fromPascalCaseToCamelCase first

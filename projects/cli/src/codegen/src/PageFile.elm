module PageFile exposing
    ( PageFile
    , decoder
    , hasDynamicParameters
    , isAdvancedElmLandPage
    , isAuthProtectedPage
    , isNotFoundPage
    , isSandboxOrElementElmLandPage
    , toLayoutName
    , toList
    , toModuleName
    , toPageModelTypeDeclaration
    , toParamsRecordAnnotation
    , toRouteVariant
    , toUrlParser
    , toVariantName
    )

import CodeGen
import CodeGen.Annotation
import CodeGen.Argument
import CodeGen.Declaration
import CodeGen.Expression
import Elm.Parser
import Elm.Processing
import Elm.RawFile
import Elm.Syntax.Declaration
import Elm.Syntax.Exposing
import Elm.Syntax.Expression
import Elm.Syntax.File
import Elm.Syntax.Module
import Elm.Syntax.ModuleName
import Elm.Syntax.Node
import Elm.Syntax.Signature
import Elm.Syntax.TypeAnnotation
import Extras.String
import Json.Decode


type PageFile
    = PageFile Internals


type alias Internals =
    { filepath : List String
    , contents : String
    }


decoder : Json.Decode.Decoder PageFile
decoder =
    Json.Decode.map PageFile
        (Json.Decode.map2 Internals
            (Json.Decode.field "filepath" (Json.Decode.list Json.Decode.string))
            (Json.Decode.oneOf
                [ Json.Decode.field "contents" Json.Decode.string
                , Json.Decode.succeed ""
                ]
            )
        )


toLayoutName : PageFile -> Maybe String
toLayoutName (PageFile { contents }) =
    let
        toLayoutNameFromFile : Elm.Syntax.File.File -> Maybe String
        toLayoutNameFromFile file =
            file.declarations
                |> List.map Elm.Syntax.Node.value
                |> List.filterMap toLayoutNameFromDeclaration
                |> List.head

        toLayoutNameFromDeclaration : Elm.Syntax.Declaration.Declaration -> Maybe String
        toLayoutNameFromDeclaration decl =
            case decl of
                Elm.Syntax.Declaration.FunctionDeclaration func ->
                    toLayoutNameFromFunction func

                _ ->
                    Nothing

        toLayoutNameFromFunction : Elm.Syntax.Expression.Function -> Maybe String
        toLayoutNameFromFunction func =
            let
                functionName : String
                functionName =
                    func.declaration
                        |> Elm.Syntax.Node.value
                        |> .name
                        |> Elm.Syntax.Node.value

                expression : Elm.Syntax.Expression.Expression
                expression =
                    Elm.Syntax.Node.value (Elm.Syntax.Node.value func.declaration).expression
            in
            if functionName == "layout" then
                case expression of
                    Elm.Syntax.Expression.FunctionOrValue [ "Layout" ] name ->
                        Just name

                    _ ->
                        Nothing

            else
                Nothing
    in
    contents
        |> Elm.Parser.parse
        |> Result.map (Elm.Processing.process Elm.Processing.init)
        |> Result.toMaybe
        |> Maybe.andThen toLayoutNameFromFile


isSandboxOrElementElmLandPage : PageFile -> Bool
isSandboxOrElementElmLandPage (PageFile { contents }) =
    let
        isElmLandPageFromFile : Elm.Syntax.File.File -> Bool
        isElmLandPageFromFile file =
            file.declarations
                |> List.map Elm.Syntax.Node.value
                |> List.any isElmLandPageFromDeclaration

        isElmLandPageFromDeclaration : Elm.Syntax.Declaration.Declaration -> Bool
        isElmLandPageFromDeclaration decl =
            case decl of
                Elm.Syntax.Declaration.FunctionDeclaration func ->
                    isElmLandPageFromFunction func

                _ ->
                    False

        isElmLandPageFromFunction : Elm.Syntax.Expression.Function -> Bool
        isElmLandPageFromFunction func =
            let
                functionName : String
                functionName =
                    func.declaration
                        |> Elm.Syntax.Node.value
                        |> .name
                        |> Elm.Syntax.Node.value

                expression : Elm.Syntax.Expression.Expression
                expression =
                    Elm.Syntax.Node.value (Elm.Syntax.Node.value func.declaration).expression
            in
            if functionName == "page" then
                expressionCouldReturn [ "Page" ] "sandbox" expression
                    || expressionCouldReturn [ "Page" ] "element" expression

            else
                False
    in
    contents
        |> Elm.Parser.parse
        |> Result.map (Elm.Processing.process Elm.Processing.init)
        |> Result.toMaybe
        |> Maybe.map isElmLandPageFromFile
        |> Maybe.withDefault False


isAdvancedElmLandPage : PageFile -> Bool
isAdvancedElmLandPage (PageFile { contents }) =
    let
        isElmLandPageFromFile : Elm.Syntax.File.File -> Bool
        isElmLandPageFromFile file =
            file.declarations
                |> List.map Elm.Syntax.Node.value
                |> List.any isElmLandPageFromDeclaration

        isElmLandPageFromDeclaration : Elm.Syntax.Declaration.Declaration -> Bool
        isElmLandPageFromDeclaration decl =
            case decl of
                Elm.Syntax.Declaration.FunctionDeclaration func ->
                    isElmLandPageFromFunction func

                _ ->
                    False

        isElmLandPageFromFunction : Elm.Syntax.Expression.Function -> Bool
        isElmLandPageFromFunction func =
            let
                functionName : String
                functionName =
                    func.declaration
                        |> Elm.Syntax.Node.value
                        |> .name
                        |> Elm.Syntax.Node.value

                expression : Elm.Syntax.Expression.Expression
                expression =
                    Elm.Syntax.Node.value (Elm.Syntax.Node.value func.declaration).expression
            in
            if functionName == "page" then
                expressionCouldReturn [ "Page" ] "new" expression

            else
                False
    in
    contents
        |> Elm.Parser.parse
        |> Result.map (Elm.Processing.process Elm.Processing.init)
        |> Result.toMaybe
        |> Maybe.map isElmLandPageFromFile
        |> Maybe.withDefault False


{-| Elm Land detects if you are using "Page.new", "Page.sandbox", or regular "Html" to
reduce the impact of the learning curve.

Beginners should see this signature:

    page : Html msg
    page =
        ...

While folks learning about state or side effects should see this signature:

    page : Page Model Msg
    page =
        ...

Only when they understand the basic building blocks will they see all of this:

    page : Shared.Model -> Route () -> Page Model Msg
    page =
        ...

This function recursively searches the expression for their "page" function, because they might
need to use a `let/in` expression, conditional, or use pipelines / function application to
provide a `Page.withLayout` around the `Page.new`

-}
expressionCouldReturn : List String -> String -> Elm.Syntax.Expression.Expression -> Bool
expressionCouldReturn modulePath functionName expression =
    case expression of
        Elm.Syntax.Expression.UnitExpr ->
            False

        Elm.Syntax.Expression.Application nodes ->
            --(List (Node Expression)) ->
            nodes
                |> List.map Elm.Syntax.Node.value
                |> List.any (expressionCouldReturn modulePath functionName)

        Elm.Syntax.Expression.OperatorApplication _ _ left right ->
            -- String InfixDirection (Node Expression) (Node Expression) ->
            [ left, right ]
                |> List.map Elm.Syntax.Node.value
                |> List.any (expressionCouldReturn modulePath functionName)

        Elm.Syntax.Expression.FunctionOrValue foundModulePath foundFunctionName ->
            --ModuleName String ->
            foundModulePath == modulePath && foundFunctionName == functionName

        Elm.Syntax.Expression.IfBlock _ whenTrue whenFalse ->
            [ whenTrue, whenFalse ]
                |> List.map Elm.Syntax.Node.value
                |> List.any (expressionCouldReturn modulePath functionName)

        Elm.Syntax.Expression.PrefixOperator _ ->
            False

        Elm.Syntax.Expression.Operator _ ->
            False

        Elm.Syntax.Expression.Integer _ ->
            False

        Elm.Syntax.Expression.Hex _ ->
            False

        Elm.Syntax.Expression.Floatable _ ->
            False

        Elm.Syntax.Expression.Negation node ->
            False

        Elm.Syntax.Expression.Literal _ ->
            False

        Elm.Syntax.Expression.CharLiteral _ ->
            False

        Elm.Syntax.Expression.TupledExpression nodes ->
            nodes
                |> List.map Elm.Syntax.Node.value
                |> List.any (expressionCouldReturn modulePath functionName)

        Elm.Syntax.Expression.ParenthesizedExpression node ->
            node
                |> Elm.Syntax.Node.value
                |> expressionCouldReturn modulePath functionName

        Elm.Syntax.Expression.LetExpression letInBlock ->
            letInBlock.expression
                :: List.map fromLetDeclarationToExpression letInBlock.declarations
                |> List.map Elm.Syntax.Node.value
                |> List.any (expressionCouldReturn modulePath functionName)

        Elm.Syntax.Expression.CaseExpression caseBlock ->
            caseBlock.cases
                |> List.map Tuple.second
                |> List.map Elm.Syntax.Node.value
                |> List.any (expressionCouldReturn modulePath functionName)

        Elm.Syntax.Expression.LambdaExpression lambda ->
            lambda.expression
                |> Elm.Syntax.Node.value
                |> expressionCouldReturn modulePath functionName

        Elm.Syntax.Expression.RecordExpr _ ->
            False

        Elm.Syntax.Expression.ListExpr nodes ->
            False

        Elm.Syntax.Expression.RecordAccess node _ ->
            False

        Elm.Syntax.Expression.RecordAccessFunction _ ->
            False

        Elm.Syntax.Expression.RecordUpdateExpression _ _ ->
            False

        Elm.Syntax.Expression.GLSLExpression _ ->
            False


fromLetDeclarationToExpression :
    Elm.Syntax.Node.Node Elm.Syntax.Expression.LetDeclaration
    -> Elm.Syntax.Node.Node Elm.Syntax.Expression.Expression
fromLetDeclarationToExpression letDeclarationNode =
    case Elm.Syntax.Node.value letDeclarationNode of
        Elm.Syntax.Expression.LetFunction function ->
            fromFunctionToExpression function

        Elm.Syntax.Expression.LetDestructuring _ node ->
            node


fromFunctionToExpression :
    Elm.Syntax.Expression.Function
    -> Elm.Syntax.Node.Node Elm.Syntax.Expression.Expression
fromFunctionToExpression function =
    function.declaration
        |> Elm.Syntax.Node.value
        |> .expression


isAuthProtectedPage : PageFile -> Bool
isAuthProtectedPage (PageFile { contents }) =
    let
        isElmLandPageFromFile : Elm.Syntax.File.File -> Bool
        isElmLandPageFromFile file =
            file.declarations
                |> List.map Elm.Syntax.Node.value
                |> List.any isElmLandPageFromDeclaration

        isElmLandPageFromDeclaration : Elm.Syntax.Declaration.Declaration -> Bool
        isElmLandPageFromDeclaration decl =
            case decl of
                Elm.Syntax.Declaration.FunctionDeclaration func ->
                    isElmLandPageFromFunction func

                _ ->
                    False

        isElmLandPageFromFunction : Elm.Syntax.Expression.Function -> Bool
        isElmLandPageFromFunction func =
            let
                functionName : String
                functionName =
                    func.declaration
                        |> Elm.Syntax.Node.value
                        |> .name
                        |> Elm.Syntax.Node.value
            in
            if functionName == "page" then
                case func.signature of
                    Just node ->
                        let
                            functionTypeAnnotation : Elm.Syntax.TypeAnnotation.TypeAnnotation
                            functionTypeAnnotation =
                                Elm.Syntax.Node.value node
                                    |> .typeAnnotation
                                    |> Elm.Syntax.Node.value
                        in
                        case functionTypeAnnotation of
                            Elm.Syntax.TypeAnnotation.FunctionTypeAnnotation functionNode _ ->
                                let
                                    typeAnnotation : Elm.Syntax.TypeAnnotation.TypeAnnotation
                                    typeAnnotation =
                                        functionNode
                                            |> Elm.Syntax.Node.value
                                in
                                case typeAnnotation of
                                    Elm.Syntax.TypeAnnotation.Typed node1 _ ->
                                        Elm.Syntax.Node.value node1 == ( [ "Auth" ], "User" )

                                    _ ->
                                        False

                            _ ->
                                False

                    Nothing ->
                        False

            else
                False
    in
    contents
        |> Elm.Parser.parse
        |> Result.map (Elm.Processing.process Elm.Processing.init)
        |> Result.toMaybe
        |> Maybe.map isElmLandPageFromFile
        |> Maybe.withDefault False


toPageModelTypeDeclaration : List PageFile -> CodeGen.Declaration
toPageModelTypeDeclaration pages =
    let
        toPageModelCustomType : List ( String, List CodeGen.Annotation )
        toPageModelCustomType =
            let
                toCustomType : PageFile -> ( String, List CodeGen.Annotation.Annotation )
                toCustomType page =
                    ( "PageModel" ++ toVariantName page
                    , List.concat
                        [ if hasDynamicParameters page then
                            [ toParamsRecordAnnotation page ]

                          else
                            []
                        , if isSandboxOrElementElmLandPage page || isAdvancedElmLandPage page then
                            [ CodeGen.Annotation.type_ (toModuleName page ++ ".Model")
                            ]

                          else
                            []
                        ]
                    )
            in
            List.concat
                [ List.map toCustomType pages
                , [ ( "PageModelNotFound_", [] )
                  , ( "Redirecting", [] )
                  , ( "Loading", [ CodeGen.Annotation.type_ "(View Never)" ] )
                  ]
                ]
    in
    CodeGen.Declaration.customType
        { name = "PageModel"
        , variants = toPageModelCustomType
        }


isNotFoundPage : PageFile -> Bool
isNotFoundPage (PageFile { filepath }) =
    filepath == [ "NotFound_" ]


hasDynamicParameters : PageFile -> Bool
hasDynamicParameters page =
    not (List.isEmpty (toDynamicParameterList page))


toDynamicParameterList : PageFile -> List String
toDynamicParameterList (PageFile { filepath }) =
    List.filter
        (\piece ->
            not (List.member piece [ "Home_", "NotFound_" ])
                && String.endsWith "_" piece
        )
        filepath


toList : PageFile -> List String
toList (PageFile { filepath }) =
    if List.isEmpty filepath then
        [ "Home_" ]

    else
        filepath


toParamsRecordAnnotation : PageFile -> CodeGen.Annotation
toParamsRecordAnnotation (PageFile { filepath }) =
    filepath
        |> List.filter (String.endsWith "_")
        |> List.map (String.dropRight 1)
        |> List.map Extras.String.fromPascalCaseToCamelCase
        |> List.map (\fieldName -> ( fieldName, CodeGen.Annotation.string ))
        |> CodeGen.Annotation.record


toVariantName : PageFile -> String
toVariantName (PageFile { filepath }) =
    String.join "__" filepath


toRouteVariant : PageFile -> ( String, List CodeGen.Annotation )
toRouteVariant page =
    ( toVariantName page
    , if hasDynamicParameters page then
        [ toParamsRecordAnnotation page ]

      else
        []
    )


toUrlParser : PageFile -> CodeGen.Expression
toUrlParser ((PageFile { filepath }) as page) =
    case filepath of
        [ "Home_" ] ->
            CodeGen.Expression.function
                { name = "Url.Parser.map"
                , arguments =
                    [ CodeGen.Expression.value "Home_"
                    , CodeGen.Expression.value "Url.Parser.top"
                    ]
                }

        _ ->
            let
                paramNameForIndex : Int -> String
                paramNameForIndex i =
                    "param" ++ String.fromInt (i + 1)

                constructorExpression : CodeGen.Expression
                constructorExpression =
                    if hasDynamicParameters page then
                        CodeGen.Expression.lambda
                            { arguments =
                                toDynamicParameterList page
                                    |> List.indexedMap (\i _ -> CodeGen.Argument.new (paramNameForIndex i))
                            , expression =
                                CodeGen.Expression.function
                                    { name = toVariantName page
                                    , arguments =
                                        [ CodeGen.Expression.record
                                            (toDynamicParameterList page
                                                |> List.indexedMap
                                                    (\i name ->
                                                        ( name
                                                            |> String.dropRight 1
                                                            |> Extras.String.fromPascalCaseToCamelCase
                                                        , CodeGen.Expression.value (paramNameForIndex i)
                                                        )
                                                    )
                                            )
                                        ]
                                    }
                            }

                    else
                        CodeGen.Expression.value (toVariantName page)

                toUrlParserList : List CodeGen.Expression
                toUrlParserList =
                    filepath
                        |> List.map
                            (\piece ->
                                if String.endsWith "_" piece then
                                    [ CodeGen.Expression.value "Url.Parser.string" ]

                                else
                                    [ CodeGen.Expression.value "Url.Parser.s"
                                    , CodeGen.Expression.string (Extras.String.fromPascalCaseToKebabCase piece)
                                    ]
                            )
                        |> List.intersperse [ CodeGen.Expression.operator "</>" ]
                        |> List.concat
            in
            CodeGen.Expression.function
                { name = "Url.Parser.map"
                , arguments =
                    [ constructorExpression
                    , CodeGen.Expression.parens toUrlParserList
                    ]
                }


toModuleName : PageFile -> String
toModuleName (PageFile { filepath }) =
    if List.isEmpty filepath then
        "Pages.Home_"

    else
        "Pages." ++ String.join "." filepath

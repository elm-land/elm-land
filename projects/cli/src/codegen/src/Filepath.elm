module Filepath exposing
    ( Filepath
    , decoder
    , hasDynamicParameters
    , isNotFoundPage
    , toLayoutModuleName
    , toLayoutRouteVariant
    , toList
    , toPageModuleName
    , toParamsRecordAnnotation
    , toRouteVariant
    , toRouteVariantName
    , toUrlParser
    )

import CodeGen
import CodeGen.Annotation
import CodeGen.Argument
import CodeGen.Expression
import Extras.String
import Json.Decode


type Filepath
    = Filepath (List String)


decoder : Json.Decode.Decoder Filepath
decoder =
    Json.Decode.map Filepath
        (Json.Decode.list Json.Decode.string)


isNotFoundPage : Filepath -> Bool
isNotFoundPage (Filepath list) =
    list == [ "NotFound_" ]


hasDynamicParameters : Filepath -> Bool
hasDynamicParameters filepath =
    not (List.isEmpty (toDynamicParameterList filepath))


toDynamicParameterList : Filepath -> List String
toDynamicParameterList (Filepath list) =
    List.filter
        (\piece ->
            not (List.member piece [ "Home_", "NotFound_" ])
                && String.endsWith "_" piece
        )
        list


toList : Filepath -> List String
toList (Filepath list) =
    if List.isEmpty list then
        [ "Home_" ]

    else
        list


toParamsRecordAnnotation : Filepath -> CodeGen.Annotation
toParamsRecordAnnotation (Filepath list) =
    list
        |> List.filter (String.endsWith "_")
        |> List.map (String.dropRight 1)
        |> List.map Extras.String.fromPascalCaseToCamelCase
        |> List.map (\fieldName -> ( fieldName, CodeGen.Annotation.string ))
        |> CodeGen.Annotation.record


toRouteVariantName : Filepath -> String
toRouteVariantName (Filepath list) =
    String.join "__" list


toRouteVariant : Filepath -> ( String, List CodeGen.Annotation )
toRouteVariant filepath =
    ( toRouteVariantName filepath
    , if hasDynamicParameters filepath then
        [ toParamsRecordAnnotation filepath ]

      else
        []
    )


toUrlParser : Filepath -> CodeGen.Expression
toUrlParser ((Filepath list) as filepath) =
    case list of
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
                    if hasDynamicParameters filepath then
                        CodeGen.Expression.lambda
                            { arguments =
                                toDynamicParameterList filepath
                                    |> List.indexedMap (\i _ -> CodeGen.Argument.new (paramNameForIndex i))
                            , expression =
                                CodeGen.Expression.function
                                    { name = toRouteVariantName filepath
                                    , arguments =
                                        [ CodeGen.Expression.record
                                            (toDynamicParameterList filepath
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
                        CodeGen.Expression.value (toRouteVariantName filepath)

                toUrlParserList : List CodeGen.Expression
                toUrlParserList =
                    list
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


toPageModuleName : Filepath -> String
toPageModuleName (Filepath list) =
    if List.isEmpty list then
        "Pages.Home_"

    else
        "Pages." ++ String.join "." list


toLayoutModuleName : Filepath -> String
toLayoutModuleName (Filepath list) =
    "Layouts." ++ String.join "." list


toLayoutRouteVariant : Filepath -> ( String, List CodeGen.Annotation )
toLayoutRouteVariant filepath =
    ( toRouteVariantName filepath
    , [ CodeGen.Annotation.type_ (toLayoutModuleName filepath ++ ".Settings")
      ]
    )

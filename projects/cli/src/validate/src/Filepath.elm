module Filepath exposing
    ( Filepath, decoder, fromList
    , toRelativeFilepath, toModuleName
    , toParentLayoutModuleName, toRouteParamsRecordString
    )

{-|

@docs Filepath, decoder, fromList
@docs toRelativeFilepath, toModuleName

-}

import CodeGen
import CodeGen.Annotation
import Json.Decode


type Filepath
    = Filepath ( String, List String )


fromList : ( String, List String ) -> Filepath
fromList =
    Filepath


{-| Create a Filepath from a JSON response. Expects a list of strings

    Json """ [ "Pages", "Home_"] """ == Ok Filepath

-}
decoder : { folder : String } -> Json.Decode.Decoder Filepath
decoder options =
    Json.Decode.list Json.Decode.string
        |> Json.Decode.andThen
            (\filepathStrings ->
                case filepathStrings of
                    [] ->
                        Json.Decode.fail "Filepath cannot be empty"

                    _ ->
                        Json.Decode.succeed
                            (Filepath ( options.folder, filepathStrings ))
            )


{-|

    Filepath [ "Pages", "Home_" ]
        |> toRelativeFilepath
        == "src/Pages/Home_.elm"

-}
toRelativeFilepath : Filepath -> String
toRelativeFilepath (Filepath ( first, rest )) =
    "src/" ++ String.join "/" (first :: rest) ++ ".elm"


{-|

    Filepath [ "Pages", "Home_" ]
        |> toModuleName
        == "Pages.Home_"

-}
toModuleName : Filepath -> String
toModuleName (Filepath ( first, rest )) =
    String.join "." (first :: rest)


{-| Copied implementation from `PageFile`, but I shouldn't have!
-}
toRouteParamsRecordString : Filepath -> String
toRouteParamsRecordString (Filepath ( first, rest )) =
    let
        filepath : List String
        filepath =
            first :: rest

        isCatchAllRoute : Bool
        isCatchAllRoute =
            filepath
                |> String.join "/"
                |> String.endsWith "ALL_"

        addConditionalCatchAllParameters : List ( String, CodeGen.Annotation ) -> List ( String, CodeGen.Annotation )
        addConditionalCatchAllParameters fields =
            if isCatchAllRoute then
                fields
                    ++ [ ( "all_"
                         , CodeGen.Annotation.type_ "List String"
                         )
                       ]

            else
                fields

        isDynamic : String -> Bool
        isDynamic str =
            str /= "ALL_" && str /= "NotFound_" && String.endsWith "_" str

        hasNoDynamicSegments : Bool
        hasNoDynamicSegments =
            filepath
                |> List.filter (\str -> str == "ALL_" || isDynamic str)
                |> List.isEmpty
    in
    case filepath of
        [ _, "Home_" ] ->
            "()"

        _ ->
            if hasNoDynamicSegments then
                "()"

            else
                filepath
                    |> List.filter isDynamic
                    |> List.map (String.dropRight 1)
                    |> List.map fromPascalCaseToCamelCase
                    |> List.map
                        (\fieldName ->
                            if fieldName == "all_" then
                                ( "all_", CodeGen.Annotation.type_ "List String" )

                            else
                                ( fieldName, CodeGen.Annotation.string )
                        )
                    |> addConditionalCatchAllParameters
                    |> CodeGen.Annotation.record
                    |> CodeGen.Annotation.toString


{-| Stolen from `Extras.String`
-}
fromPascalCaseToCamelCase : String -> String
fromPascalCaseToCamelCase str =
    case String.toList str of
        [] ->
            ""

        firstChar :: restChars ->
            String.fromList (Char.toLower firstChar :: restChars)


{-|

    toParentLayoutModuleName "Layouts.Sidebar" == Nothing

    toParentLayoutModuleName "Layouts.Sidebar.Header" == Just "Layouts.Sidebar"

-}
toParentLayoutModuleName : Filepath -> Maybe String
toParentLayoutModuleName filepath =
    case toModuleName filepath |> String.split "." of
        [] ->
            Nothing

        _ :: [] ->
            Nothing

        _ :: _ :: [] ->
            Nothing

        segments ->
            segments
                |> List.reverse
                |> List.drop 1
                |> List.reverse
                |> String.join "."
                |> Just

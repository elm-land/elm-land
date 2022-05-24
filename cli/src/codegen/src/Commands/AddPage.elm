module Commands.AddPage exposing (run)

import CodeGen
import CodeGen.Annotation
import CodeGen.Argument
import CodeGen.Declaration
import CodeGen.Expression
import CodeGen.Import
import CodeGen.Module
import Extras.String
import Filepath exposing (Filepath)
import Json.Decode


run : Json.Decode.Value -> List CodeGen.Module
run json =
    case Json.Decode.decodeValue decoder json of
        Ok data ->
            [ newPageModule data ]

        Err _ ->
            []


type alias Data =
    { url : String
    , filepath : Filepath
    }


{-| module Pages.SignIn exposing (page)

import Html exposing (Html)

page : Html msg
page =
Html.text "/sign-in"

-}
newPageModule : Data -> CodeGen.Module
newPageModule { url, filepath } =
    let
        pageFn : CodeGen.Declaration
        pageFn =
            if Filepath.hasDynamicParameters filepath then
                CodeGen.Declaration.function
                    { name = "page"
                    , annotation =
                        CodeGen.Annotation.function
                            [ Filepath.toParamsRecord filepath
                            , CodeGen.Annotation.type_ "Html msg"
                            ]
                    , arguments = [ CodeGen.Argument.new "params" ]
                    , expression =
                        CodeGen.Expression.function
                            { name = "Html.text"
                            , arguments =
                                [ CodeGen.Expression.parens
                                    (Filepath.toList filepath
                                        |> List.map
                                            (\piece ->
                                                if String.endsWith "_" piece then
                                                    CodeGen.Expression.value
                                                        ("params." ++ Extras.String.fromPascalCaseToCamelCase (String.dropRight 1 piece))

                                                else
                                                    CodeGen.Expression.string
                                                        ("/" ++ Extras.String.fromPascalCaseToKebabCase piece ++ "/")
                                            )
                                        |> List.intersperse (CodeGen.Expression.operator "++")
                                    )
                                ]
                            }
                    }

            else
                CodeGen.Declaration.function
                    { name = "page"
                    , annotation = CodeGen.Annotation.type_ "Html msg"
                    , arguments = []
                    , expression =
                        CodeGen.Expression.function
                            { name = "Html.text"
                            , arguments =
                                [ CodeGen.Expression.string url
                                ]
                            }
                    }
    in
    CodeGen.Module.new
        { name = "Pages" :: Filepath.toList filepath
        , exposing_ = [ "page" ]
        , imports =
            [ CodeGen.Import.new [ "Html" ]
                |> CodeGen.Import.withExposing [ "Html" ]
            ]
        , declarations =
            [ pageFn
            ]
        }


decoder : Json.Decode.Decoder Data
decoder =
    Json.Decode.map2 Data
        (Json.Decode.field "url" Json.Decode.string)
        (Json.Decode.field "filepath" Filepath.decoder)

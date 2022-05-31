module Commands.AddLayout exposing (run)

import CodeGen
import CodeGen.Annotation
import CodeGen.Argument
import CodeGen.Declaration
import CodeGen.Expression
import CodeGen.Import
import CodeGen.Module
import Json.Decode


run : Json.Decode.Value -> List CodeGen.Module
run json =
    case Json.Decode.decodeValue decoder json of
        Ok data ->
            [ newLayoutModule data ]

        Err _ ->
            []



-- DATA


type alias Data =
    { name : String
    }


decoder : Json.Decode.Decoder Data
decoder =
    Json.Decode.map Data
        (Json.Decode.field "name" Json.Decode.string)



-- CODEGEN


{-|

    module Layouts.Sidebar exposing (layout)

    import Html exposing (Html)
    import Html.Attributes as Attr

    layout : { page : Html msg } -> Html msg
    layout { page } =
        Html.div
            [ Attr.class "layout" ]
            [ page ]

-}
newLayoutModule : Data -> CodeGen.Module
newLayoutModule data =
    CodeGen.Module.new
        { name = [ "Layouts", data.name ]
        , exposing_ = [ "layout" ]
        , imports =
            [ CodeGen.Import.new [ "Html" ]
                |> CodeGen.Import.withExposing [ "Html" ]
            , CodeGen.Import.new [ "Html", "Attributes" ]
                |> CodeGen.Import.withAlias "Attr"
            ]
        , declarations =
            [ CodeGen.Declaration.function
                { name = "layout"
                , annotation =
                    CodeGen.Annotation.function
                        [ CodeGen.Annotation.record
                            [ ( "page", CodeGen.Annotation.type_ "Html msg" )
                            ]
                        , CodeGen.Annotation.type_ "Html msg"
                        ]
                , arguments = [ CodeGen.Argument.new "{ page }" ]
                , expression =
                    CodeGen.Expression.multilineFunction
                        { name = "Html.div"
                        , arguments =
                            [ CodeGen.Expression.list
                                [ CodeGen.Expression.function
                                    { name = "Attr.class"
                                    , arguments = [ CodeGen.Expression.string "layout" ]
                                    }
                                ]
                            , CodeGen.Expression.list
                                [ CodeGen.Expression.value "page"
                                ]
                            ]
                        }
                }
            ]
        }

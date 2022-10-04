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
    import View exposing (View)

    layout : { page : View msg } -> View msg
    layout { page } =
        { title = page.title
        , body =
            [ Html.div [ Attr.class "page" ] page.body
            ]
        }

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
            , CodeGen.Import.new [ "View" ]
                |> CodeGen.Import.withExposing [ "View" ]
            ]
        , declarations =
            [ CodeGen.Declaration.function
                { name = "layout"
                , annotation =
                    CodeGen.Annotation.function
                        [ CodeGen.Annotation.record
                            [ ( "page", CodeGen.Annotation.type_ "View msg" )
                            ]
                        , CodeGen.Annotation.type_ "View msg"
                        ]
                , arguments = [ CodeGen.Argument.new "{ page }" ]
                , expression =
                    CodeGen.Expression.multilineRecord
                        [ ( "title", CodeGen.Expression.value "page.title" )
                        , ( "body"
                          , CodeGen.Expression.list
                                [ CodeGen.Expression.function
                                    { name = "Html.div"
                                    , arguments =
                                        [ CodeGen.Expression.list
                                            [ CodeGen.Expression.function
                                                { name = "Attr.class"
                                                , arguments = [ CodeGen.Expression.string "page" ]
                                                }
                                            ]
                                        , CodeGen.Expression.value "page.body"
                                        ]
                                    }
                                ]
                          )
                        ]
                }
            ]
        }

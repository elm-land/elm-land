module Commands.AddPage exposing (Options, run)

import Elm
import Elm.Annotation
import Elm.Gen
import RoutePath exposing (RoutePath)


type alias Options =
    { routePath : RoutePath
    , url : String
    }


run : Options -> Cmd msg
run options =
    Elm.Gen.files
        [ newPageFile options
        ]


newPageFile : Options -> Elm.File
newPageFile options =
    Elm.file ("Pages" :: RoutePath.toList options.routePath)
        [ Elm.declaration "page" (pageFn options)
            |> Elm.expose
        ]


pageFn : Options -> Elm.Expression
pageFn { url, routePath } =
    if RoutePath.hasDynamicParameters routePath then
        Elm.function
            [ ( "params", Just (RoutePath.toDynamicParameterRecord routePath) )
            ]
            (\_ ->
                Elm.apply
                    (Elm.value
                        { importFrom = [ "Html" ]
                        , name = "text"
                        , annotation = Nothing
                        }
                    )
                    [ RoutePath.toInitialHtmlMessage url routePath ]
                    |> Elm.withType
                        (Elm.Annotation.namedWith [ "Html" ]
                            "Html"
                            [ Elm.Annotation.var "msg"
                            ]
                        )
            )

    else
        Elm.apply
            (Elm.value
                { importFrom = [ "Html" ]
                , name = "text"
                , annotation = Nothing
                }
            )
            [ RoutePath.toInitialHtmlMessage url routePath ]
            |> Elm.withType
                (Elm.Annotation.namedWith [ "Html" ]
                    "Html"
                    [ Elm.Annotation.var "msg"
                    ]
                )

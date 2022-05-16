module Gen exposing (main)

{-| -}

import Elm
import Generate
import Elm.Annotation as Type



main : Program {} () ()
main =
    Platform.worker
        { init =
            \json ->
                ( ()
                , Cmd.batch
                    [ Generate.files
                        [ file
                        ]
                    ]
                )
        , update =
            \msg model ->
                ( model, Cmd.none )
        , subscriptions = \_ -> Sub.none
        }


file =
    Elm.file [ "My", "Module" ]
        [ Elm.declaration "placeholder12"
            (Elm.valueFrom (Elm.moduleAs [ "Json", "Decode" ] "Json")
                "map2"
            )
        , Elm.comment "Yo, wassuyp!?"
        , Elm.declaration "myRecord"
            (Elm.record
                [ ( "field1", Elm.string "My cool string" )
                , ( "field2", Elm.int 5 )
                , ( "field4", Elm.bool False )
                , ( "field5", Elm.int 5 )
                , ( "field6", Elm.string "My cool string?!?!?!" )
                , ( "field7"
                  , Elm.record
                        [ ( "field1", Elm.string "My cool string" )
                        , ( "field2", Elm.int 5 )
                        ]
                  )
                ]
            )
            |> Elm.exposeAndGroup "records"
        , Elm.declaration "myString"
            (Elm.string "Hello world!")
                 |> Elm.exposeAndGroup "strings"

        , Elm.declaration "myString2"
            (Elm.string "Hello world!")
                 |> Elm.exposeAndGroup "strings"

        , Elm.customType "MyType"
            [ Elm.variant "One"
            , Elm.variantWith "Two" [ Type.list Type.string ]
            ]

        , Elm.customType "MyType"
            [ Elm.variant "One"
            , Elm.variantWith "Two" [ Type.list (Type.var "markdown") ]
            ]
        ]



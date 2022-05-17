module Worker exposing (main)

import Generate


main : Program { pageRoutePaths : List Generate.RoutePath } () ()
main =
    Platform.worker
        { init = \json -> ( (), Generate.run json.pageRoutePaths )
        , update = \msg model -> ( model, Cmd.none )
        , subscriptions = \_ -> Sub.none
        }

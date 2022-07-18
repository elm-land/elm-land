module Shared exposing
    ( Flags
    , Model, Msg(..)
    , init, update, subscriptions
    )

{-|

@docs Flags
@docs Model, Msg
@docs init, update, subscriptions

-}
import ElmLand.Request exposing (Request)



-- INIT


type alias Flags =
    ()


type alias Model =
    {}


init : Flags -> Request () -> ( Model, Cmd Msg )
init flags req =
    ( {}
    , Cmd.none
    )



-- UPDATE


type Msg 
    = ExampleMsgReplaceMe


update : Request () -> Msg -> Model -> ( Model, Cmd Msg )
update req msg model =
    case msg of
        ExampleMsgReplaceMe ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Request () -> Model -> Sub Msg
subscriptions req model =
    Sub.none
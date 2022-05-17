module Gen.Error.Format exposing (block, call_, cyan, green, grey, moduleName_, red, values_, yellow)

{-| 
@docs moduleName_, block, cyan, yellow, green, red, grey, call_, values_
-}


import Elm
import Elm.Annotation as Type


{-| The name of this module. -}
moduleName_ : List String
moduleName_ =
    [ "Error", "Format" ]


{-| An indented block with a newline above and below
-}
block : List Elm.Expression -> Elm.Expression
block arg1 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Error", "Format" ]
            , name = "block"
            , annotation =
                Just (Type.function [ Type.list Type.string ] Type.string)
            }
        )
        [ Elm.list arg1 ]


{-| -}
cyan : Elm.Expression -> Elm.Expression
cyan arg1 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Error", "Format" ]
            , name = "cyan"
            , annotation = Just (Type.function [ Type.string ] Type.string)
            }
        )
        [ arg1 ]


{-| -}
yellow : Elm.Expression -> Elm.Expression
yellow arg1 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Error", "Format" ]
            , name = "yellow"
            , annotation = Just (Type.function [ Type.string ] Type.string)
            }
        )
        [ arg1 ]


{-| -}
green : Elm.Expression -> Elm.Expression
green arg1 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Error", "Format" ]
            , name = "green"
            , annotation = Just (Type.function [ Type.string ] Type.string)
            }
        )
        [ arg1 ]


{-| -}
red : Elm.Expression -> Elm.Expression
red arg1 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Error", "Format" ]
            , name = "red"
            , annotation = Just (Type.function [ Type.string ] Type.string)
            }
        )
        [ arg1 ]


{-| -}
grey : Elm.Expression -> Elm.Expression
grey arg1 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Error", "Format" ]
            , name = "grey"
            , annotation = Just (Type.function [ Type.string ] Type.string)
            }
        )
        [ arg1 ]


call_ :
    { block : Elm.Expression -> Elm.Expression
    , cyan : Elm.Expression -> Elm.Expression
    , yellow : Elm.Expression -> Elm.Expression
    , green : Elm.Expression -> Elm.Expression
    , red : Elm.Expression -> Elm.Expression
    , grey : Elm.Expression -> Elm.Expression
    }
call_ =
    { block =
        \arg1_0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Error", "Format" ]
                    , name = "block"
                    , annotation =
                        Just
                            (Type.function [ Type.list Type.string ] Type.string
                            )
                    }
                )
                [ arg1_0 ]
    , cyan =
        \arg1_1_0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Error", "Format" ]
                    , name = "cyan"
                    , annotation =
                        Just (Type.function [ Type.string ] Type.string)
                    }
                )
                [ arg1_1_0 ]
    , yellow =
        \arg1_2_0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Error", "Format" ]
                    , name = "yellow"
                    , annotation =
                        Just (Type.function [ Type.string ] Type.string)
                    }
                )
                [ arg1_2_0 ]
    , green =
        \arg1_3_0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Error", "Format" ]
                    , name = "green"
                    , annotation =
                        Just (Type.function [ Type.string ] Type.string)
                    }
                )
                [ arg1_3_0 ]
    , red =
        \arg1_4_0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Error", "Format" ]
                    , name = "red"
                    , annotation =
                        Just (Type.function [ Type.string ] Type.string)
                    }
                )
                [ arg1_4_0 ]
    , grey =
        \arg1_5_0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Error", "Format" ]
                    , name = "grey"
                    , annotation =
                        Just (Type.function [ Type.string ] Type.string)
                    }
                )
                [ arg1_5_0 ]
    }


values_ :
    { block : Elm.Expression
    , cyan : Elm.Expression
    , yellow : Elm.Expression
    , green : Elm.Expression
    , red : Elm.Expression
    , grey : Elm.Expression
    }
values_ =
    { block =
        Elm.value
            { importFrom = [ "Error", "Format" ]
            , name = "block"
            , annotation =
                Just (Type.function [ Type.list Type.string ] Type.string)
            }
    , cyan =
        Elm.value
            { importFrom = [ "Error", "Format" ]
            , name = "cyan"
            , annotation = Just (Type.function [ Type.string ] Type.string)
            }
    , yellow =
        Elm.value
            { importFrom = [ "Error", "Format" ]
            , name = "yellow"
            , annotation = Just (Type.function [ Type.string ] Type.string)
            }
    , green =
        Elm.value
            { importFrom = [ "Error", "Format" ]
            , name = "green"
            , annotation = Just (Type.function [ Type.string ] Type.string)
            }
    , red =
        Elm.value
            { importFrom = [ "Error", "Format" ]
            , name = "red"
            , annotation = Just (Type.function [ Type.string ] Type.string)
            }
    , grey =
        Elm.value
            { importFrom = [ "Error", "Format" ]
            , name = "grey"
            , annotation = Just (Type.function [ Type.string ] Type.string)
            }
    }



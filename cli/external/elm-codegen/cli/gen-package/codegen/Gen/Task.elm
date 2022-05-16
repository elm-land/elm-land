module Gen.Task exposing (andThen, annotation_, attempt, call_, fail, map, map2, map3, map4, map5, mapError, moduleName_, onError, perform, sequence, succeed, values_)

{-| 
@docs moduleName_, perform, attempt, andThen, succeed, fail, sequence, map, map2, map3, map4, map5, onError, mapError, annotation_, call_, values_
-}


import Elm
import Elm.Annotation as Type


{-| The name of this module. -}
moduleName_ : List String
moduleName_ =
    [ "Task" ]


{-| Like I was saying in the [`Task`](#Task) documentation, just having a
`Task` does not mean it is done. We must command Elm to `perform` the task:

    import Time  -- elm install elm/time
    import Task

    type Msg
      = Click
      | Search String
      | NewTime Time.Posix

    getNewTime : Cmd Msg
    getNewTime =
      Task.perform NewTime Time.now

If you have worked through [`guide.elm-lang.org`][guide] (highly recommended!)
you will recognize `Cmd` from the section on The Elm Architecture. So we have
changed a task like "make delicious lasagna" into a command like "Hey Elm, make
delicious lasagna and give it to my `update` function as a `Msg` value."

[guide]: https://guide.elm-lang.org/

perform: (a -> msg) -> Task.Task Basics.Never a -> Platform.Cmd.Cmd msg
-}
perform : (Elm.Expression -> Elm.Expression) -> Elm.Expression -> Elm.Expression
perform arg arg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Task" ]
            , name = "perform"
            , annotation =
                Just
                    (Type.function
                        [ Type.function [ Type.var "a" ] (Type.var "msg")
                        , Type.namedWith
                            [ "Task" ]
                            "Task"
                            [ Type.namedWith [ "Basics" ] "Never" []
                            , Type.var "a"
                            ]
                        ]
                        (Type.namedWith
                            [ "Platform", "Cmd" ]
                            "Cmd"
                            [ Type.var "msg" ]
                        )
                    )
            }
        )
        [ Elm.functionReduced "unpack" arg, arg0 ]


{-| This is very similar to [`perform`](#perform) except it can handle failures!
So we could _attempt_ to focus on a certain DOM node like this:

    import Browser.Dom  -- elm install elm/browser
    import Task

    type Msg
      = Click
      | Search String
      | Focus (Result Browser.DomError ())

    focus : Cmd Msg
    focus =
      Task.attempt Focus (Browser.Dom.focus "my-app-search-box")

So the task is "focus on this DOM node" and we are turning it into the command
"Hey Elm, attempt to focus on this DOM node and give me a `Msg` about whether
you succeeded or failed."

**Note:** Definitely work through [`guide.elm-lang.org`][guide] to get a
feeling for how commands fit into The Elm Architecture.

[guide]: https://guide.elm-lang.org/

attempt: (Result.Result x a -> msg) -> Task.Task x a -> Platform.Cmd.Cmd msg
-}
attempt : (Elm.Expression -> Elm.Expression) -> Elm.Expression -> Elm.Expression
attempt arg arg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Task" ]
            , name = "attempt"
            , annotation =
                Just
                    (Type.function
                        [ Type.function
                            [ Type.namedWith
                                [ "Result" ]
                                "Result"
                                [ Type.var "x", Type.var "a" ]
                            ]
                            (Type.var "msg")
                        , Type.namedWith
                            [ "Task" ]
                            "Task"
                            [ Type.var "x", Type.var "a" ]
                        ]
                        (Type.namedWith
                            [ "Platform", "Cmd" ]
                            "Cmd"
                            [ Type.var "msg" ]
                        )
                    )
            }
        )
        [ Elm.functionReduced "unpack" arg, arg0 ]


{-| Chain together a task and a callback. The first task will run, and if it is
successful, you give the result to the callback resulting in another task. This
task then gets run. We could use this to make a task that resolves an hour from
now:

    import Time -- elm install elm/time
    import Process

    timeInOneHour : Task x Time.Posix
    timeInOneHour =
      Process.sleep (60 * 60 * 1000)
        |> andThen (\_ -> Time.now)

First the process sleeps for an hour **and then** it tells us what time it is.

andThen: (a -> Task.Task x b) -> Task.Task x a -> Task.Task x b
-}
andThen : (Elm.Expression -> Elm.Expression) -> Elm.Expression -> Elm.Expression
andThen arg arg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Task" ]
            , name = "andThen"
            , annotation =
                Just
                    (Type.function
                        [ Type.function
                            [ Type.var "a" ]
                            (Type.namedWith
                                [ "Task" ]
                                "Task"
                                [ Type.var "x", Type.var "b" ]
                            )
                        , Type.namedWith
                            [ "Task" ]
                            "Task"
                            [ Type.var "x", Type.var "a" ]
                        ]
                        (Type.namedWith
                            [ "Task" ]
                            "Task"
                            [ Type.var "x", Type.var "b" ]
                        )
                    )
            }
        )
        [ Elm.functionReduced "unpack" arg, arg0 ]


{-| A task that succeeds immediately when run. It is usually used with
[`andThen`](#andThen). You can use it like `map` if you want:

    import Time -- elm install elm/time

    timeInMillis : Task x Int
    timeInMillis =
      Time.now
        |> andThen (\t -> succeed (Time.posixToMillis t))

succeed: a -> Task.Task x a
-}
succeed : Elm.Expression -> Elm.Expression
succeed arg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Task" ]
            , name = "succeed"
            , annotation =
                Just
                    (Type.function
                        [ Type.var "a" ]
                        (Type.namedWith
                            [ "Task" ]
                            "Task"
                            [ Type.var "x", Type.var "a" ]
                        )
                    )
            }
        )
        [ arg ]


{-| A task that fails immediately when run. Like with `succeed`, this can be
used with `andThen` to check on the outcome of another task.

    type Error = NotFound

    notFound : Task Error a
    notFound =
      fail NotFound

fail: x -> Task.Task x a
-}
fail : Elm.Expression -> Elm.Expression
fail arg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Task" ]
            , name = "fail"
            , annotation =
                Just
                    (Type.function
                        [ Type.var "x" ]
                        (Type.namedWith
                            [ "Task" ]
                            "Task"
                            [ Type.var "x", Type.var "a" ]
                        )
                    )
            }
        )
        [ arg ]


{-| Start with a list of tasks, and turn them into a single task that returns a
list. The tasks will be run in order one-by-one and if any task fails the whole
sequence fails.

    sequence [ succeed 1, succeed 2 ] == succeed [ 1, 2 ]

sequence: List (Task.Task x a) -> Task.Task x (List a)
-}
sequence : List Elm.Expression -> Elm.Expression
sequence arg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Task" ]
            , name = "sequence"
            , annotation =
                Just
                    (Type.function
                        [ Type.list
                            (Type.namedWith
                                [ "Task" ]
                                "Task"
                                [ Type.var "x", Type.var "a" ]
                            )
                        ]
                        (Type.namedWith
                            [ "Task" ]
                            "Task"
                            [ Type.var "x", Type.list (Type.var "a") ]
                        )
                    )
            }
        )
        [ Elm.list arg ]


{-| Transform a task. Maybe you want to use [`elm/time`][time] to figure
out what time it will be in one hour:

    import Task exposing (Task)
    import Time -- elm install elm/time

    timeInOneHour : Task x Time.Posix
    timeInOneHour =
      Task.map addAnHour Time.now

    addAnHour : Time.Posix -> Time.Posix
    addAnHour time =
      Time.millisToPosix (Time.posixToMillis time + 60 * 60 * 1000)

[time]: /packages/elm/time/latest/

map: (a -> b) -> Task.Task x a -> Task.Task x b
-}
map : (Elm.Expression -> Elm.Expression) -> Elm.Expression -> Elm.Expression
map arg arg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Task" ]
            , name = "map"
            , annotation =
                Just
                    (Type.function
                        [ Type.function [ Type.var "a" ] (Type.var "b")
                        , Type.namedWith
                            [ "Task" ]
                            "Task"
                            [ Type.var "x", Type.var "a" ]
                        ]
                        (Type.namedWith
                            [ "Task" ]
                            "Task"
                            [ Type.var "x", Type.var "b" ]
                        )
                    )
            }
        )
        [ Elm.functionReduced "unpack" arg, arg0 ]


{-| Put the results of two tasks together. For example, if we wanted to know
the current month, we could use [`elm/time`][time] to ask:

    import Task exposing (Task)
    import Time -- elm install elm/time

    getMonth : Task x Int
    getMonth =
      Task.map2 Time.toMonth Time.here Time.now

**Note:** Say we were doing HTTP requests instead. `map2` does each task in
order, so it would try the first request and only continue after it succeeds.
If it fails, the whole thing fails!

[time]: /packages/elm/time/latest/

map2: (a -> b -> result) -> Task.Task x a -> Task.Task x b -> Task.Task x result
-}
map2 :
    (Elm.Expression -> Elm.Expression -> Elm.Expression)
    -> Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
map2 arg arg0 arg1 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Task" ]
            , name = "map2"
            , annotation =
                Just
                    (Type.function
                        [ Type.function
                            [ Type.var "a", Type.var "b" ]
                            (Type.var "result")
                        , Type.namedWith
                            [ "Task" ]
                            "Task"
                            [ Type.var "x", Type.var "a" ]
                        , Type.namedWith
                            [ "Task" ]
                            "Task"
                            [ Type.var "x", Type.var "b" ]
                        ]
                        (Type.namedWith
                            [ "Task" ]
                            "Task"
                            [ Type.var "x", Type.var "result" ]
                        )
                    )
            }
        )
        [ Elm.functionReduced
            "unpack"
            (\unpack -> Elm.functionReduced "unpack" (arg unpack))
        , arg0
        , arg1
        ]


{-| map3: 
    (a -> b -> c -> result)
    -> Task.Task x a
    -> Task.Task x b
    -> Task.Task x c
    -> Task.Task x result
-}
map3 :
    (Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression)
    -> Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
map3 arg arg0 arg1 arg2 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Task" ]
            , name = "map3"
            , annotation =
                Just
                    (Type.function
                        [ Type.function
                            [ Type.var "a", Type.var "b", Type.var "c" ]
                            (Type.var "result")
                        , Type.namedWith
                            [ "Task" ]
                            "Task"
                            [ Type.var "x", Type.var "a" ]
                        , Type.namedWith
                            [ "Task" ]
                            "Task"
                            [ Type.var "x", Type.var "b" ]
                        , Type.namedWith
                            [ "Task" ]
                            "Task"
                            [ Type.var "x", Type.var "c" ]
                        ]
                        (Type.namedWith
                            [ "Task" ]
                            "Task"
                            [ Type.var "x", Type.var "result" ]
                        )
                    )
            }
        )
        [ Elm.functionReduced
            "unpack"
            (\unpack ->
                Elm.functionReduced
                    "unpack"
                    (\unpack0 ->
                        Elm.functionReduced "unpack" (arg unpack unpack0)
                    )
            )
        , arg0
        , arg1
        , arg2
        ]


{-| map4: 
    (a -> b -> c -> d -> result)
    -> Task.Task x a
    -> Task.Task x b
    -> Task.Task x c
    -> Task.Task x d
    -> Task.Task x result
-}
map4 :
    (Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
    -> Elm.Expression)
    -> Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
map4 arg arg0 arg1 arg2 arg3 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Task" ]
            , name = "map4"
            , annotation =
                Just
                    (Type.function
                        [ Type.function
                            [ Type.var "a"
                            , Type.var "b"
                            , Type.var "c"
                            , Type.var "d"
                            ]
                            (Type.var "result")
                        , Type.namedWith
                            [ "Task" ]
                            "Task"
                            [ Type.var "x", Type.var "a" ]
                        , Type.namedWith
                            [ "Task" ]
                            "Task"
                            [ Type.var "x", Type.var "b" ]
                        , Type.namedWith
                            [ "Task" ]
                            "Task"
                            [ Type.var "x", Type.var "c" ]
                        , Type.namedWith
                            [ "Task" ]
                            "Task"
                            [ Type.var "x", Type.var "d" ]
                        ]
                        (Type.namedWith
                            [ "Task" ]
                            "Task"
                            [ Type.var "x", Type.var "result" ]
                        )
                    )
            }
        )
        [ Elm.functionReduced
            "unpack"
            (\unpack ->
                Elm.functionReduced
                    "unpack"
                    (\unpack0 ->
                        Elm.functionReduced
                            "unpack"
                            (\unpack_4_3_3_3_0 ->
                                Elm.functionReduced
                                    "unpack"
                                    (arg unpack unpack0 unpack_4_3_3_3_0)
                            )
                    )
            )
        , arg0
        , arg1
        , arg2
        , arg3
        ]


{-| map5: 
    (a -> b -> c -> d -> e -> result)
    -> Task.Task x a
    -> Task.Task x b
    -> Task.Task x c
    -> Task.Task x d
    -> Task.Task x e
    -> Task.Task x result
-}
map5 :
    (Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
    -> Elm.Expression)
    -> Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
map5 arg arg0 arg1 arg2 arg3 arg4 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Task" ]
            , name = "map5"
            , annotation =
                Just
                    (Type.function
                        [ Type.function
                            [ Type.var "a"
                            , Type.var "b"
                            , Type.var "c"
                            , Type.var "d"
                            , Type.var "e"
                            ]
                            (Type.var "result")
                        , Type.namedWith
                            [ "Task" ]
                            "Task"
                            [ Type.var "x", Type.var "a" ]
                        , Type.namedWith
                            [ "Task" ]
                            "Task"
                            [ Type.var "x", Type.var "b" ]
                        , Type.namedWith
                            [ "Task" ]
                            "Task"
                            [ Type.var "x", Type.var "c" ]
                        , Type.namedWith
                            [ "Task" ]
                            "Task"
                            [ Type.var "x", Type.var "d" ]
                        , Type.namedWith
                            [ "Task" ]
                            "Task"
                            [ Type.var "x", Type.var "e" ]
                        ]
                        (Type.namedWith
                            [ "Task" ]
                            "Task"
                            [ Type.var "x", Type.var "result" ]
                        )
                    )
            }
        )
        [ Elm.functionReduced
            "unpack"
            (\unpack ->
                Elm.functionReduced
                    "unpack"
                    (\unpack0 ->
                        Elm.functionReduced
                            "unpack"
                            (\unpack_4_3_3_3_0 ->
                                Elm.functionReduced
                                    "unpack"
                                    (\unpack_4_4_3_3_3_0 ->
                                        Elm.functionReduced
                                            "unpack"
                                            (arg unpack unpack0 unpack_4_3_3_3_0
                                                unpack_4_4_3_3_3_0
                                            )
                                    )
                            )
                    )
            )
        , arg0
        , arg1
        , arg2
        , arg3
        , arg4
        ]


{-| Recover from a failure in a task. If the given task fails, we use the
callback to recover.

    fail "file not found"
      |> onError (\msg -> succeed 42)
      -- succeed 42

    succeed 9
      |> onError (\msg -> succeed 42)
      -- succeed 9

onError: (x -> Task.Task y a) -> Task.Task x a -> Task.Task y a
-}
onError : (Elm.Expression -> Elm.Expression) -> Elm.Expression -> Elm.Expression
onError arg arg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Task" ]
            , name = "onError"
            , annotation =
                Just
                    (Type.function
                        [ Type.function
                            [ Type.var "x" ]
                            (Type.namedWith
                                [ "Task" ]
                                "Task"
                                [ Type.var "y", Type.var "a" ]
                            )
                        , Type.namedWith
                            [ "Task" ]
                            "Task"
                            [ Type.var "x", Type.var "a" ]
                        ]
                        (Type.namedWith
                            [ "Task" ]
                            "Task"
                            [ Type.var "y", Type.var "a" ]
                        )
                    )
            }
        )
        [ Elm.functionReduced "unpack" arg, arg0 ]


{-| Transform the error value. This can be useful if you need a bunch of error
types to match up.

    type Error
      = Http Http.Error
      | WebGL WebGL.Error

    getResources : Task Error Resource
    getResources =
      sequence
        [ mapError Http serverTask
        , mapError WebGL textureTask
        ]

mapError: (x -> y) -> Task.Task x a -> Task.Task y a
-}
mapError :
    (Elm.Expression -> Elm.Expression) -> Elm.Expression -> Elm.Expression
mapError arg arg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Task" ]
            , name = "mapError"
            , annotation =
                Just
                    (Type.function
                        [ Type.function [ Type.var "x" ] (Type.var "y")
                        , Type.namedWith
                            [ "Task" ]
                            "Task"
                            [ Type.var "x", Type.var "a" ]
                        ]
                        (Type.namedWith
                            [ "Task" ]
                            "Task"
                            [ Type.var "y", Type.var "a" ]
                        )
                    )
            }
        )
        [ Elm.functionReduced "unpack" arg, arg0 ]


annotation_ : { task : Type.Annotation -> Type.Annotation -> Type.Annotation }
annotation_ =
    { task =
        \arg0 arg1 ->
            Type.alias
                moduleName_
                "Task"
                [ arg0, arg1 ]
                (Type.namedWith
                    [ "Platform" ]
                    "Task"
                    [ Type.var "x", Type.var "a" ]
                )
    }


call_ :
    { perform : Elm.Expression -> Elm.Expression -> Elm.Expression
    , attempt : Elm.Expression -> Elm.Expression -> Elm.Expression
    , andThen : Elm.Expression -> Elm.Expression -> Elm.Expression
    , succeed : Elm.Expression -> Elm.Expression
    , fail : Elm.Expression -> Elm.Expression
    , sequence : Elm.Expression -> Elm.Expression
    , map : Elm.Expression -> Elm.Expression -> Elm.Expression
    , map2 :
        Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
    , map3 :
        Elm.Expression
        -> Elm.Expression
        -> Elm.Expression
        -> Elm.Expression
        -> Elm.Expression
    , map4 :
        Elm.Expression
        -> Elm.Expression
        -> Elm.Expression
        -> Elm.Expression
        -> Elm.Expression
        -> Elm.Expression
    , map5 :
        Elm.Expression
        -> Elm.Expression
        -> Elm.Expression
        -> Elm.Expression
        -> Elm.Expression
        -> Elm.Expression
        -> Elm.Expression
    , onError : Elm.Expression -> Elm.Expression -> Elm.Expression
    , mapError : Elm.Expression -> Elm.Expression -> Elm.Expression
    }
call_ =
    { perform =
        \arg arg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Task" ]
                    , name = "perform"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.function
                                    [ Type.var "a" ]
                                    (Type.var "msg")
                                , Type.namedWith
                                    [ "Task" ]
                                    "Task"
                                    [ Type.namedWith [ "Basics" ] "Never" []
                                    , Type.var "a"
                                    ]
                                ]
                                (Type.namedWith
                                    [ "Platform", "Cmd" ]
                                    "Cmd"
                                    [ Type.var "msg" ]
                                )
                            )
                    }
                )
                [ arg, arg0 ]
    , attempt =
        \arg arg1 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Task" ]
                    , name = "attempt"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.function
                                    [ Type.namedWith
                                        [ "Result" ]
                                        "Result"
                                        [ Type.var "x", Type.var "a" ]
                                    ]
                                    (Type.var "msg")
                                , Type.namedWith
                                    [ "Task" ]
                                    "Task"
                                    [ Type.var "x", Type.var "a" ]
                                ]
                                (Type.namedWith
                                    [ "Platform", "Cmd" ]
                                    "Cmd"
                                    [ Type.var "msg" ]
                                )
                            )
                    }
                )
                [ arg, arg1 ]
    , andThen =
        \arg arg2 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Task" ]
                    , name = "andThen"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.function
                                    [ Type.var "a" ]
                                    (Type.namedWith
                                        [ "Task" ]
                                        "Task"
                                        [ Type.var "x", Type.var "b" ]
                                    )
                                , Type.namedWith
                                    [ "Task" ]
                                    "Task"
                                    [ Type.var "x", Type.var "a" ]
                                ]
                                (Type.namedWith
                                    [ "Task" ]
                                    "Task"
                                    [ Type.var "x", Type.var "b" ]
                                )
                            )
                    }
                )
                [ arg, arg2 ]
    , succeed =
        \arg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Task" ]
                    , name = "succeed"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.var "a" ]
                                (Type.namedWith
                                    [ "Task" ]
                                    "Task"
                                    [ Type.var "x", Type.var "a" ]
                                )
                            )
                    }
                )
                [ arg ]
    , fail =
        \arg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Task" ]
                    , name = "fail"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.var "x" ]
                                (Type.namedWith
                                    [ "Task" ]
                                    "Task"
                                    [ Type.var "x", Type.var "a" ]
                                )
                            )
                    }
                )
                [ arg ]
    , sequence =
        \arg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Task" ]
                    , name = "sequence"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.list
                                    (Type.namedWith
                                        [ "Task" ]
                                        "Task"
                                        [ Type.var "x", Type.var "a" ]
                                    )
                                ]
                                (Type.namedWith
                                    [ "Task" ]
                                    "Task"
                                    [ Type.var "x", Type.list (Type.var "a") ]
                                )
                            )
                    }
                )
                [ arg ]
    , map =
        \arg arg6 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Task" ]
                    , name = "map"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.function [ Type.var "a" ] (Type.var "b")
                                , Type.namedWith
                                    [ "Task" ]
                                    "Task"
                                    [ Type.var "x", Type.var "a" ]
                                ]
                                (Type.namedWith
                                    [ "Task" ]
                                    "Task"
                                    [ Type.var "x", Type.var "b" ]
                                )
                            )
                    }
                )
                [ arg, arg6 ]
    , map2 =
        \arg arg7 arg8 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Task" ]
                    , name = "map2"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.function
                                    [ Type.var "a", Type.var "b" ]
                                    (Type.var "result")
                                , Type.namedWith
                                    [ "Task" ]
                                    "Task"
                                    [ Type.var "x", Type.var "a" ]
                                , Type.namedWith
                                    [ "Task" ]
                                    "Task"
                                    [ Type.var "x", Type.var "b" ]
                                ]
                                (Type.namedWith
                                    [ "Task" ]
                                    "Task"
                                    [ Type.var "x", Type.var "result" ]
                                )
                            )
                    }
                )
                [ arg, arg7, arg8 ]
    , map3 =
        \arg arg8 arg9 arg10 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Task" ]
                    , name = "map3"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.function
                                    [ Type.var "a", Type.var "b", Type.var "c" ]
                                    (Type.var "result")
                                , Type.namedWith
                                    [ "Task" ]
                                    "Task"
                                    [ Type.var "x", Type.var "a" ]
                                , Type.namedWith
                                    [ "Task" ]
                                    "Task"
                                    [ Type.var "x", Type.var "b" ]
                                , Type.namedWith
                                    [ "Task" ]
                                    "Task"
                                    [ Type.var "x", Type.var "c" ]
                                ]
                                (Type.namedWith
                                    [ "Task" ]
                                    "Task"
                                    [ Type.var "x", Type.var "result" ]
                                )
                            )
                    }
                )
                [ arg, arg8, arg9, arg10 ]
    , map4 =
        \arg arg9 arg10 arg11 arg12 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Task" ]
                    , name = "map4"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.function
                                    [ Type.var "a"
                                    , Type.var "b"
                                    , Type.var "c"
                                    , Type.var "d"
                                    ]
                                    (Type.var "result")
                                , Type.namedWith
                                    [ "Task" ]
                                    "Task"
                                    [ Type.var "x", Type.var "a" ]
                                , Type.namedWith
                                    [ "Task" ]
                                    "Task"
                                    [ Type.var "x", Type.var "b" ]
                                , Type.namedWith
                                    [ "Task" ]
                                    "Task"
                                    [ Type.var "x", Type.var "c" ]
                                , Type.namedWith
                                    [ "Task" ]
                                    "Task"
                                    [ Type.var "x", Type.var "d" ]
                                ]
                                (Type.namedWith
                                    [ "Task" ]
                                    "Task"
                                    [ Type.var "x", Type.var "result" ]
                                )
                            )
                    }
                )
                [ arg, arg9, arg10, arg11, arg12 ]
    , map5 =
        \arg arg10 arg11 arg12 arg13 arg14 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Task" ]
                    , name = "map5"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.function
                                    [ Type.var "a"
                                    , Type.var "b"
                                    , Type.var "c"
                                    , Type.var "d"
                                    , Type.var "e"
                                    ]
                                    (Type.var "result")
                                , Type.namedWith
                                    [ "Task" ]
                                    "Task"
                                    [ Type.var "x", Type.var "a" ]
                                , Type.namedWith
                                    [ "Task" ]
                                    "Task"
                                    [ Type.var "x", Type.var "b" ]
                                , Type.namedWith
                                    [ "Task" ]
                                    "Task"
                                    [ Type.var "x", Type.var "c" ]
                                , Type.namedWith
                                    [ "Task" ]
                                    "Task"
                                    [ Type.var "x", Type.var "d" ]
                                , Type.namedWith
                                    [ "Task" ]
                                    "Task"
                                    [ Type.var "x", Type.var "e" ]
                                ]
                                (Type.namedWith
                                    [ "Task" ]
                                    "Task"
                                    [ Type.var "x", Type.var "result" ]
                                )
                            )
                    }
                )
                [ arg, arg10, arg11, arg12, arg13, arg14 ]
    , onError =
        \arg arg11 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Task" ]
                    , name = "onError"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.function
                                    [ Type.var "x" ]
                                    (Type.namedWith
                                        [ "Task" ]
                                        "Task"
                                        [ Type.var "y", Type.var "a" ]
                                    )
                                , Type.namedWith
                                    [ "Task" ]
                                    "Task"
                                    [ Type.var "x", Type.var "a" ]
                                ]
                                (Type.namedWith
                                    [ "Task" ]
                                    "Task"
                                    [ Type.var "y", Type.var "a" ]
                                )
                            )
                    }
                )
                [ arg, arg11 ]
    , mapError =
        \arg arg12 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Task" ]
                    , name = "mapError"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.function [ Type.var "x" ] (Type.var "y")
                                , Type.namedWith
                                    [ "Task" ]
                                    "Task"
                                    [ Type.var "x", Type.var "a" ]
                                ]
                                (Type.namedWith
                                    [ "Task" ]
                                    "Task"
                                    [ Type.var "y", Type.var "a" ]
                                )
                            )
                    }
                )
                [ arg, arg12 ]
    }


values_ :
    { perform : Elm.Expression
    , attempt : Elm.Expression
    , andThen : Elm.Expression
    , succeed : Elm.Expression
    , fail : Elm.Expression
    , sequence : Elm.Expression
    , map : Elm.Expression
    , map2 : Elm.Expression
    , map3 : Elm.Expression
    , map4 : Elm.Expression
    , map5 : Elm.Expression
    , onError : Elm.Expression
    , mapError : Elm.Expression
    }
values_ =
    { perform =
        Elm.value
            { importFrom = [ "Task" ]
            , name = "perform"
            , annotation =
                Just
                    (Type.function
                        [ Type.function [ Type.var "a" ] (Type.var "msg")
                        , Type.namedWith
                            [ "Task" ]
                            "Task"
                            [ Type.namedWith [ "Basics" ] "Never" []
                            , Type.var "a"
                            ]
                        ]
                        (Type.namedWith
                            [ "Platform", "Cmd" ]
                            "Cmd"
                            [ Type.var "msg" ]
                        )
                    )
            }
    , attempt =
        Elm.value
            { importFrom = [ "Task" ]
            , name = "attempt"
            , annotation =
                Just
                    (Type.function
                        [ Type.function
                            [ Type.namedWith
                                [ "Result" ]
                                "Result"
                                [ Type.var "x", Type.var "a" ]
                            ]
                            (Type.var "msg")
                        , Type.namedWith
                            [ "Task" ]
                            "Task"
                            [ Type.var "x", Type.var "a" ]
                        ]
                        (Type.namedWith
                            [ "Platform", "Cmd" ]
                            "Cmd"
                            [ Type.var "msg" ]
                        )
                    )
            }
    , andThen =
        Elm.value
            { importFrom = [ "Task" ]
            , name = "andThen"
            , annotation =
                Just
                    (Type.function
                        [ Type.function
                            [ Type.var "a" ]
                            (Type.namedWith
                                [ "Task" ]
                                "Task"
                                [ Type.var "x", Type.var "b" ]
                            )
                        , Type.namedWith
                            [ "Task" ]
                            "Task"
                            [ Type.var "x", Type.var "a" ]
                        ]
                        (Type.namedWith
                            [ "Task" ]
                            "Task"
                            [ Type.var "x", Type.var "b" ]
                        )
                    )
            }
    , succeed =
        Elm.value
            { importFrom = [ "Task" ]
            , name = "succeed"
            , annotation =
                Just
                    (Type.function
                        [ Type.var "a" ]
                        (Type.namedWith
                            [ "Task" ]
                            "Task"
                            [ Type.var "x", Type.var "a" ]
                        )
                    )
            }
    , fail =
        Elm.value
            { importFrom = [ "Task" ]
            , name = "fail"
            , annotation =
                Just
                    (Type.function
                        [ Type.var "x" ]
                        (Type.namedWith
                            [ "Task" ]
                            "Task"
                            [ Type.var "x", Type.var "a" ]
                        )
                    )
            }
    , sequence =
        Elm.value
            { importFrom = [ "Task" ]
            , name = "sequence"
            , annotation =
                Just
                    (Type.function
                        [ Type.list
                            (Type.namedWith
                                [ "Task" ]
                                "Task"
                                [ Type.var "x", Type.var "a" ]
                            )
                        ]
                        (Type.namedWith
                            [ "Task" ]
                            "Task"
                            [ Type.var "x", Type.list (Type.var "a") ]
                        )
                    )
            }
    , map =
        Elm.value
            { importFrom = [ "Task" ]
            , name = "map"
            , annotation =
                Just
                    (Type.function
                        [ Type.function [ Type.var "a" ] (Type.var "b")
                        , Type.namedWith
                            [ "Task" ]
                            "Task"
                            [ Type.var "x", Type.var "a" ]
                        ]
                        (Type.namedWith
                            [ "Task" ]
                            "Task"
                            [ Type.var "x", Type.var "b" ]
                        )
                    )
            }
    , map2 =
        Elm.value
            { importFrom = [ "Task" ]
            , name = "map2"
            , annotation =
                Just
                    (Type.function
                        [ Type.function
                            [ Type.var "a", Type.var "b" ]
                            (Type.var "result")
                        , Type.namedWith
                            [ "Task" ]
                            "Task"
                            [ Type.var "x", Type.var "a" ]
                        , Type.namedWith
                            [ "Task" ]
                            "Task"
                            [ Type.var "x", Type.var "b" ]
                        ]
                        (Type.namedWith
                            [ "Task" ]
                            "Task"
                            [ Type.var "x", Type.var "result" ]
                        )
                    )
            }
    , map3 =
        Elm.value
            { importFrom = [ "Task" ]
            , name = "map3"
            , annotation =
                Just
                    (Type.function
                        [ Type.function
                            [ Type.var "a", Type.var "b", Type.var "c" ]
                            (Type.var "result")
                        , Type.namedWith
                            [ "Task" ]
                            "Task"
                            [ Type.var "x", Type.var "a" ]
                        , Type.namedWith
                            [ "Task" ]
                            "Task"
                            [ Type.var "x", Type.var "b" ]
                        , Type.namedWith
                            [ "Task" ]
                            "Task"
                            [ Type.var "x", Type.var "c" ]
                        ]
                        (Type.namedWith
                            [ "Task" ]
                            "Task"
                            [ Type.var "x", Type.var "result" ]
                        )
                    )
            }
    , map4 =
        Elm.value
            { importFrom = [ "Task" ]
            , name = "map4"
            , annotation =
                Just
                    (Type.function
                        [ Type.function
                            [ Type.var "a"
                            , Type.var "b"
                            , Type.var "c"
                            , Type.var "d"
                            ]
                            (Type.var "result")
                        , Type.namedWith
                            [ "Task" ]
                            "Task"
                            [ Type.var "x", Type.var "a" ]
                        , Type.namedWith
                            [ "Task" ]
                            "Task"
                            [ Type.var "x", Type.var "b" ]
                        , Type.namedWith
                            [ "Task" ]
                            "Task"
                            [ Type.var "x", Type.var "c" ]
                        , Type.namedWith
                            [ "Task" ]
                            "Task"
                            [ Type.var "x", Type.var "d" ]
                        ]
                        (Type.namedWith
                            [ "Task" ]
                            "Task"
                            [ Type.var "x", Type.var "result" ]
                        )
                    )
            }
    , map5 =
        Elm.value
            { importFrom = [ "Task" ]
            , name = "map5"
            , annotation =
                Just
                    (Type.function
                        [ Type.function
                            [ Type.var "a"
                            , Type.var "b"
                            , Type.var "c"
                            , Type.var "d"
                            , Type.var "e"
                            ]
                            (Type.var "result")
                        , Type.namedWith
                            [ "Task" ]
                            "Task"
                            [ Type.var "x", Type.var "a" ]
                        , Type.namedWith
                            [ "Task" ]
                            "Task"
                            [ Type.var "x", Type.var "b" ]
                        , Type.namedWith
                            [ "Task" ]
                            "Task"
                            [ Type.var "x", Type.var "c" ]
                        , Type.namedWith
                            [ "Task" ]
                            "Task"
                            [ Type.var "x", Type.var "d" ]
                        , Type.namedWith
                            [ "Task" ]
                            "Task"
                            [ Type.var "x", Type.var "e" ]
                        ]
                        (Type.namedWith
                            [ "Task" ]
                            "Task"
                            [ Type.var "x", Type.var "result" ]
                        )
                    )
            }
    , onError =
        Elm.value
            { importFrom = [ "Task" ]
            , name = "onError"
            , annotation =
                Just
                    (Type.function
                        [ Type.function
                            [ Type.var "x" ]
                            (Type.namedWith
                                [ "Task" ]
                                "Task"
                                [ Type.var "y", Type.var "a" ]
                            )
                        , Type.namedWith
                            [ "Task" ]
                            "Task"
                            [ Type.var "x", Type.var "a" ]
                        ]
                        (Type.namedWith
                            [ "Task" ]
                            "Task"
                            [ Type.var "y", Type.var "a" ]
                        )
                    )
            }
    , mapError =
        Elm.value
            { importFrom = [ "Task" ]
            , name = "mapError"
            , annotation =
                Just
                    (Type.function
                        [ Type.function [ Type.var "x" ] (Type.var "y")
                        , Type.namedWith
                            [ "Task" ]
                            "Task"
                            [ Type.var "x", Type.var "a" ]
                        ]
                        (Type.namedWith
                            [ "Task" ]
                            "Task"
                            [ Type.var "y", Type.var "a" ]
                        )
                    )
            }
    }



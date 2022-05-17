module Gen.List exposing (all, any, append, call_, concat, concatMap, drop, filter, filterMap, foldl, foldr, head, indexedMap, intersperse, isEmpty, length, map, map2, map3, map4, map5, maximum, member, minimum, moduleName_, partition, product, range, repeat, reverse, singleton, sort, sortBy, sortWith, sum, tail, take, unzip, values_)

{-| 
@docs moduleName_, singleton, repeat, range, map, indexedMap, foldl, foldr, filter, filterMap, length, reverse, member, all, any, maximum, minimum, sum, product, append, concat, concatMap, intersperse, map2, map3, map4, map5, sort, sortBy, sortWith, isEmpty, head, tail, take, drop, partition, unzip, call_, values_
-}


import Elm
import Elm.Annotation as Type


{-| The name of this module. -}
moduleName_ : List String
moduleName_ =
    [ "List" ]


{-| Create a list with only one element:

    singleton 1234 == [1234]
    singleton "hi" == ["hi"]

singleton: a -> List a
-}
singleton : Elm.Expression -> Elm.Expression
singleton arg =
    Elm.apply
        (Elm.value
            { importFrom = [ "List" ]
            , name = "singleton"
            , annotation =
                Just (Type.function [ Type.var "a" ] (Type.list (Type.var "a")))
            }
        )
        [ arg ]


{-| Create a list with *n* copies of a value:

    repeat 3 (0,0) == [(0,0),(0,0),(0,0)]

repeat: Int -> a -> List a
-}
repeat : Int -> Elm.Expression -> Elm.Expression
repeat arg arg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "List" ]
            , name = "repeat"
            , annotation =
                Just
                    (Type.function
                        [ Type.int, Type.var "a" ]
                        (Type.list (Type.var "a"))
                    )
            }
        )
        [ Elm.int arg, arg0 ]


{-| Create a list of numbers, every element increasing by one.
You give the lowest and highest number that should be in the list.

    range 3 6 == [3, 4, 5, 6]
    range 3 3 == [3]
    range 6 3 == []

range: Int -> Int -> List Int
-}
range : Int -> Int -> Elm.Expression
range arg arg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "List" ]
            , name = "range"
            , annotation =
                Just (Type.function [ Type.int, Type.int ] (Type.list Type.int))
            }
        )
        [ Elm.int arg, Elm.int arg0 ]


{-| Apply a function to every element of a list.

    map sqrt [1,4,9] == [1,2,3]

    map not [True,False,True] == [False,True,False]

So `map func [ a, b, c ]` is the same as `[ func a, func b, func c ]`

map: (a -> b) -> List a -> List b
-}
map :
    (Elm.Expression -> Elm.Expression) -> List Elm.Expression -> Elm.Expression
map arg arg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "List" ]
            , name = "map"
            , annotation =
                Just
                    (Type.function
                        [ Type.function [ Type.var "a" ] (Type.var "b")
                        , Type.list (Type.var "a")
                        ]
                        (Type.list (Type.var "b"))
                    )
            }
        )
        [ Elm.functionReduced "unpack" arg, Elm.list arg0 ]


{-| Same as `map` but the function is also applied to the index of each
element (starting at zero).

    indexedMap Tuple.pair ["Tom","Sue","Bob"] == [ (0,"Tom"), (1,"Sue"), (2,"Bob") ]

indexedMap: (Int -> a -> b) -> List a -> List b
-}
indexedMap :
    (Elm.Expression -> Elm.Expression -> Elm.Expression)
    -> List Elm.Expression
    -> Elm.Expression
indexedMap arg arg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "List" ]
            , name = "indexedMap"
            , annotation =
                Just
                    (Type.function
                        [ Type.function
                            [ Type.int, Type.var "a" ]
                            (Type.var "b")
                        , Type.list (Type.var "a")
                        ]
                        (Type.list (Type.var "b"))
                    )
            }
        )
        [ Elm.functionReduced
            "unpack"
            (\unpack -> Elm.functionReduced "unpack" (arg unpack))
        , Elm.list arg0
        ]


{-| Reduce a list from the left.

    foldl (+)  0  [1,2,3] == 6
    foldl (::) [] [1,2,3] == [3,2,1]

So `foldl step state [1,2,3]` is like saying:

    state
      |> step 1
      |> step 2
      |> step 3

foldl: (a -> b -> b) -> b -> List a -> b
-}
foldl :
    (Elm.Expression -> Elm.Expression -> Elm.Expression)
    -> Elm.Expression
    -> List Elm.Expression
    -> Elm.Expression
foldl arg arg0 arg1 =
    Elm.apply
        (Elm.value
            { importFrom = [ "List" ]
            , name = "foldl"
            , annotation =
                Just
                    (Type.function
                        [ Type.function
                            [ Type.var "a", Type.var "b" ]
                            (Type.var "b")
                        , Type.var "b"
                        , Type.list (Type.var "a")
                        ]
                        (Type.var "b")
                    )
            }
        )
        [ Elm.functionReduced
            "unpack"
            (\unpack -> Elm.functionReduced "unpack" (arg unpack))
        , arg0
        , Elm.list arg1
        ]


{-| Reduce a list from the right.

    foldr (+)  0  [1,2,3] == 6
    foldr (::) [] [1,2,3] == [1,2,3]

So `foldr step state [1,2,3]` is like saying:

    state
      |> step 3
      |> step 2
      |> step 1

foldr: (a -> b -> b) -> b -> List a -> b
-}
foldr :
    (Elm.Expression -> Elm.Expression -> Elm.Expression)
    -> Elm.Expression
    -> List Elm.Expression
    -> Elm.Expression
foldr arg arg0 arg1 =
    Elm.apply
        (Elm.value
            { importFrom = [ "List" ]
            , name = "foldr"
            , annotation =
                Just
                    (Type.function
                        [ Type.function
                            [ Type.var "a", Type.var "b" ]
                            (Type.var "b")
                        , Type.var "b"
                        , Type.list (Type.var "a")
                        ]
                        (Type.var "b")
                    )
            }
        )
        [ Elm.functionReduced
            "unpack"
            (\unpack -> Elm.functionReduced "unpack" (arg unpack))
        , arg0
        , Elm.list arg1
        ]


{-| Keep elements that satisfy the test.

    filter isEven [1,2,3,4,5,6] == [2,4,6]

filter: (a -> Bool) -> List a -> List a
-}
filter :
    (Elm.Expression -> Elm.Expression) -> List Elm.Expression -> Elm.Expression
filter arg arg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "List" ]
            , name = "filter"
            , annotation =
                Just
                    (Type.function
                        [ Type.function [ Type.var "a" ] Type.bool
                        , Type.list (Type.var "a")
                        ]
                        (Type.list (Type.var "a"))
                    )
            }
        )
        [ Elm.functionReduced "unpack" arg, Elm.list arg0 ]


{-| Filter out certain values. For example, maybe you have a bunch of strings
from an untrusted source and you want to turn them into numbers:

    numbers : List Int
    numbers =
      filterMap String.toInt ["3", "hi", "12", "4th", "May"]

    -- numbers == [3, 12]

filterMap: (a -> Maybe b) -> List a -> List b
-}
filterMap :
    (Elm.Expression -> Elm.Expression) -> List Elm.Expression -> Elm.Expression
filterMap arg arg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "List" ]
            , name = "filterMap"
            , annotation =
                Just
                    (Type.function
                        [ Type.function
                            [ Type.var "a" ]
                            (Type.maybe (Type.var "b"))
                        , Type.list (Type.var "a")
                        ]
                        (Type.list (Type.var "b"))
                    )
            }
        )
        [ Elm.functionReduced "unpack" arg, Elm.list arg0 ]


{-| Determine the length of a list.

    length [1,2,3] == 3

length: List a -> Int
-}
length : List Elm.Expression -> Elm.Expression
length arg =
    Elm.apply
        (Elm.value
            { importFrom = [ "List" ]
            , name = "length"
            , annotation =
                Just (Type.function [ Type.list (Type.var "a") ] Type.int)
            }
        )
        [ Elm.list arg ]


{-| Reverse a list.

    reverse [1,2,3,4] == [4,3,2,1]

reverse: List a -> List a
-}
reverse : List Elm.Expression -> Elm.Expression
reverse arg =
    Elm.apply
        (Elm.value
            { importFrom = [ "List" ]
            , name = "reverse"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.var "a") ]
                        (Type.list (Type.var "a"))
                    )
            }
        )
        [ Elm.list arg ]


{-| Figure out whether a list contains a value.

    member 9 [1,2,3,4] == False
    member 4 [1,2,3,4] == True

member: a -> List a -> Bool
-}
member : Elm.Expression -> List Elm.Expression -> Elm.Expression
member arg arg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "List" ]
            , name = "member"
            , annotation =
                Just
                    (Type.function
                        [ Type.var "a", Type.list (Type.var "a") ]
                        Type.bool
                    )
            }
        )
        [ arg, Elm.list arg0 ]


{-| Determine if all elements satisfy some test.

    all isEven [2,4] == True
    all isEven [2,3] == False
    all isEven [] == True

all: (a -> Bool) -> List a -> Bool
-}
all :
    (Elm.Expression -> Elm.Expression) -> List Elm.Expression -> Elm.Expression
all arg arg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "List" ]
            , name = "all"
            , annotation =
                Just
                    (Type.function
                        [ Type.function [ Type.var "a" ] Type.bool
                        , Type.list (Type.var "a")
                        ]
                        Type.bool
                    )
            }
        )
        [ Elm.functionReduced "unpack" arg, Elm.list arg0 ]


{-| Determine if any elements satisfy some test.

    any isEven [2,3] == True
    any isEven [1,3] == False
    any isEven [] == False

any: (a -> Bool) -> List a -> Bool
-}
any :
    (Elm.Expression -> Elm.Expression) -> List Elm.Expression -> Elm.Expression
any arg arg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "List" ]
            , name = "any"
            , annotation =
                Just
                    (Type.function
                        [ Type.function [ Type.var "a" ] Type.bool
                        , Type.list (Type.var "a")
                        ]
                        Type.bool
                    )
            }
        )
        [ Elm.functionReduced "unpack" arg, Elm.list arg0 ]


{-| Find the maximum element in a non-empty list.

    maximum [1,4,2] == Just 4
    maximum []      == Nothing

maximum: List comparable -> Maybe comparable
-}
maximum : List Elm.Expression -> Elm.Expression
maximum arg =
    Elm.apply
        (Elm.value
            { importFrom = [ "List" ]
            , name = "maximum"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.var "comparable") ]
                        (Type.maybe (Type.var "comparable"))
                    )
            }
        )
        [ Elm.list arg ]


{-| Find the minimum element in a non-empty list.

    minimum [3,2,1] == Just 1
    minimum []      == Nothing

minimum: List comparable -> Maybe comparable
-}
minimum : List Elm.Expression -> Elm.Expression
minimum arg =
    Elm.apply
        (Elm.value
            { importFrom = [ "List" ]
            , name = "minimum"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.var "comparable") ]
                        (Type.maybe (Type.var "comparable"))
                    )
            }
        )
        [ Elm.list arg ]


{-| Get the sum of the list elements.

    sum [1,2,3] == 6
    sum [1,1,1] == 3
    sum []      == 0

sum: List number -> number
-}
sum : List Elm.Expression -> Elm.Expression
sum arg =
    Elm.apply
        (Elm.value
            { importFrom = [ "List" ]
            , name = "sum"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.var "number") ]
                        (Type.var "number")
                    )
            }
        )
        [ Elm.list arg ]


{-| Get the product of the list elements.

    product [2,2,2] == 8
    product [3,3,3] == 27
    product []      == 1

product: List number -> number
-}
product : List Elm.Expression -> Elm.Expression
product arg =
    Elm.apply
        (Elm.value
            { importFrom = [ "List" ]
            , name = "product"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.var "number") ]
                        (Type.var "number")
                    )
            }
        )
        [ Elm.list arg ]


{-| Put two lists together.

    append [1,1,2] [3,5,8] == [1,1,2,3,5,8]
    append ['a','b'] ['c'] == ['a','b','c']

You can also use [the `(++)` operator](Basics#++) to append lists.

append: List a -> List a -> List a
-}
append : List Elm.Expression -> List Elm.Expression -> Elm.Expression
append arg arg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "List" ]
            , name = "append"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.var "a"), Type.list (Type.var "a") ]
                        (Type.list (Type.var "a"))
                    )
            }
        )
        [ Elm.list arg, Elm.list arg0 ]


{-| Concatenate a bunch of lists into a single list:

    concat [[1,2],[3],[4,5]] == [1,2,3,4,5]

concat: List (List a) -> List a
-}
concat : List (List Elm.Expression) -> Elm.Expression
concat arg =
    Elm.apply
        (Elm.value
            { importFrom = [ "List" ]
            , name = "concat"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.list (Type.var "a")) ]
                        (Type.list (Type.var "a"))
                    )
            }
        )
        [ Elm.list (List.map Elm.list arg) ]


{-| Map a given function onto a list and flatten the resulting lists.

    concatMap f xs == concat (map f xs)

concatMap: (a -> List b) -> List a -> List b
-}
concatMap :
    (Elm.Expression -> Elm.Expression) -> List Elm.Expression -> Elm.Expression
concatMap arg arg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "List" ]
            , name = "concatMap"
            , annotation =
                Just
                    (Type.function
                        [ Type.function
                            [ Type.var "a" ]
                            (Type.list (Type.var "b"))
                        , Type.list (Type.var "a")
                        ]
                        (Type.list (Type.var "b"))
                    )
            }
        )
        [ Elm.functionReduced "unpack" arg, Elm.list arg0 ]


{-| Places the given value between all members of the given list.

    intersperse "on" ["turtles","turtles","turtles"] == ["turtles","on","turtles","on","turtles"]

intersperse: a -> List a -> List a
-}
intersperse : Elm.Expression -> List Elm.Expression -> Elm.Expression
intersperse arg arg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "List" ]
            , name = "intersperse"
            , annotation =
                Just
                    (Type.function
                        [ Type.var "a", Type.list (Type.var "a") ]
                        (Type.list (Type.var "a"))
                    )
            }
        )
        [ arg, Elm.list arg0 ]


{-| Combine two lists, combining them with the given function.
If one list is longer, the extra elements are dropped.

    totals : List Int -> List Int -> List Int
    totals xs ys =
      List.map2 (+) xs ys

    -- totals [1,2,3] [4,5,6] == [5,7,9]

    pairs : List a -> List b -> List (a,b)
    pairs xs ys =
      List.map2 Tuple.pair xs ys

    -- pairs ["alice","bob","chuck"] [2,5,7,8]
    --   == [("alice",2),("bob",5),("chuck",7)]

map2: (a -> b -> result) -> List a -> List b -> List result
-}
map2 :
    (Elm.Expression -> Elm.Expression -> Elm.Expression)
    -> List Elm.Expression
    -> List Elm.Expression
    -> Elm.Expression
map2 arg arg0 arg1 =
    Elm.apply
        (Elm.value
            { importFrom = [ "List" ]
            , name = "map2"
            , annotation =
                Just
                    (Type.function
                        [ Type.function
                            [ Type.var "a", Type.var "b" ]
                            (Type.var "result")
                        , Type.list (Type.var "a")
                        , Type.list (Type.var "b")
                        ]
                        (Type.list (Type.var "result"))
                    )
            }
        )
        [ Elm.functionReduced
            "unpack"
            (\unpack -> Elm.functionReduced "unpack" (arg unpack))
        , Elm.list arg0
        , Elm.list arg1
        ]


{-| map3: (a -> b -> c -> result) -> List a -> List b -> List c -> List result -}
map3 :
    (Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression)
    -> List Elm.Expression
    -> List Elm.Expression
    -> List Elm.Expression
    -> Elm.Expression
map3 arg arg0 arg1 arg2 =
    Elm.apply
        (Elm.value
            { importFrom = [ "List" ]
            , name = "map3"
            , annotation =
                Just
                    (Type.function
                        [ Type.function
                            [ Type.var "a", Type.var "b", Type.var "c" ]
                            (Type.var "result")
                        , Type.list (Type.var "a")
                        , Type.list (Type.var "b")
                        , Type.list (Type.var "c")
                        ]
                        (Type.list (Type.var "result"))
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
        , Elm.list arg0
        , Elm.list arg1
        , Elm.list arg2
        ]


{-| map4: 
    (a -> b -> c -> d -> result)
    -> List a
    -> List b
    -> List c
    -> List d
    -> List result
-}
map4 :
    (Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
    -> Elm.Expression)
    -> List Elm.Expression
    -> List Elm.Expression
    -> List Elm.Expression
    -> List Elm.Expression
    -> Elm.Expression
map4 arg arg0 arg1 arg2 arg3 =
    Elm.apply
        (Elm.value
            { importFrom = [ "List" ]
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
                        , Type.list (Type.var "a")
                        , Type.list (Type.var "b")
                        , Type.list (Type.var "c")
                        , Type.list (Type.var "d")
                        ]
                        (Type.list (Type.var "result"))
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
        , Elm.list arg0
        , Elm.list arg1
        , Elm.list arg2
        , Elm.list arg3
        ]


{-| map5: 
    (a -> b -> c -> d -> e -> result)
    -> List a
    -> List b
    -> List c
    -> List d
    -> List e
    -> List result
-}
map5 :
    (Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
    -> Elm.Expression)
    -> List Elm.Expression
    -> List Elm.Expression
    -> List Elm.Expression
    -> List Elm.Expression
    -> List Elm.Expression
    -> Elm.Expression
map5 arg arg0 arg1 arg2 arg3 arg4 =
    Elm.apply
        (Elm.value
            { importFrom = [ "List" ]
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
                        , Type.list (Type.var "a")
                        , Type.list (Type.var "b")
                        , Type.list (Type.var "c")
                        , Type.list (Type.var "d")
                        , Type.list (Type.var "e")
                        ]
                        (Type.list (Type.var "result"))
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
        , Elm.list arg0
        , Elm.list arg1
        , Elm.list arg2
        , Elm.list arg3
        , Elm.list arg4
        ]


{-| Sort values from lowest to highest

    sort [3,1,5] == [1,3,5]

sort: List comparable -> List comparable
-}
sort : List Elm.Expression -> Elm.Expression
sort arg =
    Elm.apply
        (Elm.value
            { importFrom = [ "List" ]
            , name = "sort"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.var "comparable") ]
                        (Type.list (Type.var "comparable"))
                    )
            }
        )
        [ Elm.list arg ]


{-| Sort values by a derived property.

    alice = { name="Alice", height=1.62 }
    bob   = { name="Bob"  , height=1.85 }
    chuck = { name="Chuck", height=1.76 }

    sortBy .name   [chuck,alice,bob] == [alice,bob,chuck]
    sortBy .height [chuck,alice,bob] == [alice,chuck,bob]

    sortBy String.length ["mouse","cat"] == ["cat","mouse"]

sortBy: (a -> comparable) -> List a -> List a
-}
sortBy :
    (Elm.Expression -> Elm.Expression) -> List Elm.Expression -> Elm.Expression
sortBy arg arg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "List" ]
            , name = "sortBy"
            , annotation =
                Just
                    (Type.function
                        [ Type.function [ Type.var "a" ] (Type.var "comparable")
                        , Type.list (Type.var "a")
                        ]
                        (Type.list (Type.var "a"))
                    )
            }
        )
        [ Elm.functionReduced "unpack" arg, Elm.list arg0 ]


{-| Sort values with a custom comparison function.

    sortWith flippedComparison [1,2,3,4,5] == [5,4,3,2,1]

    flippedComparison a b =
        case compare a b of
          LT -> GT
          EQ -> EQ
          GT -> LT

This is also the most general sort function, allowing you
to define any other: `sort == sortWith compare`

sortWith: (a -> a -> Basics.Order) -> List a -> List a
-}
sortWith :
    (Elm.Expression -> Elm.Expression -> Elm.Expression)
    -> List Elm.Expression
    -> Elm.Expression
sortWith arg arg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "List" ]
            , name = "sortWith"
            , annotation =
                Just
                    (Type.function
                        [ Type.function
                            [ Type.var "a", Type.var "a" ]
                            (Type.namedWith [ "Basics" ] "Order" [])
                        , Type.list (Type.var "a")
                        ]
                        (Type.list (Type.var "a"))
                    )
            }
        )
        [ Elm.functionReduced
            "unpack"
            (\unpack -> Elm.functionReduced "unpack" (arg unpack))
        , Elm.list arg0
        ]


{-| Determine if a list is empty.

    isEmpty [] == True

**Note:** It is usually preferable to use a `case` to test this so you do not
forget to handle the `(x :: xs)` case as well!

isEmpty: List a -> Bool
-}
isEmpty : List Elm.Expression -> Elm.Expression
isEmpty arg =
    Elm.apply
        (Elm.value
            { importFrom = [ "List" ]
            , name = "isEmpty"
            , annotation =
                Just (Type.function [ Type.list (Type.var "a") ] Type.bool)
            }
        )
        [ Elm.list arg ]


{-| Extract the first element of a list.

    head [1,2,3] == Just 1
    head [] == Nothing

**Note:** It is usually preferable to use a `case` to deconstruct a `List`
because it gives you `(x :: xs)` and you can work with both subparts.

head: List a -> Maybe a
-}
head : List Elm.Expression -> Elm.Expression
head arg =
    Elm.apply
        (Elm.value
            { importFrom = [ "List" ]
            , name = "head"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.var "a") ]
                        (Type.maybe (Type.var "a"))
                    )
            }
        )
        [ Elm.list arg ]


{-| Extract the rest of the list.

    tail [1,2,3] == Just [2,3]
    tail [] == Nothing

**Note:** It is usually preferable to use a `case` to deconstruct a `List`
because it gives you `(x :: xs)` and you can work with both subparts.

tail: List a -> Maybe (List a)
-}
tail : List Elm.Expression -> Elm.Expression
tail arg =
    Elm.apply
        (Elm.value
            { importFrom = [ "List" ]
            , name = "tail"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.var "a") ]
                        (Type.maybe (Type.list (Type.var "a")))
                    )
            }
        )
        [ Elm.list arg ]


{-| Take the first *n* members of a list.

    take 2 [1,2,3,4] == [1,2]

take: Int -> List a -> List a
-}
take : Int -> List Elm.Expression -> Elm.Expression
take arg arg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "List" ]
            , name = "take"
            , annotation =
                Just
                    (Type.function
                        [ Type.int, Type.list (Type.var "a") ]
                        (Type.list (Type.var "a"))
                    )
            }
        )
        [ Elm.int arg, Elm.list arg0 ]


{-| Drop the first *n* members of a list.

    drop 2 [1,2,3,4] == [3,4]

drop: Int -> List a -> List a
-}
drop : Int -> List Elm.Expression -> Elm.Expression
drop arg arg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "List" ]
            , name = "drop"
            , annotation =
                Just
                    (Type.function
                        [ Type.int, Type.list (Type.var "a") ]
                        (Type.list (Type.var "a"))
                    )
            }
        )
        [ Elm.int arg, Elm.list arg0 ]


{-| Partition a list based on some test. The first list contains all values
that satisfy the test, and the second list contains all the value that do not.

    partition (\x -> x < 3) [0,1,2,3,4,5] == ([0,1,2], [3,4,5])
    partition isEven        [0,1,2,3,4,5] == ([0,2,4], [1,3,5])

partition: (a -> Bool) -> List a -> ( List a, List a )
-}
partition :
    (Elm.Expression -> Elm.Expression) -> List Elm.Expression -> Elm.Expression
partition arg arg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "List" ]
            , name = "partition"
            , annotation =
                Just
                    (Type.function
                        [ Type.function [ Type.var "a" ] Type.bool
                        , Type.list (Type.var "a")
                        ]
                        (Type.tuple
                            (Type.list (Type.var "a"))
                            (Type.list (Type.var "a"))
                        )
                    )
            }
        )
        [ Elm.functionReduced "unpack" arg, Elm.list arg0 ]


{-| Decompose a list of tuples into a tuple of lists.

    unzip [(0, True), (17, False), (1337, True)] == ([0,17,1337], [True,False,True])

unzip: List ( a, b ) -> ( List a, List b )
-}
unzip : List Elm.Expression -> Elm.Expression
unzip arg =
    Elm.apply
        (Elm.value
            { importFrom = [ "List" ]
            , name = "unzip"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.tuple (Type.var "a") (Type.var "b")) ]
                        (Type.tuple
                            (Type.list (Type.var "a"))
                            (Type.list (Type.var "b"))
                        )
                    )
            }
        )
        [ Elm.list arg ]


call_ :
    { singleton : Elm.Expression -> Elm.Expression
    , repeat : Elm.Expression -> Elm.Expression -> Elm.Expression
    , range : Elm.Expression -> Elm.Expression -> Elm.Expression
    , map : Elm.Expression -> Elm.Expression -> Elm.Expression
    , indexedMap : Elm.Expression -> Elm.Expression -> Elm.Expression
    , foldl :
        Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
    , foldr :
        Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
    , filter : Elm.Expression -> Elm.Expression -> Elm.Expression
    , filterMap : Elm.Expression -> Elm.Expression -> Elm.Expression
    , length : Elm.Expression -> Elm.Expression
    , reverse : Elm.Expression -> Elm.Expression
    , member : Elm.Expression -> Elm.Expression -> Elm.Expression
    , all : Elm.Expression -> Elm.Expression -> Elm.Expression
    , any : Elm.Expression -> Elm.Expression -> Elm.Expression
    , maximum : Elm.Expression -> Elm.Expression
    , minimum : Elm.Expression -> Elm.Expression
    , sum : Elm.Expression -> Elm.Expression
    , product : Elm.Expression -> Elm.Expression
    , append : Elm.Expression -> Elm.Expression -> Elm.Expression
    , concat : Elm.Expression -> Elm.Expression
    , concatMap : Elm.Expression -> Elm.Expression -> Elm.Expression
    , intersperse : Elm.Expression -> Elm.Expression -> Elm.Expression
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
    , sort : Elm.Expression -> Elm.Expression
    , sortBy : Elm.Expression -> Elm.Expression -> Elm.Expression
    , sortWith : Elm.Expression -> Elm.Expression -> Elm.Expression
    , isEmpty : Elm.Expression -> Elm.Expression
    , head : Elm.Expression -> Elm.Expression
    , tail : Elm.Expression -> Elm.Expression
    , take : Elm.Expression -> Elm.Expression -> Elm.Expression
    , drop : Elm.Expression -> Elm.Expression -> Elm.Expression
    , partition : Elm.Expression -> Elm.Expression -> Elm.Expression
    , unzip : Elm.Expression -> Elm.Expression
    }
call_ =
    { singleton =
        \arg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "List" ]
                    , name = "singleton"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.var "a" ]
                                (Type.list (Type.var "a"))
                            )
                    }
                )
                [ arg ]
    , repeat =
        \arg arg1 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "List" ]
                    , name = "repeat"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.int, Type.var "a" ]
                                (Type.list (Type.var "a"))
                            )
                    }
                )
                [ arg, arg1 ]
    , range =
        \arg arg2 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "List" ]
                    , name = "range"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.int, Type.int ]
                                (Type.list Type.int)
                            )
                    }
                )
                [ arg, arg2 ]
    , map =
        \arg arg3 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "List" ]
                    , name = "map"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.function [ Type.var "a" ] (Type.var "b")
                                , Type.list (Type.var "a")
                                ]
                                (Type.list (Type.var "b"))
                            )
                    }
                )
                [ arg, arg3 ]
    , indexedMap =
        \arg arg4 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "List" ]
                    , name = "indexedMap"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.function
                                    [ Type.int, Type.var "a" ]
                                    (Type.var "b")
                                , Type.list (Type.var "a")
                                ]
                                (Type.list (Type.var "b"))
                            )
                    }
                )
                [ arg, arg4 ]
    , foldl =
        \arg arg5 arg6 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "List" ]
                    , name = "foldl"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.function
                                    [ Type.var "a", Type.var "b" ]
                                    (Type.var "b")
                                , Type.var "b"
                                , Type.list (Type.var "a")
                                ]
                                (Type.var "b")
                            )
                    }
                )
                [ arg, arg5, arg6 ]
    , foldr =
        \arg arg6 arg7 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "List" ]
                    , name = "foldr"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.function
                                    [ Type.var "a", Type.var "b" ]
                                    (Type.var "b")
                                , Type.var "b"
                                , Type.list (Type.var "a")
                                ]
                                (Type.var "b")
                            )
                    }
                )
                [ arg, arg6, arg7 ]
    , filter =
        \arg arg7 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "List" ]
                    , name = "filter"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.function [ Type.var "a" ] Type.bool
                                , Type.list (Type.var "a")
                                ]
                                (Type.list (Type.var "a"))
                            )
                    }
                )
                [ arg, arg7 ]
    , filterMap =
        \arg arg8 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "List" ]
                    , name = "filterMap"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.function
                                    [ Type.var "a" ]
                                    (Type.maybe (Type.var "b"))
                                , Type.list (Type.var "a")
                                ]
                                (Type.list (Type.var "b"))
                            )
                    }
                )
                [ arg, arg8 ]
    , length =
        \arg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "List" ]
                    , name = "length"
                    , annotation =
                        Just
                            (Type.function [ Type.list (Type.var "a") ] Type.int
                            )
                    }
                )
                [ arg ]
    , reverse =
        \arg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "List" ]
                    , name = "reverse"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.list (Type.var "a") ]
                                (Type.list (Type.var "a"))
                            )
                    }
                )
                [ arg ]
    , member =
        \arg arg11 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "List" ]
                    , name = "member"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.var "a", Type.list (Type.var "a") ]
                                Type.bool
                            )
                    }
                )
                [ arg, arg11 ]
    , all =
        \arg arg12 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "List" ]
                    , name = "all"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.function [ Type.var "a" ] Type.bool
                                , Type.list (Type.var "a")
                                ]
                                Type.bool
                            )
                    }
                )
                [ arg, arg12 ]
    , any =
        \arg arg13 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "List" ]
                    , name = "any"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.function [ Type.var "a" ] Type.bool
                                , Type.list (Type.var "a")
                                ]
                                Type.bool
                            )
                    }
                )
                [ arg, arg13 ]
    , maximum =
        \arg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "List" ]
                    , name = "maximum"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.list (Type.var "comparable") ]
                                (Type.maybe (Type.var "comparable"))
                            )
                    }
                )
                [ arg ]
    , minimum =
        \arg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "List" ]
                    , name = "minimum"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.list (Type.var "comparable") ]
                                (Type.maybe (Type.var "comparable"))
                            )
                    }
                )
                [ arg ]
    , sum =
        \arg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "List" ]
                    , name = "sum"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.list (Type.var "number") ]
                                (Type.var "number")
                            )
                    }
                )
                [ arg ]
    , product =
        \arg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "List" ]
                    , name = "product"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.list (Type.var "number") ]
                                (Type.var "number")
                            )
                    }
                )
                [ arg ]
    , append =
        \arg arg18 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "List" ]
                    , name = "append"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.list (Type.var "a")
                                , Type.list (Type.var "a")
                                ]
                                (Type.list (Type.var "a"))
                            )
                    }
                )
                [ arg, arg18 ]
    , concat =
        \arg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "List" ]
                    , name = "concat"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.list (Type.list (Type.var "a")) ]
                                (Type.list (Type.var "a"))
                            )
                    }
                )
                [ arg ]
    , concatMap =
        \arg arg20 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "List" ]
                    , name = "concatMap"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.function
                                    [ Type.var "a" ]
                                    (Type.list (Type.var "b"))
                                , Type.list (Type.var "a")
                                ]
                                (Type.list (Type.var "b"))
                            )
                    }
                )
                [ arg, arg20 ]
    , intersperse =
        \arg arg21 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "List" ]
                    , name = "intersperse"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.var "a", Type.list (Type.var "a") ]
                                (Type.list (Type.var "a"))
                            )
                    }
                )
                [ arg, arg21 ]
    , map2 =
        \arg arg22 arg23 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "List" ]
                    , name = "map2"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.function
                                    [ Type.var "a", Type.var "b" ]
                                    (Type.var "result")
                                , Type.list (Type.var "a")
                                , Type.list (Type.var "b")
                                ]
                                (Type.list (Type.var "result"))
                            )
                    }
                )
                [ arg, arg22, arg23 ]
    , map3 =
        \arg arg23 arg24 arg25 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "List" ]
                    , name = "map3"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.function
                                    [ Type.var "a", Type.var "b", Type.var "c" ]
                                    (Type.var "result")
                                , Type.list (Type.var "a")
                                , Type.list (Type.var "b")
                                , Type.list (Type.var "c")
                                ]
                                (Type.list (Type.var "result"))
                            )
                    }
                )
                [ arg, arg23, arg24, arg25 ]
    , map4 =
        \arg arg24 arg25 arg26 arg27 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "List" ]
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
                                , Type.list (Type.var "a")
                                , Type.list (Type.var "b")
                                , Type.list (Type.var "c")
                                , Type.list (Type.var "d")
                                ]
                                (Type.list (Type.var "result"))
                            )
                    }
                )
                [ arg, arg24, arg25, arg26, arg27 ]
    , map5 =
        \arg arg25 arg26 arg27 arg28 arg29 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "List" ]
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
                                , Type.list (Type.var "a")
                                , Type.list (Type.var "b")
                                , Type.list (Type.var "c")
                                , Type.list (Type.var "d")
                                , Type.list (Type.var "e")
                                ]
                                (Type.list (Type.var "result"))
                            )
                    }
                )
                [ arg, arg25, arg26, arg27, arg28, arg29 ]
    , sort =
        \arg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "List" ]
                    , name = "sort"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.list (Type.var "comparable") ]
                                (Type.list (Type.var "comparable"))
                            )
                    }
                )
                [ arg ]
    , sortBy =
        \arg arg27 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "List" ]
                    , name = "sortBy"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.function
                                    [ Type.var "a" ]
                                    (Type.var "comparable")
                                , Type.list (Type.var "a")
                                ]
                                (Type.list (Type.var "a"))
                            )
                    }
                )
                [ arg, arg27 ]
    , sortWith =
        \arg arg28 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "List" ]
                    , name = "sortWith"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.function
                                    [ Type.var "a", Type.var "a" ]
                                    (Type.namedWith [ "Basics" ] "Order" [])
                                , Type.list (Type.var "a")
                                ]
                                (Type.list (Type.var "a"))
                            )
                    }
                )
                [ arg, arg28 ]
    , isEmpty =
        \arg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "List" ]
                    , name = "isEmpty"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.list (Type.var "a") ]
                                Type.bool
                            )
                    }
                )
                [ arg ]
    , head =
        \arg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "List" ]
                    , name = "head"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.list (Type.var "a") ]
                                (Type.maybe (Type.var "a"))
                            )
                    }
                )
                [ arg ]
    , tail =
        \arg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "List" ]
                    , name = "tail"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.list (Type.var "a") ]
                                (Type.maybe (Type.list (Type.var "a")))
                            )
                    }
                )
                [ arg ]
    , take =
        \arg arg32 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "List" ]
                    , name = "take"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.int, Type.list (Type.var "a") ]
                                (Type.list (Type.var "a"))
                            )
                    }
                )
                [ arg, arg32 ]
    , drop =
        \arg arg33 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "List" ]
                    , name = "drop"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.int, Type.list (Type.var "a") ]
                                (Type.list (Type.var "a"))
                            )
                    }
                )
                [ arg, arg33 ]
    , partition =
        \arg arg34 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "List" ]
                    , name = "partition"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.function [ Type.var "a" ] Type.bool
                                , Type.list (Type.var "a")
                                ]
                                (Type.tuple
                                    (Type.list (Type.var "a"))
                                    (Type.list (Type.var "a"))
                                )
                            )
                    }
                )
                [ arg, arg34 ]
    , unzip =
        \arg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "List" ]
                    , name = "unzip"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.list
                                    (Type.tuple (Type.var "a") (Type.var "b"))
                                ]
                                (Type.tuple
                                    (Type.list (Type.var "a"))
                                    (Type.list (Type.var "b"))
                                )
                            )
                    }
                )
                [ arg ]
    }


values_ :
    { singleton : Elm.Expression
    , repeat : Elm.Expression
    , range : Elm.Expression
    , map : Elm.Expression
    , indexedMap : Elm.Expression
    , foldl : Elm.Expression
    , foldr : Elm.Expression
    , filter : Elm.Expression
    , filterMap : Elm.Expression
    , length : Elm.Expression
    , reverse : Elm.Expression
    , member : Elm.Expression
    , all : Elm.Expression
    , any : Elm.Expression
    , maximum : Elm.Expression
    , minimum : Elm.Expression
    , sum : Elm.Expression
    , product : Elm.Expression
    , append : Elm.Expression
    , concat : Elm.Expression
    , concatMap : Elm.Expression
    , intersperse : Elm.Expression
    , map2 : Elm.Expression
    , map3 : Elm.Expression
    , map4 : Elm.Expression
    , map5 : Elm.Expression
    , sort : Elm.Expression
    , sortBy : Elm.Expression
    , sortWith : Elm.Expression
    , isEmpty : Elm.Expression
    , head : Elm.Expression
    , tail : Elm.Expression
    , take : Elm.Expression
    , drop : Elm.Expression
    , partition : Elm.Expression
    , unzip : Elm.Expression
    }
values_ =
    { singleton =
        Elm.value
            { importFrom = [ "List" ]
            , name = "singleton"
            , annotation =
                Just (Type.function [ Type.var "a" ] (Type.list (Type.var "a")))
            }
    , repeat =
        Elm.value
            { importFrom = [ "List" ]
            , name = "repeat"
            , annotation =
                Just
                    (Type.function
                        [ Type.int, Type.var "a" ]
                        (Type.list (Type.var "a"))
                    )
            }
    , range =
        Elm.value
            { importFrom = [ "List" ]
            , name = "range"
            , annotation =
                Just (Type.function [ Type.int, Type.int ] (Type.list Type.int))
            }
    , map =
        Elm.value
            { importFrom = [ "List" ]
            , name = "map"
            , annotation =
                Just
                    (Type.function
                        [ Type.function [ Type.var "a" ] (Type.var "b")
                        , Type.list (Type.var "a")
                        ]
                        (Type.list (Type.var "b"))
                    )
            }
    , indexedMap =
        Elm.value
            { importFrom = [ "List" ]
            , name = "indexedMap"
            , annotation =
                Just
                    (Type.function
                        [ Type.function
                            [ Type.int, Type.var "a" ]
                            (Type.var "b")
                        , Type.list (Type.var "a")
                        ]
                        (Type.list (Type.var "b"))
                    )
            }
    , foldl =
        Elm.value
            { importFrom = [ "List" ]
            , name = "foldl"
            , annotation =
                Just
                    (Type.function
                        [ Type.function
                            [ Type.var "a", Type.var "b" ]
                            (Type.var "b")
                        , Type.var "b"
                        , Type.list (Type.var "a")
                        ]
                        (Type.var "b")
                    )
            }
    , foldr =
        Elm.value
            { importFrom = [ "List" ]
            , name = "foldr"
            , annotation =
                Just
                    (Type.function
                        [ Type.function
                            [ Type.var "a", Type.var "b" ]
                            (Type.var "b")
                        , Type.var "b"
                        , Type.list (Type.var "a")
                        ]
                        (Type.var "b")
                    )
            }
    , filter =
        Elm.value
            { importFrom = [ "List" ]
            , name = "filter"
            , annotation =
                Just
                    (Type.function
                        [ Type.function [ Type.var "a" ] Type.bool
                        , Type.list (Type.var "a")
                        ]
                        (Type.list (Type.var "a"))
                    )
            }
    , filterMap =
        Elm.value
            { importFrom = [ "List" ]
            , name = "filterMap"
            , annotation =
                Just
                    (Type.function
                        [ Type.function
                            [ Type.var "a" ]
                            (Type.maybe (Type.var "b"))
                        , Type.list (Type.var "a")
                        ]
                        (Type.list (Type.var "b"))
                    )
            }
    , length =
        Elm.value
            { importFrom = [ "List" ]
            , name = "length"
            , annotation =
                Just (Type.function [ Type.list (Type.var "a") ] Type.int)
            }
    , reverse =
        Elm.value
            { importFrom = [ "List" ]
            , name = "reverse"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.var "a") ]
                        (Type.list (Type.var "a"))
                    )
            }
    , member =
        Elm.value
            { importFrom = [ "List" ]
            , name = "member"
            , annotation =
                Just
                    (Type.function
                        [ Type.var "a", Type.list (Type.var "a") ]
                        Type.bool
                    )
            }
    , all =
        Elm.value
            { importFrom = [ "List" ]
            , name = "all"
            , annotation =
                Just
                    (Type.function
                        [ Type.function [ Type.var "a" ] Type.bool
                        , Type.list (Type.var "a")
                        ]
                        Type.bool
                    )
            }
    , any =
        Elm.value
            { importFrom = [ "List" ]
            , name = "any"
            , annotation =
                Just
                    (Type.function
                        [ Type.function [ Type.var "a" ] Type.bool
                        , Type.list (Type.var "a")
                        ]
                        Type.bool
                    )
            }
    , maximum =
        Elm.value
            { importFrom = [ "List" ]
            , name = "maximum"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.var "comparable") ]
                        (Type.maybe (Type.var "comparable"))
                    )
            }
    , minimum =
        Elm.value
            { importFrom = [ "List" ]
            , name = "minimum"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.var "comparable") ]
                        (Type.maybe (Type.var "comparable"))
                    )
            }
    , sum =
        Elm.value
            { importFrom = [ "List" ]
            , name = "sum"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.var "number") ]
                        (Type.var "number")
                    )
            }
    , product =
        Elm.value
            { importFrom = [ "List" ]
            , name = "product"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.var "number") ]
                        (Type.var "number")
                    )
            }
    , append =
        Elm.value
            { importFrom = [ "List" ]
            , name = "append"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.var "a"), Type.list (Type.var "a") ]
                        (Type.list (Type.var "a"))
                    )
            }
    , concat =
        Elm.value
            { importFrom = [ "List" ]
            , name = "concat"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.list (Type.var "a")) ]
                        (Type.list (Type.var "a"))
                    )
            }
    , concatMap =
        Elm.value
            { importFrom = [ "List" ]
            , name = "concatMap"
            , annotation =
                Just
                    (Type.function
                        [ Type.function
                            [ Type.var "a" ]
                            (Type.list (Type.var "b"))
                        , Type.list (Type.var "a")
                        ]
                        (Type.list (Type.var "b"))
                    )
            }
    , intersperse =
        Elm.value
            { importFrom = [ "List" ]
            , name = "intersperse"
            , annotation =
                Just
                    (Type.function
                        [ Type.var "a", Type.list (Type.var "a") ]
                        (Type.list (Type.var "a"))
                    )
            }
    , map2 =
        Elm.value
            { importFrom = [ "List" ]
            , name = "map2"
            , annotation =
                Just
                    (Type.function
                        [ Type.function
                            [ Type.var "a", Type.var "b" ]
                            (Type.var "result")
                        , Type.list (Type.var "a")
                        , Type.list (Type.var "b")
                        ]
                        (Type.list (Type.var "result"))
                    )
            }
    , map3 =
        Elm.value
            { importFrom = [ "List" ]
            , name = "map3"
            , annotation =
                Just
                    (Type.function
                        [ Type.function
                            [ Type.var "a", Type.var "b", Type.var "c" ]
                            (Type.var "result")
                        , Type.list (Type.var "a")
                        , Type.list (Type.var "b")
                        , Type.list (Type.var "c")
                        ]
                        (Type.list (Type.var "result"))
                    )
            }
    , map4 =
        Elm.value
            { importFrom = [ "List" ]
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
                        , Type.list (Type.var "a")
                        , Type.list (Type.var "b")
                        , Type.list (Type.var "c")
                        , Type.list (Type.var "d")
                        ]
                        (Type.list (Type.var "result"))
                    )
            }
    , map5 =
        Elm.value
            { importFrom = [ "List" ]
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
                        , Type.list (Type.var "a")
                        , Type.list (Type.var "b")
                        , Type.list (Type.var "c")
                        , Type.list (Type.var "d")
                        , Type.list (Type.var "e")
                        ]
                        (Type.list (Type.var "result"))
                    )
            }
    , sort =
        Elm.value
            { importFrom = [ "List" ]
            , name = "sort"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.var "comparable") ]
                        (Type.list (Type.var "comparable"))
                    )
            }
    , sortBy =
        Elm.value
            { importFrom = [ "List" ]
            , name = "sortBy"
            , annotation =
                Just
                    (Type.function
                        [ Type.function [ Type.var "a" ] (Type.var "comparable")
                        , Type.list (Type.var "a")
                        ]
                        (Type.list (Type.var "a"))
                    )
            }
    , sortWith =
        Elm.value
            { importFrom = [ "List" ]
            , name = "sortWith"
            , annotation =
                Just
                    (Type.function
                        [ Type.function
                            [ Type.var "a", Type.var "a" ]
                            (Type.namedWith [ "Basics" ] "Order" [])
                        , Type.list (Type.var "a")
                        ]
                        (Type.list (Type.var "a"))
                    )
            }
    , isEmpty =
        Elm.value
            { importFrom = [ "List" ]
            , name = "isEmpty"
            , annotation =
                Just (Type.function [ Type.list (Type.var "a") ] Type.bool)
            }
    , head =
        Elm.value
            { importFrom = [ "List" ]
            , name = "head"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.var "a") ]
                        (Type.maybe (Type.var "a"))
                    )
            }
    , tail =
        Elm.value
            { importFrom = [ "List" ]
            , name = "tail"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.var "a") ]
                        (Type.maybe (Type.list (Type.var "a")))
                    )
            }
    , take =
        Elm.value
            { importFrom = [ "List" ]
            , name = "take"
            , annotation =
                Just
                    (Type.function
                        [ Type.int, Type.list (Type.var "a") ]
                        (Type.list (Type.var "a"))
                    )
            }
    , drop =
        Elm.value
            { importFrom = [ "List" ]
            , name = "drop"
            , annotation =
                Just
                    (Type.function
                        [ Type.int, Type.list (Type.var "a") ]
                        (Type.list (Type.var "a"))
                    )
            }
    , partition =
        Elm.value
            { importFrom = [ "List" ]
            , name = "partition"
            , annotation =
                Just
                    (Type.function
                        [ Type.function [ Type.var "a" ] Type.bool
                        , Type.list (Type.var "a")
                        ]
                        (Type.tuple
                            (Type.list (Type.var "a"))
                            (Type.list (Type.var "a"))
                        )
                    )
            }
    , unzip =
        Elm.value
            { importFrom = [ "List" ]
            , name = "unzip"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.tuple (Type.var "a") (Type.var "b")) ]
                        (Type.tuple
                            (Type.list (Type.var "a"))
                            (Type.list (Type.var "b"))
                        )
                    )
            }
    }



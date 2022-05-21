module Util.String exposing (dedent, indent, quote, toRecord)

{-| Removes excess spaces from the string provided

    """
            query {
              me
            }
    """

    -- becomes
    """
    query {
      me
    }
    """

-}


dedent : String -> String
dedent indentedString =
    let
        lines : List String
        lines =
            String.lines indentedString

        nonBlankLines : List String
        nonBlankLines =
            List.filter isNonBlank lines

        isNonBlank : String -> Bool
        isNonBlank =
            not << String.isEmpty << String.trimLeft

        countInitialSpacesFor : String -> Int
        countInitialSpacesFor str =
            String.length str - String.length (String.trimLeft str)

        numberOfSpacesToRemove : Int
        numberOfSpacesToRemove =
            List.foldl
                (\line maybeMin ->
                    let
                        count =
                            countInitialSpacesFor line
                    in
                    case maybeMin of
                        Nothing ->
                            Just count

                        Just min ->
                            if min < count then
                                Just min

                            else
                                Just count
                )
                Nothing
                nonBlankLines
                |> Maybe.withDefault 0
    in
    nonBlankLines
        |> List.map (String.dropLeft numberOfSpacesToRemove)
        |> String.join "\n"


{-| Indent each line of the given string by a number of spaces.

    indent 0 "hello" == "hello"

    indent 2 "hey" == "  hey"

    indent 4 "hello\nworld" == "    hello\n    world"

-}
indent : Int -> String -> String
indent numberOfSpaces str =
    let
        tab : String
        tab =
            String.fromList (List.repeat numberOfSpaces ' ')
    in
    str
        |> String.lines
        |> List.map (\line -> tab ++ line)
        |> String.join "\n"


{-| Wrap a string in quotes
-}
quote : String -> String
quote str =
    "\""
        ++ (String.toList str
                |> List.concatMap
                    (\char ->
                        if char == '"' then
                            [ '\\', '"' ]

                        else
                            [ char ]
                    )
                |> String.fromList
           )
        ++ "\""


{-| Helper function for making a record, either for a type annotation or a value
-}
toRecord :
    { joinWith : String
    , toKey : item -> String
    , toValue : item -> String
    , items : List item
    }
    -> String
toRecord options =
    let
        fromItemToString : item -> String
        fromItemToString item =
            String.join " "
                [ options.toKey item
                , options.joinWith
                , options.toValue item
                ]
    in
    case options.items of
        [] ->
            "{}"

        items ->
            items
                |> List.map fromItemToString
                |> String.join ", "
                |> (\str -> "{ " ++ str ++ " }")

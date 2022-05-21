module Util.String exposing (indent, quote, toMultilineList, toRecord, wrapInParentheses, dedent)

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


wrapInParentheses : String -> String
wrapInParentheses str =
    "(" ++ str ++ ")"


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


toMultilineList : { toString : item -> String, items : List item } -> String
toMultilineList options =
    case options.items of
        [] ->
            "[]"

        items ->
            "[ "
                ++ (items
                        |> List.map options.toString
                        |> String.join "\n, "
                   )
                ++ "\n]"



dedent : String -> String
dedent string =
  let
      trimmedLines : List String
      trimmedLines =
          string
            |> String.trim
            |> String.lines
            
      toIndentation : String -> Int
      toIndentation line =
        String.length line - String.length (String.trimLeft line)
            
      keepSmallestPositiveInt : Int -> Maybe Int -> Maybe Int
      keepSmallestPositiveInt indentation smallestSoFar =
                  case smallestSoFar of
                    Just smallest ->
                        if indentation > 0 && smallest > indentation then
                          Just indentation
                        else
                          smallestSoFar
                    Nothing ->
                        if indentation > 0 then
                          Just indentation
                        else
                          smallestSoFar
                
            
      smallestIndent : Int
      smallestIndent =
          trimmedLines
            |> List.map toIndentation
            |> List.foldl keepSmallestPositiveInt Nothing
            |> Maybe.withDefault 0
            
            
      trimIfIndented : String -> String
      trimIfIndented str =
          if String.left smallestIndent str == String.fromList (List.repeat smallestIndent ' ') then
            String.dropLeft smallestIndent str
          else
            str
  in
  trimmedLines
      |> List.map trimIfIndented
      |> String.join "\n"
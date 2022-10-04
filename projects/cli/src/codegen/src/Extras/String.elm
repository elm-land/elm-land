module Extras.String exposing
    ( fromPascalCaseToCamelCase
    , fromPascalCaseToKebabCase
    )


fromPascalCaseToCamelCase : String -> String
fromPascalCaseToCamelCase str =
    case String.toList str of
        [] ->
            ""

        firstChar :: rest ->
            String.fromList (Char.toLower firstChar :: rest)


fromPascalCaseToKebabCase : String -> String
fromPascalCaseToKebabCase str =
    str
        |> String.toList
        |> List.concatMap
            (\char ->
                if Char.isUpper char then
                    [ '-', Char.toLower char ]

                else
                    [ char ]
            )
        |> String.fromList
        |> String.dropLeft 1

module GraphQL.CliError exposing (CliError(..), toString)

{-| This is a data structure to represent all the things that might go wrong
when generated Elm code with @elm-land/graphql
-}


{-| This is a data structure represents all the problems that might occur
when generating Elm code with @elm-land/graphql
-}
type CliError
    = NoOperationMatchingFilename
    | CouldNotFindOperationType


toString : CliError -> String
toString cliError =
    case cliError of
        NoOperationMatchingFilename ->
            {- When the "graphql/queries/HelloWorld.graphql" file doesn't have a
               query with the name "HelloWorld", @elm-land/graphql isn't able
               to figure out which operation is the one that should be run.

               Defining many queries in one file is valid GraphQL syntax, so
               we need to let the user know that Elm Land expects a named query
               to determine which one to use.
            -}
            "NoOperationMatchingFilename"

        CouldNotFindOperationType ->
            "CouldNotFindOperationType"

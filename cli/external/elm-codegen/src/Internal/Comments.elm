module Internal.Comments exposing
    ( Comment, CommentPart(..), DocComment, FileComment
    , emptyComment, addPart
    , prettyDocComment, prettyFileComment
    , docCommentParser, fileCommentParser
    )

{-| A component DSL that helps with building comments.
It is useful to have this in a structured way, so that it can be re-flowed by
the pretty printer, and so that an understanding of the layout of the doc tags
can be extracted to order the exposing clause by.


# Structured comments

@docs Comment, CommentPart, DocComment, FileComment


# Building comments

@docs emptyComment, addPart


# Pretty printing of comments

@docs prettyDocComment, prettyFileComment


# Parsing of comments into structured comments

@docs docCommentParser, fileCommentParser

-}

import Parser exposing (Parser)
import Pretty exposing (Doc)


type DocComment
    = DocComment


type FileComment
    = FileComment


type Comment a
    = Comment (List CommentPart)


type CommentPart
    = Markdown String
    | Code String
    | DocTags (List String)


{-| Creates an empty comment of any type.
-}
emptyComment : Comment a
emptyComment =
    Comment []


{-| Adds a part to a comment.
-}
addPart : Comment a -> CommentPart -> Comment a
addPart (Comment parts) part =
    Comment (part :: parts)


{-| Gets the parts of a comment in the correct order.
-}
getParts : Comment a -> List CommentPart
getParts (Comment parts) =
    List.reverse parts


{-| Pretty prints a document comment.
Where possible the comment will be re-flowed to fit the specified page width.
-}
prettyDocComment : Int -> Comment DocComment -> String
prettyDocComment width comment =
    List.map prettyCommentPart (getParts comment)
        |> Pretty.lines
        |> delimeters
        |> Pretty.pretty width


{-| Pretty prints a file comment.
Where possible the comment will be re-flowed to fit the specified page width.
-}
prettyFileComment : Int -> Comment FileComment -> ( String, List (List String) )
prettyFileComment width comment =
    let
        ( parts, splits ) =
            layoutTags width (getParts comment)
    in
    ( List.map prettyCommentPart parts
        |> Pretty.lines
        |> delimeters
        |> Pretty.pretty width
    , splits
    )


{-| Combines lists of doc tags that are together in the comment into single lists,
then breaks those lists up to fit the page width.
-}
layoutTags : Int -> List CommentPart -> ( List CommentPart, List (List String) )
layoutTags width parts =
    List.foldr
        (\part ( accumParts, accumDocTags ) ->
            case part of
                DocTags tags ->
                    let
                        splits =
                            fitAndSplit width tags
                    in
                    ( List.map DocTags splits ++ accumParts
                    , accumDocTags ++ splits
                    )

                otherPart ->
                    ( otherPart :: accumParts, accumDocTags )
        )
        ( [], [] )
        (mergeDocTags parts)


{-| Takes tags from the input and builds them into an output list until the
given width limit cannot be kept to. When the width limit is breached the output
spills over into more lists.
Each list must contain at least one tag, even if this were to breach the width
limit.
-}
fitAndSplit : Int -> List String -> List (List String)
fitAndSplit width tags =
    case tags of
        [] ->
            []

        t :: ts ->
            let
                ( splitsExceptLast, lastSplit, _ ) =
                    List.foldl
                        (\tag ( allSplits, curSplit, remaining ) ->
                            if String.length tag <= remaining then
                                ( allSplits, tag :: curSplit, remaining - String.length tag )

                            else
                                ( allSplits ++ [ List.reverse curSplit ], [ tag ], width - String.length tag )
                        )
                        ( [], [ t ], width - String.length t )
                        ts
            in
            splitsExceptLast ++ [ List.reverse lastSplit ]


{-| Merges neighbouring lists of doc tags together.
-}
mergeDocTags : List CommentPart -> List CommentPart
mergeDocTags innerParts =
    let
        ( partsExceptMaybeFirst, maybeFirstPart ) =
            List.foldr
                (\part ( accum, context ) ->
                    case context of
                        Nothing ->
                            case part of
                                DocTags tags ->
                                    ( accum, Just tags )

                                otherPart ->
                                    ( otherPart :: accum, Nothing )

                        Just contextTags ->
                            case part of
                                DocTags tags ->
                                    ( accum, Just (contextTags ++ tags) )

                                otherPart ->
                                    ( otherPart :: DocTags (List.sort contextTags) :: accum, Nothing )
                )
                ( [], Nothing )
                innerParts
    in
    case maybeFirstPart of
        Nothing ->
            partsExceptMaybeFirst

        Just tags ->
            DocTags (List.sort tags) :: partsExceptMaybeFirst


prettyCommentPart : CommentPart -> Doc t
prettyCommentPart part =
    case part of
        Markdown val ->
            prettyMarkdown val

        Code val ->
            prettyCode val

        DocTags tags ->
            prettyTags tags


prettyMarkdown val =
    Pretty.string val



prettyCode val =
    Pretty.string val
        |> Pretty.indent 4


prettyTags tags =
    [ Pretty.string "@docs"
    , List.map Pretty.string tags
        |> Pretty.join (Pretty.string ", ")
    ]
        |> Pretty.words


partToStringAndTags : Int -> CommentPart -> ( String, List String )
partToStringAndTags width part =
    case part of
        Markdown val ->
            ( val, [] )

        Code val ->
            ( "    " ++ val, [] )

        DocTags tags ->
            ( "@doc " ++ String.join ", " tags, tags )


docCommentParser : Parser (Comment DocComment)
docCommentParser =
    Parser.getSource
        |> Parser.map (\val -> Comment [ Markdown val ])


fileCommentParser : Parser (Comment FileComment)
fileCommentParser =
    Parser.getSource
        |> Parser.map (\val -> Comment [ Markdown val ])


delimeters : Doc t -> Doc t
delimeters doc =
    Pretty.string "{-| "
        |> Pretty.a doc
        |> Pretty.a Pretty.line
        |> Pretty.a (Pretty.string "-}")

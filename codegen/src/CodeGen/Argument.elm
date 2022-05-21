module CodeGen.Argument exposing
    ( Argument, new
    , toString
    )

{-|

@docs Argument, new

@docs toString

-}


{-| Represents argument to a function or case expression.
-}
type Argument
    = NamedArgument String


{-| Create a simple argument that is just the name of a value

    -- params
    CodeGen.Argument.new "params"

-}
new : String -> Argument
new str =
    NamedArgument str


{-| Render an `Argument` value to a `String`

( Used internally by `CodeGen.Module` )

-}
toString : Argument -> String
toString argument =
    case argument of
        NamedArgument str ->
            str

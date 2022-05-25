module CodeGen exposing
    ( Program, program
    , File
    , Module
    , Import, Declaration
    , Annotation, Argument, Expression
    )

{-|


## **Generating code**

@docs Program, program
@docs File


## **Aliases**

@docs Module
@docs Import, Declaration
@docs Annotation, Argument, Expression

-}

import CodeGen.Annotation
import CodeGen.Argument
import CodeGen.Declaration
import CodeGen.Expression
import CodeGen.Import
import CodeGen.Module



-- PROGRAMS & FILES


{-| Represents a runnable program for generating Elm files. Built on top of [Platform.worker](https://package.elm-lang.org/packages/elm/core/latest/Platform#worker)
-}
type alias Program flags =
    Platform.Program flags () ()


{-| Represents a newly generated Elm file
-}
type alias File =
    { filepath : String
    , contents : String
    }


{-| Create a runnable Elm worker program

    main : CodeGen.Program ()
    main =
        CodeGen.program
            { onComplete = onComplete
            , modules =
                [ module1
                , module2
                , ...
                ]
            }

    module1 : CodeGen.Module
    module1 =
        ...

-}
program :
    { onComplete : List File -> Cmd ()
    , modules : flags -> List CodeGen.Module.Module
    }
    -> Program flags
program options =
    Platform.worker
        { init =
            \flags ->
                ( ()
                , options.modules flags
                    |> List.map
                        (\module_ ->
                            { filepath = CodeGen.Module.toFilepath module_
                            , contents = CodeGen.Module.toString module_
                            }
                        )
                    |> options.onComplete
                )
        , update = \_ model -> ( model, Cmd.none )
        , subscriptions = \_ -> Sub.none
        }



-- ALIASES


{-| An alias for `CodeGen.Module.Module`
-}
type alias Module =
    CodeGen.Module.Module


{-| An alias for `CodeGen.Annotation.Annotation`
-}
type alias Annotation =
    CodeGen.Annotation.Annotation


{-| An alias for `CodeGen.Argument.Argument`
-}
type alias Argument =
    CodeGen.Argument.Argument


{-| An alias for `CodeGen.Declaration.Declaration`
-}
type alias Declaration =
    CodeGen.Declaration.Declaration


{-| An alias for `CodeGen.Expression.Expression`
-}
type alias Expression =
    CodeGen.Expression.Expression


{-| An alias for `CodeGen.Import.Import`
-}
type alias Import =
    CodeGen.Import.Import

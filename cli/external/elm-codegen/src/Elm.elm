module Elm exposing
    ( File, file
    , Expression
    , bool, int, float, char, string, hex, unit
    , maybe, just, nothing
    , list, tuple, triple
    , withType, withAlias
    , record, field, Field, get, updateRecord
    , letIn, ifThen
    , Declaration
    , comment, declaration
    , withDocumentation
    , expose, exposeWith
    , fileWith, docs
    , fn, fn2, fn3, fn4, fn5, fn6, function, functionReduced
    , customType, Variant, variant, variantWith
    , alias
    , equal, notEqual
    , append, cons
    , plus, minus, multiply, divide, intDivide, power
    , lt, gt, lte, gte, and, or
    , keep, skip
    , slash, query
    , portIncoming, portOutgoing
    , parse, unsafe
    , toString, signature, expressionImports
    , declarationToString, declarationImports
    , apply, value
    , unwrap, unwrapper
    )

{-|

@docs File, file


## Basics

@docs Expression

@docs bool, int, float, char, string, hex, unit

@docs maybe, just, nothing

@docs list, tuple, triple

@docs withType, withAlias


## Records

@docs record, field, Field, get, updateRecord


## Flow control

@docs letIn, ifThen


## Top level

@docs Declaration

@docs comment, declaration

@docs withDocumentation

@docs expose, exposeWith

@docs fileWith, docs


## Functions

@docs fn, fn2, fn3, fn4, fn5, fn6, function, functionReduced


## Custom Types

@docs customType, Variant, variant, variantWith

@docs alias


# Operators

@docs equal, notEqual

@docs append, cons

@docs plus, minus, multiply, divide, intDivide, power

@docs lt, gt, lte, gte, and, or


## Parsing

@docs keep, skip


## Url parsing

@docs slash, query


# Ports

@docs portIncoming, portOutgoing


# Parsing existing Elm

@docs parse, unsafe


# Rendering to string

@docs toString, signature, expressionImports

@docs declarationToString, declarationImports


# Low-level

@docs apply, value

@docs unwrap, unwrapper

-}

import Dict
import Elm.Annotation
import Elm.Parser
import Elm.Processing
import Elm.Syntax.Declaration as Declaration exposing (Declaration(..))
import Elm.Syntax.Exposing as Expose
import Elm.Syntax.Expression as Exp
import Elm.Syntax.Infix as Infix
import Elm.Syntax.Module
import Elm.Syntax.Node as Node
import Elm.Syntax.Pattern as Pattern
import Elm.Syntax.Range as Range
import Elm.Syntax.TypeAnnotation as Annotation
import Internal.Comments
import Internal.Compiler as Compiler
import Internal.Types
import Internal.Write
import Set


{-| -}
type alias Expression =
    Compiler.Expression


{-| -}
expressionImports : Expression -> String
expressionImports exp =
    exp
        |> Compiler.toExpressionDetails Compiler.startIndex
        |> Tuple.second
        |> Compiler.getImports
        |> List.filterMap (Compiler.makeImport [])
        |> Internal.Write.writeImports


{-| -}
toString : Expression -> String
toString (Compiler.Expression exp) =
    Internal.Write.writeExpression (exp Compiler.startIndex |> .expression)


{-| -}
facts : Expression -> Result String (List ( String, String ))
facts (Compiler.Expression exp) =
    let
        expresh =
            exp Compiler.startIndex
    in
    case expresh.annotation of
        Ok sig ->
            sig.inferences
                |> Dict.toList
                |> List.map
                    (\( key, type_ ) ->
                        ( key, Internal.Write.writeAnnotation type_ )
                    )
                |> Ok

        Err inferenceError ->
            List.foldl
                (\err str ->
                    case str of
                        "" ->
                            Compiler.inferenceErrorToString err

                        _ ->
                            str ++ "\n\n" ++ Compiler.inferenceErrorToString err
                )
                ""
                inferenceError
                |> Err


{-| -}
signature : Expression -> String
signature (Compiler.Expression exp) =
    let
        expresh =
            exp Compiler.startIndex
    in
    case expresh.annotation of
        Ok sig ->
            case Compiler.resolve sig.inferences sig.type_ of
                Ok finalType ->
                    Internal.Write.writeAnnotation finalType

                Err errMsg ->
                    errMsg

        Err inferenceError ->
            List.foldl
                (\err str ->
                    case str of
                        "" ->
                            Compiler.inferenceErrorToString err

                        _ ->
                            str ++ "\n\n" ++ Compiler.inferenceErrorToString err
                )
                "Err: "
                inferenceError


{-| -}
declarationImports : Declaration -> String
declarationImports decl =
    case decl of
        Compiler.Declaration _ imps _ ->
            List.filterMap (Compiler.makeImport []) imps
                |> Internal.Write.writeImports

        Compiler.Comment _ ->
            ""

        Compiler.Block _ ->
            ""


{-| -}
declarationToString : Declaration -> String
declarationToString dec =
    Internal.Write.writeDeclaration dec


{-| Build a file!

    Elm.file [ "My", "Module" ]
        [ Elm.declaration "placeholder"
            (Elm.string "a fancy string!")
        ]

-}
file : List String -> List Declaration -> File
file mod decs =
    render renderStandardComment
        { moduleDefinition = mod
        , imports =
            reduceDeclarationImports mod decs ( Set.empty, [] )
                |> Tuple.second
        , body = decs
        , aliases = []
        , moduleComment = ""
        }


renderStandardComment :
    List
        { group : Maybe String
        , members : List String
        }
    -> List String
renderStandardComment groups =
    if List.isEmpty groups then
        []

    else
        List.map docs groups


{-| Render a standard docstring.

    @docs one, two, three

If a `group` has been given, it will be rendered as a second level header.

```markdown
## Group name

@docs one, two, three
```

-}
docs :
    { group : Maybe String
    , members : List String
    }
    -> String
docs group =
    case group.group of
        Nothing ->
            "@docs " ++ String.join ", " group.members

        Just groupName ->
            "## " ++ groupName ++ "\n\n@docs " ++ String.join ", " group.members


{-| Same as [file](#file), but you have more control over how the module comment is generated!

Pass in a function that determines how to render a `@doc` comment.

Each exposed item is grouped based on the string used in [exposeWith](#exposeWith).

**aliases** allow you to specify a module alias to be used.

    aliases =
        [ (["Json", "Encode"), "Encode")
        ]

would make an import statement like

    import Json.Encode as Encode

All values rendered in this file that are from this module would also automatically respect this alias as well.

-}
fileWith :
    List String
    ->
        { docs :
            List
                { group : Maybe String
                , members : List String
                }
            -> List String
        , aliases : List ( List String, String )
        }
    -> List Declaration
    -> File
fileWith mod options decs =
    render options.docs
        { moduleDefinition = mod
        , imports =
            reduceDeclarationImports mod decs ( Set.empty, [] )
                |> Tuple.second
        , aliases = options.aliases
        , body = decs
        , moduleComment = ""
        }


{-| -}
render :
    (List
        { group : Maybe String
        , members : List String
        }
     -> List String
    )
    -> FileDetails
    -> File
render toDocComment fileDetails =
    let
        mod =
            fileDetails.moduleDefinition

        exposed =
            Compiler.getExposed fileDetails.body

        exposedGroups =
            Compiler.getExposedGroups fileDetails.body

        body =
            Internal.Write.write
                { moduleDefinition =
                    (if Compiler.hasPorts fileDetails.body then
                        Elm.Syntax.Module.PortModule

                     else
                        Elm.Syntax.Module.NormalModule
                    )
                        { moduleName = Compiler.nodify mod
                        , exposingList =
                            case exposed of
                                [] ->
                                    Compiler.nodify
                                        (Expose.All Range.emptyRange)

                                _ ->
                                    Compiler.nodify
                                        (Expose.Explicit
                                            (Compiler.nodifyAll exposed)
                                        )
                        }
                , aliases = fileDetails.aliases
                , imports =
                    List.filterMap (Compiler.makeImport fileDetails.aliases) fileDetails.imports
                , declarations = fileDetails.body
                , comments =
                    Just
                        (Internal.Comments.addPart
                            Internal.Comments.emptyComment
                            (Internal.Comments.Markdown
                                (case exposedGroups of
                                    [] ->
                                        ""

                                    _ ->
                                        "\n"
                                            ++ (toDocComment exposedGroups
                                                    |> String.join "\n\n"
                                               )
                                )
                            )
                        )
                }
    in
    { path =
        String.join "/" mod ++ ".elm"
    , contents = body
    }


type alias Module =
    List String


reduceDeclarationImports : Module -> List Declaration -> ( Set.Set String, List Module ) -> ( Set.Set String, List Module )
reduceDeclarationImports self decs imports =
    case decs of
        [] ->
            imports

        (Compiler.Comment _) :: remain ->
            reduceDeclarationImports self
                remain
                imports

        (Compiler.Block _) :: remain ->
            reduceDeclarationImports self
                remain
                imports

        (Compiler.Declaration _ newImports body) :: remain ->
            reduceDeclarationImports self
                remain
                (addImports self newImports imports)


addImports : Module -> List Module -> ( Set.Set String, List Module ) -> ( Set.Set String, List Module )
addImports self newImports ( set, deduped ) =
    case newImports of
        [] ->
            ( set, deduped )

        new :: remain ->
            let
                full =
                    Compiler.fullModName new
            in
            if Set.member full set || full == Compiler.fullModName self then
                -- skip
                addImports self remain ( set, deduped )

            else
                addImports self
                    remain
                    ( Set.insert full set, new :: deduped )


{-| -}
type alias File =
    { path : String
    , contents : String
    }


type alias FileDetails =
    { moduleDefinition : Module
    , imports : List Module
    , aliases : List ( Module, String )
    , body : List Declaration
    , moduleComment : String
    }


{-| -}
value :
    { importFrom : List String
    , name : String
    , annotation : Maybe Elm.Annotation.Annotation
    }
    -> Expression
value details =
    Compiler.Expression <|
        \index ->
            { expression =
                Exp.FunctionOrValue details.importFrom
                    (Compiler.sanitize details.name)
            , annotation =
                case details.annotation of
                    Nothing ->
                        Ok
                            { type_ =
                                Annotation.GenericType
                                    (Compiler.protectTypeName details.name index)
                            , inferences = Dict.empty
                            , aliases = Compiler.emptyAliases
                            }

                    Just ann ->
                        Ok (Compiler.getInnerInference index ann)
            , imports =
                case details.annotation of
                    Nothing ->
                        case details.importFrom of
                            [] ->
                                []

                            _ ->
                                [ details.importFrom ]

                    Just ann ->
                        case details.importFrom of
                            [] ->
                                Compiler.getAnnotationImports ann

                            _ ->
                                details.importFrom :: Compiler.getAnnotationImports ann
            }


valueWithHelper : List String -> String -> Elm.Annotation.Annotation -> Expression
valueWithHelper mod name ann =
    value
        { importFrom = mod
        , name = name
        , annotation = Just ann
        }


{-| Sometimes you may need to add a manual type annotation.

    import Elm.Annotation as Type

    Elm.value "myString"
        |> Elm.withType Type.string

Though be sure `elm-codegen` isn't already doing this automatically for you!

-}
withType : Elm.Annotation.Annotation -> Expression -> Expression
withType ann (Compiler.Expression toExp) =
    Compiler.Expression <|
        \index ->
            let
                exp =
                    toExp index
            in
            { exp
                | annotation =
                    Compiler.unifyOn ann exp.annotation
                , imports = exp.imports ++ Compiler.getAnnotationImports ann
            }


{-| -}
withAlias :
    List String
    -> String
    -> List Elm.Annotation.Annotation
    -> Expression
    -> Expression
withAlias mod name vars (Compiler.Expression toExp) =
    Compiler.Expression <|
        \index ->
            let
                exp =
                    toExp index
            in
            { exp
                | annotation =
                    case exp.annotation of
                        Ok ann ->
                            Ok
                                { type_ =
                                    Annotation.Typed
                                        (Compiler.nodify
                                            ( mod, Compiler.formatType name )
                                        )
                                        (List.map
                                            (Compiler.getInnerAnnotation
                                                >> Compiler.nodify
                                            )
                                            vars
                                        )
                                , inferences = Dict.empty
                                , aliases =
                                    Compiler.emptyAliases
                                        |> Compiler.addAlias
                                            mod
                                            name
                                            (Compiler.noImports ann.type_)
                                }

                        Err err ->
                            Err err
                , imports =
                    if List.isEmpty mod then
                        []

                    else
                        [ mod ]
            }


{-| Generate a lambda which unwraps a single-variant type.

    Elm.unwrapper [ "MyModule" ] "MyType"

Results in the following lambda

    \(MyModule.MyType val) -> val

**Note** This needs to be a type with only a single variant

-}
unwrapper : List String -> String -> Expression
unwrapper modName typename =
    Compiler.Expression <|
        \index ->
            let
                childIndex =
                    Compiler.dive index

                ( arg1Name, newIndex ) =
                    Compiler.getName "val" childIndex

                ( unwrappedName, newIndex2 ) =
                    Compiler.getName "unwrapped" newIndex

                arg1Type =
                    Elm.Annotation.var arg1Name

                arg1 =
                    value
                        { importFrom = []
                        , name = arg1Name
                        , annotation = Just arg1Type
                        }
            in
            { expression =
                Exp.LambdaExpression
                    { args =
                        [ Compiler.nodify
                            (Pattern.NamedPattern
                                { moduleName = modName
                                , name = typename
                                }
                                [ Pattern.VarPattern arg1Name
                                    |> Compiler.nodify
                                ]
                            )
                        ]
                    , expression =
                        Compiler.nodify
                            (Exp.FunctionOrValue []
                                arg1Name
                            )
                    }
            , annotation =
                Ok
                    { type_ =
                        Annotation.FunctionTypeAnnotation
                            (Compiler.nodify (Annotation.GenericType arg1Name))
                            (Compiler.nodify (Annotation.GenericType unwrappedName))
                    , inferences = Dict.empty
                    , aliases = Compiler.emptyAliases
                    }
            , imports =
                case modName of
                    [] ->
                        []

                    _ ->
                        [ modName ]
            }


{-| Unwraps a single-variant type

    Elm.declaration "myFunction" <|
        Elm.fn "val"
            (\\val ->
                Elm.unwrap "MyType" val
            )

Results in the following lambda

    myFunction val =
        ((MyType val) -> val) val

-}
unwrap : List String -> String -> Expression -> Expression
unwrap modName typename exp =
    apply (unwrapper modName typename) [ exp ]


{-| -}
unit : Expression
unit =
    Compiler.Expression <|
        \_ ->
            { expression = Exp.UnitExpr
            , annotation = Ok (Compiler.inference Annotation.Unit)
            , imports = []
            }


{-| -}
bool : Bool -> Expression
bool on =
    Compiler.Expression <|
        \_ ->
            { expression =
                Exp.FunctionOrValue []
                    (if on then
                        "True"

                     else
                        "False"
                    )
            , annotation =
                Ok
                    { inferences = Dict.empty
                    , type_ = Internal.Types.bool
                    , aliases = Compiler.emptyAliases
                    }
            , imports = []
            }


{-| -}
int : Int -> Expression
int intVal =
    Compiler.Expression <|
        \_ ->
            { expression = Exp.Integer intVal
            , annotation =
                Ok
                    { inferences = Dict.empty
                    , type_ = Internal.Types.int
                    , aliases = Compiler.emptyAliases
                    }
            , imports = []
            }


{-| -}
hex : Int -> Expression
hex hexVal =
    Compiler.Expression <|
        \_ ->
            { expression = Exp.Hex hexVal
            , annotation =
                Ok
                    { inferences = Dict.empty
                    , type_ = Internal.Types.int
                    , aliases = Compiler.emptyAliases
                    }
            , imports = []
            }


{-| -}
float : Float -> Expression
float floatVal =
    Compiler.Expression <|
        \_ ->
            { expression = Exp.Floatable floatVal
            , annotation =
                Ok
                    { inferences = Dict.empty
                    , type_ = Internal.Types.float
                    , aliases = Compiler.emptyAliases
                    }
            , imports = []
            }


{-| -}
string : String -> Expression
string literal =
    Compiler.Expression <|
        \_ ->
            { expression = Exp.Literal literal
            , annotation =
                Ok
                    { inferences = Dict.empty
                    , type_ = Internal.Types.string
                    , aliases = Compiler.emptyAliases
                    }
            , imports = []
            }


{-| -}
char : Char -> Expression
char charVal =
    Compiler.Expression <|
        \_ ->
            { expression = Exp.CharLiteral charVal
            , annotation =
                Ok
                    { inferences = Dict.empty
                    , type_ = Internal.Types.char
                    , aliases = Compiler.emptyAliases
                    }
            , imports = [ [ "Char" ] ]
            }



-- {-|
-- -}
-- glsl : String -> Expression
-- glsl expr =
--     Exp.GLSLExpression expr


{-| -}
tuple : Expression -> Expression -> Expression
tuple oneExp twoExp =
    Compiler.Expression <|
        \index ->
            let
                ( oneIndex, one ) =
                    Compiler.toExpressionDetails index oneExp

                ( twoIndex, two ) =
                    Compiler.toExpressionDetails oneIndex twoExp
            in
            { expression =
                Exp.TupledExpression
                    [ Compiler.nodify one.expression
                    , Compiler.nodify two.expression
                    ]
            , annotation =
                Result.map2
                    (\oneA twoA ->
                        { type_ =
                            Annotation.Tupled
                                [ Compiler.nodify oneA.type_
                                , Compiler.nodify twoA.type_
                                ]
                        , inferences =
                            oneA.inferences
                                |> Compiler.mergeInferences twoA.inferences
                        , aliases =
                            oneA.aliases
                                |> Compiler.mergeAliases twoA.aliases
                        }
                    )
                    one.annotation
                    two.annotation
            , imports = one.imports ++ two.imports
            }


{-| -}
triple : Expression -> Expression -> Expression -> Expression
triple oneExp twoExp threeExp =
    Compiler.Expression <|
        \index ->
            let
                ( oneIndex, one ) =
                    Compiler.toExpressionDetails index oneExp

                ( twoIndex, two ) =
                    Compiler.toExpressionDetails oneIndex twoExp

                ( threeIndex, three ) =
                    Compiler.toExpressionDetails twoIndex threeExp
            in
            { expression =
                Exp.TupledExpression
                    (Compiler.nodifyAll
                        [ one.expression, two.expression, three.expression ]
                    )
            , annotation =
                Result.map3
                    (\oneA twoA threeA ->
                        { type_ =
                            Elm.Annotation.triple
                                (Compiler.noImports oneA.type_)
                                (Compiler.noImports twoA.type_)
                                (Compiler.noImports threeA.type_)
                                |> Compiler.getInnerAnnotation
                        , inferences =
                            oneA.inferences
                                |> Compiler.mergeInferences twoA.inferences
                                |> Compiler.mergeInferences threeA.inferences
                        , aliases =
                            oneA.aliases
                                |> Compiler.mergeAliases twoA.aliases
                                |> Compiler.mergeAliases threeA.aliases
                        }
                    )
                    one.annotation
                    two.annotation
                    three.annotation
            , imports = one.imports ++ two.imports ++ three.imports
            }


{-| -}
just : Expression -> Expression
just content =
    maybe (Just content)


{-| -}
nothing : Expression
nothing =
    maybe Nothing


{-| -}
maybe : Maybe Expression -> Expression
maybe maybeContent =
    Compiler.Expression <|
        \index ->
            case maybeContent of
                Nothing ->
                    { expression =
                        Exp.FunctionOrValue []
                            "Nothing"
                    , annotation =
                        Ok
                            (Compiler.getInnerInference index
                                (Elm.Annotation.maybe (Elm.Annotation.var "a"))
                            )
                    , imports =
                        []
                    }

                Just contentExp ->
                    let
                        ( _, content ) =
                            Compiler.toExpressionDetails index contentExp
                    in
                    { expression =
                        Exp.Application
                            [ Exp.FunctionOrValue []
                                "Just"
                                |> Compiler.nodify
                            , Exp.ParenthesizedExpression
                                (Compiler.nodify content.expression)
                                |> Compiler.nodify
                            ]
                    , annotation =
                        Result.map
                            (\ann ->
                                { type_ =
                                    Annotation.Typed
                                        (Compiler.nodify ( [], "Maybe" ))
                                        [ Compiler.nodify ann.type_ ]
                                , inferences =
                                    ann.inferences
                                , aliases =
                                    ann.aliases
                                }
                            )
                            (Compiler.getAnnotation content)
                    , imports =
                        Compiler.getImports content
                    }


{-| -}
list : List Expression -> Expression
list exprs =
    Compiler.Expression <|
        \sourceIndex ->
            let
                index =
                    Compiler.dive sourceIndex

                exprDetails =
                    Compiler.thread index exprs
            in
            { expression = Exp.ListExpr (List.map (.expression >> Compiler.nodify) exprDetails)
            , annotation =
                Compiler.unify exprDetails
                    |> Result.map
                        (\inner ->
                            { type_ =
                                Annotation.Typed
                                    (Compiler.nodify ( [], "List" ))
                                    [ Compiler.nodify inner.type_ ]
                            , inferences =
                                inner.inferences
                            , aliases = inner.aliases
                            }
                        )
            , imports = List.concatMap Compiler.getImports exprDetails
            }


{-| -}
updateRecord : Expression -> List Field -> Expression
updateRecord recordExpression fields =
    Compiler.Expression <|
        \sourceIndex ->
            let
                index =
                    Compiler.dive sourceIndex

                ( recordIndex, recordExp ) =
                    Compiler.toExpressionDetails index recordExpression

                ( fieldIndex, fieldAnnotationsGathered, fieldDetails ) =
                    fields
                        |> List.foldl
                            (\(Field fieldName fieldExp) ( currentIndex, fieldAnnotationResult, items ) ->
                                let
                                    ( newIndex, exp ) =
                                        Compiler.toExpressionDetails currentIndex fieldExp

                                    currentFieldAnnotations =
                                        case fieldAnnotationResult of
                                            Ok fieldAnns ->
                                                case exp.annotation of
                                                    Ok fs ->
                                                        Ok (( fieldName, fs ) :: fieldAnns)

                                                    Err newErr ->
                                                        Err newErr

                                            Err err ->
                                                case exp.annotation of
                                                    Ok _ ->
                                                        fieldAnnotationResult

                                                    Err newErr ->
                                                        Err (err ++ newErr)
                                in
                                ( newIndex
                                , currentFieldAnnotations
                                , ( fieldName, exp ) :: items
                                )
                            )
                            ( recordIndex, Ok [], [] )
            in
            { expression =
                case recordExp.expression of
                    Exp.FunctionOrValue _ name ->
                        fieldDetails
                            |> List.reverse
                            |> List.map
                                (\( fieldName, expDetails ) ->
                                    Compiler.nodify
                                        ( Compiler.nodify fieldName
                                        , Compiler.nodify expDetails.expression
                                        )
                                )
                            |> Exp.RecordUpdateExpression (Compiler.nodify name)

                    _ ->
                        let
                            name =
                                "record" ++ Compiler.indexToString fieldIndex
                        in
                        Exp.LetExpression
                            { declarations =
                                [ Compiler.nodify
                                    (Exp.LetDestructuring
                                        (Compiler.nodify
                                            (Pattern.VarPattern name)
                                        )
                                        (Compiler.nodify recordExp.expression)
                                    )
                                ]
                            , expression =
                                Compiler.nodify
                                    (fieldDetails
                                        |> List.map
                                            (\( fieldName, expDetails ) ->
                                                Compiler.nodify
                                                    ( Compiler.nodify fieldName
                                                    , Compiler.nodify expDetails.expression
                                                    )
                                            )
                                        |> Exp.RecordUpdateExpression (Compiler.nodify name)
                                    )
                            }
            , annotation =
                case fieldAnnotationsGathered of
                    Err fieldErrors ->
                        -- Add in existing errors
                        Err fieldErrors

                    Ok verifiedFieldAnnotations ->
                        case recordExp.annotation of
                            Ok recordAnn ->
                                case recordAnn.type_ of
                                    Annotation.Record existingFields ->
                                        -- must match all existing fields
                                        case verifyFields verifiedFieldAnnotations existingFields of
                                            Nothing ->
                                                recordExp.annotation

                                            Just err ->
                                                Err [ err ]

                                    Annotation.GenericType nameOfRecord ->
                                        -- We can attempt to infer that his is a record
                                        Ok
                                            { type_ = recordAnn.type_
                                            , aliases = recordAnn.aliases
                                            , inferences =
                                                recordAnn.inferences
                                                    |> Compiler.addInference
                                                        nameOfRecord
                                                        (Annotation.GenericRecord (Compiler.nodify nameOfRecord)
                                                            (Compiler.nodify
                                                                (List.map
                                                                    (\( fieldName, inference ) ->
                                                                        Compiler.nodify
                                                                            ( Compiler.nodify fieldName
                                                                            , Compiler.nodify inference.type_
                                                                            )
                                                                    )
                                                                    verifiedFieldAnnotations
                                                                )
                                                            )
                                                        )
                                            }

                                    otherwise ->
                                        recordExp.annotation

                            otherwise ->
                                otherwise
            , imports =
                List.concatMap
                    (Tuple.second >> Compiler.getImports)
                    fieldDetails
            }


{-|

    Elm.record
        [ Elm.field "name" (Elm.string "Elm")
        , Elm.field "designation" (Elm.string "Pretty fabulous")
        ]

-}
record : List Field -> Expression
record fields =
    Compiler.Expression <|
        \sourceIndex ->
            let
                unified =
                    fields
                        |> List.foldl
                            (\(Field unformattedFieldName fieldExpression) found ->
                                let
                                    ( newIndex, exp ) =
                                        Compiler.toExpressionDetails found.index fieldExpression

                                    fieldName =
                                        Compiler.formatValue unformattedFieldName
                                in
                                { index = newIndex
                                , fields =
                                    ( Compiler.nodify fieldName
                                    , Compiler.nodify exp.expression
                                    )
                                        :: found.fields
                                , errors =
                                    if Set.member fieldName found.passed then
                                        Compiler.DuplicateFieldInRecord fieldName :: found.errors

                                    else
                                        case exp.annotation of
                                            Err [] ->
                                                found.errors

                                            Err errs ->
                                                errs ++ found.errors

                                            Ok ann ->
                                                found.errors
                                , fieldAnnotations =
                                    case exp.annotation of
                                        Err err ->
                                            found.fieldAnnotations

                                        Ok ann ->
                                            ( Compiler.formatValue fieldName
                                            , ann
                                            )
                                                :: found.fieldAnnotations
                                , passed = Set.insert fieldName found.passed
                                , imports = exp.imports ++ found.imports
                                }
                            )
                            { fields = []
                            , errors = []
                            , fieldAnnotations = []
                            , passed = Set.empty
                            , imports = []
                            , index = Compiler.dive sourceIndex
                            }
            in
            { expression =
                unified.fields
                    |> List.reverse
                    |> Compiler.nodifyAll
                    |> Exp.RecordExpr
            , annotation =
                case unified.errors of
                    [] ->
                        Ok
                            { type_ =
                                List.reverse unified.fieldAnnotations
                                    |> List.map
                                        (\( name, ann ) ->
                                            ( Compiler.nodify name
                                            , Compiler.nodify ann.type_
                                            )
                                        )
                                    |> Compiler.nodifyAll
                                    |> Annotation.Record
                            , inferences =
                                List.foldl
                                    (\( name, ann ) gathered ->
                                        Compiler.mergeInferences ann.inferences gathered
                                    )
                                    Dict.empty
                                    unified.fieldAnnotations
                            , aliases =
                                List.foldl
                                    (\( name, ann ) gathered ->
                                        Compiler.mergeAliases ann.aliases gathered
                                    )
                                    Compiler.emptyAliases
                                    unified.fieldAnnotations
                            }

                    errs ->
                        Err errs
            , imports =
                unified.imports
            }


{-| -}
type Field
    = Field String Expression


{-| -}
field : String -> Expression -> Field
field name exp =
    Field (Compiler.formatValue name) exp


{-| A let block.

    import Elm


    Elm.letIn
        [ ("one", (Elm.int 5))
        , ("two", (Elm.int 10))
        ]
        (Elm.add (Elm.value "one") (Elm.value "two"))

-}
letIn : List ( String, Expression ) -> Expression -> Expression
letIn decls resultExpr =
    Compiler.Expression <|
        \index ->
            let
                ( firstIndex, within ) =
                    Compiler.toExpressionDetails index resultExpr

                gathered =
                    List.foldr
                        (\( name, body ) accum ->
                            let
                                ( new, newExpr ) =
                                    Compiler.toExpressionDetails accum.index body
                            in
                            { index = new
                            , declarations =
                                Compiler.nodify
                                    (Exp.LetDestructuring
                                        (Compiler.nodify
                                            (Pattern.VarPattern name)
                                        )
                                        (Compiler.nodify newExpr.expression)
                                    )
                                    :: accum.declarations
                            , imports = accum.imports ++ newExpr.imports
                            }
                        )
                        { index = firstIndex
                        , declarations = []
                        , imports = []
                        }
                        decls
            in
            { expression =
                Exp.LetExpression
                    { declarations = gathered.declarations
                    , expression = Compiler.nodify within.expression
                    }
            , imports = gathered.imports
            , annotation =
                within.annotation
            }


{-|

    ifThen (Elm.bool True)
        (Elm.string "yes")
        (Elm.string "no")

Will generate

    if True then
        "yes"

    else
        "no"

-}
ifThen : Expression -> Expression -> Expression -> Expression
ifThen condition thenBranch elseBranch =
    Compiler.Expression <|
        \index ->
            let
                ( condIndex, cond ) =
                    Compiler.toExpressionDetails index condition

                ( thenIndex, thenB ) =
                    Compiler.toExpressionDetails condIndex thenBranch

                ( finalIndex, elseB ) =
                    Compiler.toExpressionDetails thenIndex elseBranch
            in
            { expression =
                Exp.IfBlock
                    (Compiler.nodify cond.expression)
                    (Compiler.nodify thenB.expression)
                    (Compiler.nodify elseB.expression)
            , annotation =
                thenB.annotation
            , imports = cond.imports ++ thenB.imports ++ elseB.imports
            }


{-|

    record
        |> Elm.get "field"

results in

    record.field

-}
get : String -> Expression -> Expression
get unformattedFieldName recordExpression =
    Compiler.Expression <|
        \index ->
            let
                fieldName =
                    Compiler.formatValue unformattedFieldName

                ( _, expr ) =
                    Compiler.toExpressionDetails index recordExpression
            in
            { expression =
                Exp.RecordAccess
                    (Compiler.nodify expr.expression)
                    (Compiler.nodify fieldName)
            , annotation =
                case expr.annotation of
                    Ok recordAnn ->
                        case recordAnn.type_ of
                            Annotation.Record fields ->
                                case getField fieldName fields of
                                    Just ann ->
                                        Ok
                                            { type_ = ann
                                            , inferences = recordAnn.inferences
                                            , aliases = recordAnn.aliases
                                            }

                                    Nothing ->
                                        Err [ Compiler.CouldNotFindField fieldName ]

                            Annotation.GenericRecord name fields ->
                                case getField fieldName (Compiler.denode fields) of
                                    Just ann ->
                                        Ok
                                            { type_ = ann
                                            , inferences = recordAnn.inferences
                                            , aliases = recordAnn.aliases
                                            }

                                    Nothing ->
                                        Err [ Compiler.CouldNotFindField fieldName ]

                            Annotation.GenericType nameOfRecord ->
                                Compiler.inferRecordField index
                                    { nameOfRecord = nameOfRecord
                                    , fieldName = fieldName
                                    }

                            otherwise ->
                                expr.annotation

                    otherwise ->
                        otherwise
            , imports = expr.imports
            }


getField :
    String
    -> List (Node.Node ( Node.Node String, Node.Node b ))
    -> Maybe b
getField selector fields =
    case fields of
        [] ->
            Nothing

        nodifiedTop :: remain ->
            case Compiler.denode nodifiedTop of
                ( fieldname, contents ) ->
                    if Compiler.denode fieldname == selector then
                        Just (Compiler.denode contents)

                    else
                        getField selector remain


verifyFields : List ( String, Compiler.Inference ) -> List (Node.Node Annotation.RecordField) -> Maybe Compiler.InferenceError
verifyFields updatedFields existingFields =
    if verifyFieldsHelper existingFields updatedFields then
        Nothing

    else
        Just
            (Compiler.RecordUpdateIncorrectFields
                { existingFields =
                    List.map
                        (\(Node.Node _ ( Node.Node _ fieldName, Node.Node _ fieldInference )) ->
                            ( fieldName, fieldInference )
                        )
                        existingFields
                , attemptingToUpdate =
                    List.map
                        (\( fieldName, fieldInference ) ->
                            ( fieldName, fieldInference.type_ )
                        )
                        updatedFields
                }
            )


verifyFieldsHelper :
    List (Node.Node Annotation.RecordField)
    -> List ( String, Compiler.Inference )
    -> Bool
verifyFieldsHelper existingFields updatedFields =
    case updatedFields of
        [] ->
            True

        ( fieldName, fieldInference ) :: remain ->
            if presentAndMatching fieldName fieldInference existingFields then
                verifyFieldsHelper existingFields remain

            else
                False


presentAndMatching fieldName fieldInference existingFields =
    List.foldl
        (\(Node.Node _ ( Node.Node _ existingFieldName, Node.Node _ existingFieldType )) gathered ->
            if gathered then
                gathered

            else if fieldName == existingFieldName then
                True

            else
                False
        )
        False
        existingFields


{-| A custom type declaration.

    Elm.customType "MyType"
        [ Elm.variant "One"
        , Elm.variantWith "Two"
            [ Elm.Annotation.list Elm.Annotation.string ]
        ]

Will result in

    type MyType
        = One
        | Two (List String)

-}
customType : String -> List Variant -> Declaration
customType name variants =
    Compiler.Declaration Compiler.NotExposed
        (List.concatMap
            (\(Variant _ listAnn) ->
                List.concatMap Compiler.getAnnotationImports listAnn
            )
            variants
        )
        (Declaration.CustomTypeDeclaration
            { documentation = Nothing
            , name = Compiler.nodify (Compiler.formatType name)
            , generics =
                List.concatMap
                    (\(Variant _ listAnn) ->
                        listAnn
                            |> List.concatMap
                                Compiler.getGenerics
                    )
                    variants
            , constructors =
                List.map
                    (\(Variant varName vars) ->
                        Compiler.nodify
                            { name = Compiler.nodify (Compiler.formatType varName)
                            , arguments =
                                List.map
                                    (Compiler.getInnerAnnotation
                                        >> Compiler.nodify
                                    )
                                    vars
                            }
                    )
                    variants
            }
        )


{-| -}
type Variant
    = Variant String (List Elm.Annotation.Annotation)


{-| -}
variant : String -> Variant
variant name =
    Variant name []


{-| -}
variantWith : String -> List Elm.Annotation.Annotation -> Variant
variantWith =
    Variant


{-| A custom type declaration.

    import Elm.Annotation as Type

    Elm.alias "MyAlias"
        (Type.record
            [ ( "one", Type.string )
            , ( "two", Type.int )
            , ( "three", Type.var "content" )
            ]
        )

Should result in

    type alias MyAlias content =
        { one : String
        , two : Int
        , three : content
        }

-}
alias : String -> Elm.Annotation.Annotation -> Declaration
alias name innerAnnotation =
    Compiler.Declaration Compiler.NotExposed
        (Compiler.getAnnotationImports innerAnnotation)
        (Declaration.AliasDeclaration
            { documentation = Nothing
            , name = Compiler.nodify (Compiler.formatType name)
            , generics =
                Compiler.getGenerics innerAnnotation
            , typeAnnotation = Compiler.nodify (Compiler.getInnerAnnotation innerAnnotation)
            }
        )


{-| Not exposed, this should be done automatically!
-}
parens : Exp.Expression -> Exp.Expression
parens expr =
    case expr of
        Exp.UnitExpr ->
            expr

        Exp.Integer i ->
            expr

        Exp.Literal _ ->
            expr

        Exp.Hex _ ->
            expr

        Exp.Floatable _ ->
            expr

        Exp.TupledExpression _ ->
            expr

        Exp.ParenthesizedExpression _ ->
            expr

        Exp.CharLiteral _ ->
            expr

        Exp.ListExpr _ ->
            expr

        Exp.FunctionOrValue _ _ ->
            expr

        Exp.RecordAccessFunction _ ->
            expr

        Exp.RecordUpdateExpression _ _ ->
            expr

        Exp.RecordExpr _ ->
            expr

        Exp.LambdaExpression _ ->
            expr

        _ ->
            Exp.ParenthesizedExpression (Compiler.nodify expr)


{-| -}
apply : Expression -> List Expression -> Expression
apply express argExpressions =
    Compiler.Expression
        (\index ->
            let
                ( annotationIndex, exp ) =
                    Compiler.toExpressionDetails index express

                nextIndex =
                    Compiler.next annotationIndex

                args =
                    Compiler.thread nextIndex argExpressions

                protectedAnnotation =
                    Compiler.protectInference annotationIndex
                        exp.annotation
            in
            { expression =
                -- Disabling autopipe for now.
                -- There seems to be some edge cases where it generates invalid code.
                -- autopipe False exp.expression (List.map getExpression args)
                Exp.Application
                    (Compiler.nodifyAll
                        (exp.expression
                            :: List.map (parens << .expression) args
                        )
                    )
            , annotation =
                Compiler.applyType protectedAnnotation args
            , imports = exp.imports ++ List.concatMap Compiler.getImports args
            }
        )


popLast : List a -> Maybe ( List a, a )
popLast lst =
    case List.reverse lst of
        [] ->
            Nothing

        last :: initReverse ->
            Just ( List.reverse initReverse, last )


{-|

    String.append "world2" (String.append "world" "Hello")

    Apply [ String.append, "world2", Apply [ String.append, "world", "hello" ] ]

    Elm.string "Hello"
        |> Elm.Gen.String.append (Elm.string "world")
        |> Elm.Gen.String.append (Elm.string "world2")

    OpApply "|>"
        (OpApply "|>"
            ()
            (Apply [ String.append, "world" ])
        )
        String.append

-}
autopipe : Bool -> Exp.Expression -> List Exp.Expression -> Exp.Expression
autopipe committed topFn expressions =
    if committed then
        case popLast expressions of
            Nothing ->
                topFn

            Just ( init, last ) ->
                Exp.OperatorApplication "|>"
                    Infix.Left
                    (Compiler.nodify last)
                    (Compiler.nodify
                        (Exp.Application
                            (Compiler.nodify topFn :: List.map (Compiler.nodify << parens) init)
                        )
                    )

    else
        case popLast expressions of
            Nothing ->
                topFn

            Just ( init, last ) ->
                case last of
                    Exp.Application lastArgs ->
                        Exp.OperatorApplication "|>"
                            Infix.Left
                            (Compiler.nodify
                                (case lastArgs of
                                    [] ->
                                        Exp.Application []

                                    innerFn :: remain ->
                                        autopipe True (Compiler.denode innerFn) (List.map Compiler.denode remain)
                                )
                            )
                            (Compiler.nodify
                                (Exp.Application
                                    (Compiler.nodify topFn :: List.map (Compiler.nodify << parens) init)
                                )
                            )

                    _ ->
                        Exp.Application
                            (List.map (Compiler.nodify << parens) (topFn :: expressions))


{-| Create a function with a single argument.

This may seem a little weird the first time you encounter it, so let's break it down.

Here's what's happening for the `fn*` functions —

  - The `String` arguments are the **names of the arguments** for the generated function.
  - The `(Expression -> Expression)` function is where we're providing you an `Expression` that represents an argument coming in to the generated function.

So, this

    Elm.fn "firstInt"
        (\firstArgument ->
            Elm.plus
                (Elm.int 42)
                firstArgument
        )

Generates

    \firstInt -> 42 + firstInt

If you want to generate a **top level** function instead of an anonymous function, use `Elm.declaration`.

    Elm.declaration "add42" <|
        Elm.fn "firstInt"
            (\firstArgument ->
                Elm.plus
                    (Elm.int 42)
                    firstArgument
            )

Results in

    add42 : Int -> Int
    add42 firstInt =
        42 + firstInt

**Note** — Elm CodeGen will protect variable names if they're used in a nested `fn*` by adding a string of numbers to the end of the name. So, you may see a variable name be something like `myVariable_0_1`.

If you absolutely don't want this behavior, you'll need to use [`functionAdvanced`](#functionAdvanced).

**Another Note** — There may be situations where `elm-codegen` is unable to infer the type of one of the parameters. This is especially the case if you are using type aliases.

In this case you can use [`withType`](#withType) to manually attach a type to a value. That looks like this:

    import Elm
    import Elm.Annotation

    Elm.fn "firstInt"
        (\firstArgument ->
            (firstArgument
                |> Elm.withType
                    (Elm.Annotation.named ["MyOwnModule"] "MyCustomType")
            )
        )

-}
fn : String -> (Expression -> Expression) -> Expression
fn arg1BaseName toExpression =
    Compiler.Expression <|
        \index ->
            let
                childIndex =
                    Compiler.dive index

                ( arg1Name, newIndex ) =
                    Compiler.getName arg1BaseName childIndex

                arg1Type =
                    Elm.Annotation.var arg1Name

                arg1 =
                    value
                        { importFrom = []
                        , name = arg1Name
                        , annotation = Just arg1Type
                        }

                (Compiler.Expression toExpr) =
                    toExpression arg1

                expr =
                    toExpr newIndex
            in
            { expression =
                Exp.LambdaExpression
                    { args = [ Compiler.nodify (Pattern.VarPattern arg1Name) ]
                    , expression = Compiler.nodify expr.expression
                    }
            , annotation =
                fnTypeApply expr.annotation
                    [ arg1Type
                    ]
            , imports = expr.imports
            }


{-| This is a special case of function declaration which will _reduce_ itself if possible.

Meaning, if this would generate the following code

    \myArg -> someOtherFunction myArg

Then it will replace itself with just

    someOtherFunction

**Note** you likely won't need this! It's generally used by the package-helper generator, but that might be a relatively special case.

-}
functionReduced : String -> (Expression -> Expression) -> Expression
functionReduced argBaseName toExpression =
    Compiler.Expression <|
        \index ->
            let
                childIndex =
                    Compiler.dive index

                ( arg1Name, newIndex ) =
                    Compiler.getName argBaseName childIndex

                argType =
                    Elm.Annotation.var arg1Name

                arg1 =
                    value
                        { importFrom = []
                        , name = arg1Name
                        , annotation = Just argType
                        }

                (Compiler.Expression toExpr) =
                    toExpression arg1

                expr =
                    toExpr newIndex
            in
            { expression =
                betaReduce <|
                    Exp.LambdaExpression
                        { args = [ Compiler.nodify (Pattern.VarPattern arg1Name) ]
                        , expression = Compiler.nodify expr.expression
                        }
            , annotation =
                fnTypeApply expr.annotation
                    [ argType
                    ]
            , imports = expr.imports
            }



-- -- If the list is nonempty, returns a tuple with the beginning of the list and the last element (denoded).


popLastAndDenodeLast : List (Node.Node a) -> Maybe ( List (Node.Node a), a )
popLastAndDenodeLast lst =
    case List.reverse lst of
        [] ->
            Nothing

        last :: initReverse ->
            Just ( List.reverse initReverse, Compiler.denode last )


betaReduce : Exp.Expression -> Exp.Expression
betaReduce e =
    let
        extractLastArg arg =
            case arg of
                Exp.FunctionOrValue [] n ->
                    Just n

                Exp.ParenthesizedExpression p ->
                    extractLastArg <| Compiler.denode p

                _ ->
                    Nothing
    in
    case e of
        Exp.LambdaExpression { args, expression } ->
            case popLastAndDenodeLast args of
                Just ( initLambdaArgs, Pattern.VarPattern lastLambdaArg ) ->
                    case Compiler.denode expression of
                        Exp.RecordAccess argNode fieldNode ->
                            let
                                fieldName =
                                    Compiler.denode fieldNode

                                arg =
                                    Compiler.denode argNode
                            in
                            case arg of
                                Exp.FunctionOrValue [] argName ->
                                    if argName == lastLambdaArg then
                                        Exp.RecordAccessFunction <| "." ++ fieldName

                                    else
                                        e

                                _ ->
                                    e

                        Exp.Application applicationArgs ->
                            case popLastAndDenodeLast applicationArgs of
                                Just ( [], uniqueApplicationArg ) ->
                                    if extractLastArg uniqueApplicationArg == Just lastLambdaArg then
                                        Exp.FunctionOrValue [] "identity"

                                    else
                                        e

                                Just ( initApplicationArgs, lastApplicationArg ) ->
                                    if extractLastArg lastApplicationArg == Just lastLambdaArg then
                                        if List.isEmpty initLambdaArgs then
                                            case initApplicationArgs of
                                                [ s ] ->
                                                    betaReduce <| Compiler.denode s

                                                _ ->
                                                    Exp.Application initApplicationArgs

                                        else
                                            betaReduce <|
                                                Exp.LambdaExpression
                                                    { args = initLambdaArgs
                                                    , expression =
                                                        Compiler.nodify <|
                                                            Exp.Application initApplicationArgs
                                                    }

                                    else
                                        e

                                _ ->
                                    e

                        _ ->
                            e

                _ ->
                    e

        _ ->
            e


{-| -}
fn2 :
    String
    -> String
    -> (Expression -> Expression -> Expression)
    -> Expression
fn2 oneBaseName twoBaseName toExpression =
    Compiler.Expression <|
        \index ->
            let
                childIndex =
                    Compiler.dive index

                ( oneName, oneIndex ) =
                    Compiler.getName oneBaseName childIndex

                oneType =
                    Elm.Annotation.var oneName

                arg1 =
                    valueWithHelper [] oneName oneType

                ( twoName, twoIndex ) =
                    Compiler.getName twoBaseName oneIndex

                twoType =
                    Elm.Annotation.var twoName

                arg2 =
                    valueWithHelper [] twoName twoType

                ( newIndex, expr ) =
                    Compiler.toExpressionDetails twoIndex (toExpression arg1 arg2)
            in
            { expression =
                Exp.LambdaExpression
                    { args =
                        [ Compiler.nodify (Pattern.VarPattern oneName)
                        , Compiler.nodify (Pattern.VarPattern twoName)
                        ]
                    , expression = Compiler.nodify expr.expression
                    }
            , annotation =
                fnTypeApply expr.annotation
                    [ oneType
                    , twoType
                    ]
            , imports = expr.imports
            }


fnTypeApply :
    Result
        (List Compiler.InferenceError)
        Compiler.Inference
    -> List Compiler.Annotation
    -> Result (List Compiler.InferenceError) Compiler.Inference
fnTypeApply annotation args =
    case annotation of
        Err err ->
            Err err

        Ok return ->
            Ok
                { type_ =
                    List.foldr
                        (\ann fnbody ->
                            Annotation.FunctionTypeAnnotation
                                (Compiler.nodify (Compiler.getInnerAnnotation ann))
                                (Compiler.nodify fnbody)
                        )
                        return.type_
                        args
                , aliases =
                    List.foldl
                        (\ann aliases ->
                            Compiler.mergeAliases
                                (Compiler.getAliases ann)
                                aliases
                        )
                        return.aliases
                        args
                , inferences =
                    return.inferences
                }


{-| -}
fn3 :
    String
    -> String
    -> String
    -> (Expression -> Expression -> Expression -> Expression)
    -> Expression
fn3 oneBaseName twoBaseName threeBaseName toExpression =
    Compiler.Expression <|
        \index ->
            let
                childIndex =
                    Compiler.dive index

                ( oneName, oneIndex ) =
                    Compiler.getName oneBaseName childIndex

                oneType =
                    Elm.Annotation.var oneName

                arg1 =
                    valueWithHelper [] oneName oneType

                ( twoName, twoIndex ) =
                    Compiler.getName twoBaseName oneIndex

                twoType =
                    Elm.Annotation.var twoName

                arg2 =
                    valueWithHelper [] twoName twoType

                ( threeName, threeIndex ) =
                    Compiler.getName threeBaseName twoIndex

                threeType =
                    Elm.Annotation.var threeName

                arg3 =
                    valueWithHelper [] threeName threeType

                ( newIndex, expr ) =
                    Compiler.toExpressionDetails threeIndex (toExpression arg1 arg2 arg3)
            in
            { expression =
                Exp.LambdaExpression
                    { args =
                        [ Compiler.nodify (Pattern.VarPattern oneName)
                        , Compiler.nodify (Pattern.VarPattern twoName)
                        , Compiler.nodify (Pattern.VarPattern threeName)
                        ]
                    , expression = Compiler.nodify expr.expression
                    }
            , annotation =
                fnTypeApply expr.annotation
                    [ oneType
                    , twoType
                    , threeType
                    ]
            , imports = expr.imports
            }


{-| -}
fn4 :
    String
    -> String
    -> String
    -> String
    -> (Expression -> Expression -> Expression -> Expression -> Expression)
    -> Expression
fn4 oneBaseName twoBaseName threeBaseName fourBaseName toExpression =
    Compiler.Expression <|
        \index ->
            let
                childIndex =
                    Compiler.dive index

                ( oneName, oneIndex ) =
                    Compiler.getName oneBaseName childIndex

                oneType =
                    Elm.Annotation.var oneName

                arg1 =
                    valueWithHelper [] oneName oneType

                ( twoName, twoIndex ) =
                    Compiler.getName twoBaseName oneIndex

                twoType =
                    Elm.Annotation.var twoName

                arg2 =
                    valueWithHelper [] twoName twoType

                ( threeName, threeIndex ) =
                    Compiler.getName threeBaseName twoIndex

                threeType =
                    Elm.Annotation.var threeName

                arg3 =
                    valueWithHelper [] threeName threeType

                ( fourName, fourIndex ) =
                    Compiler.getName fourBaseName threeIndex

                fourType =
                    Elm.Annotation.var fourName

                arg4 =
                    valueWithHelper [] fourName fourType

                ( newIndex, expr ) =
                    Compiler.toExpressionDetails fourIndex (toExpression arg1 arg2 arg3 arg4)
            in
            { expression =
                Exp.LambdaExpression
                    { args =
                        [ Compiler.nodify (Pattern.VarPattern oneName)
                        , Compiler.nodify (Pattern.VarPattern twoName)
                        , Compiler.nodify (Pattern.VarPattern threeName)
                        , Compiler.nodify (Pattern.VarPattern fourName)
                        ]
                    , expression = Compiler.nodify expr.expression
                    }
            , annotation =
                fnTypeApply expr.annotation
                    [ oneType
                    , twoType
                    , threeType
                    , fourType
                    ]
            , imports = expr.imports
            }


{-| -}
fn5 :
    String
    -> String
    -> String
    -> String
    -> String
    -> (Expression -> Expression -> Expression -> Expression -> Expression -> Expression)
    -> Expression
fn5 oneBaseName twoBaseName threeBaseName fourBaseName fiveBaseName toExpression =
    Compiler.Expression <|
        \index ->
            let
                childIndex =
                    Compiler.dive index

                ( oneName, oneIndex ) =
                    Compiler.getName oneBaseName childIndex

                oneType =
                    Elm.Annotation.var oneName

                arg1 =
                    valueWithHelper [] oneName oneType

                ( twoName, twoIndex ) =
                    Compiler.getName twoBaseName oneIndex

                twoType =
                    Elm.Annotation.var twoName

                arg2 =
                    valueWithHelper [] twoName twoType

                ( threeName, threeIndex ) =
                    Compiler.getName threeBaseName twoIndex

                threeType =
                    Elm.Annotation.var threeName

                arg3 =
                    valueWithHelper [] threeName threeType

                ( fourName, fourIndex ) =
                    Compiler.getName fourBaseName threeIndex

                fourType =
                    Elm.Annotation.var fourName

                arg4 =
                    valueWithHelper [] fourName fourType

                ( fiveName, fiveIndex ) =
                    Compiler.getName fiveBaseName fourIndex

                fiveType =
                    Elm.Annotation.var fiveName

                arg5 =
                    valueWithHelper [] fiveName fiveType

                ( newIndex, expr ) =
                    Compiler.toExpressionDetails fiveIndex (toExpression arg1 arg2 arg3 arg4 arg5)
            in
            { expression =
                Exp.LambdaExpression
                    { args =
                        [ Compiler.nodify (Pattern.VarPattern oneName)
                        , Compiler.nodify (Pattern.VarPattern twoName)
                        , Compiler.nodify (Pattern.VarPattern threeName)
                        , Compiler.nodify (Pattern.VarPattern fourName)
                        , Compiler.nodify (Pattern.VarPattern fiveName)
                        ]
                    , expression = Compiler.nodify expr.expression
                    }
            , annotation =
                fnTypeApply expr.annotation
                    [ oneType
                    , twoType
                    , threeType
                    , fourType
                    , fiveType
                    ]
            , imports = expr.imports
            }


{-| -}
fn6 :
    String
    -> String
    -> String
    -> String
    -> String
    -> String
    -> (Expression -> Expression -> Expression -> Expression -> Expression -> Expression -> Expression)
    -> Expression
fn6 oneBaseName twoBaseName threeBaseName fourBaseName fiveBaseName sixBaseName toExpression =
    Compiler.Expression <|
        \index ->
            let
                childIndex =
                    Compiler.dive index

                ( oneName, oneIndex ) =
                    Compiler.getName oneBaseName childIndex

                oneType =
                    Elm.Annotation.var oneName

                arg1 =
                    valueWithHelper [] oneName oneType

                ( twoName, twoIndex ) =
                    Compiler.getName twoBaseName oneIndex

                twoType =
                    Elm.Annotation.var twoName

                arg2 =
                    valueWithHelper [] twoName twoType

                ( threeName, threeIndex ) =
                    Compiler.getName threeBaseName twoIndex

                threeType =
                    Elm.Annotation.var threeName

                arg3 =
                    valueWithHelper [] threeName threeType

                ( fourName, fourIndex ) =
                    Compiler.getName fourBaseName threeIndex

                fourType =
                    Elm.Annotation.var fourName

                arg4 =
                    valueWithHelper [] fourName fourType

                ( fiveName, fiveIndex ) =
                    Compiler.getName fiveBaseName fourIndex

                fiveType =
                    Elm.Annotation.var fiveName

                arg5 =
                    valueWithHelper [] fiveName fiveType

                ( sixName, sixIndex ) =
                    Compiler.getName sixBaseName fiveIndex

                sixType =
                    Elm.Annotation.var sixName

                arg6 =
                    valueWithHelper [] sixName sixType

                ( newIndex, expr ) =
                    Compiler.toExpressionDetails sixIndex (toExpression arg1 arg2 arg3 arg4 arg5 arg6)
            in
            { expression =
                Exp.LambdaExpression
                    { args =
                        [ Compiler.nodify (Pattern.VarPattern oneName)
                        , Compiler.nodify (Pattern.VarPattern twoName)
                        , Compiler.nodify (Pattern.VarPattern threeName)
                        , Compiler.nodify (Pattern.VarPattern fourName)
                        , Compiler.nodify (Pattern.VarPattern fiveName)
                        , Compiler.nodify (Pattern.VarPattern sixName)
                        ]
                    , expression = Compiler.nodify expr.expression
                    }
            , annotation =
                fnTypeApply expr.annotation
                    [ oneType
                    , twoType
                    , threeType
                    , fourType
                    , fiveType
                    , sixType
                    ]
            , imports = expr.imports
            }


{-| -}
type alias Declaration =
    Compiler.Declaration


{-| -}
comment : String -> Declaration
comment content =
    Compiler.Comment ("{- " ++ content ++ " -}")


renderDocumentation resolvedType bodyAnnotation =
    case resolvedType of
        Ok sig ->
            case bodyAnnotation of
                Ok inference ->
                    Nothing

                Err err ->
                    Just
                        (renderError err)

        Err err ->
            Just
                err


sep : String
sep =
    "\n----\n"


renderDebugDocumentation resolvedType bodyAnnotation =
    case resolvedType of
        Ok sig ->
            case bodyAnnotation of
                Ok inference ->
                    Just (Internal.Write.writeInference inference)

                Err err ->
                    Just
                        (renderError err)

        Err err ->
            case bodyAnnotation of
                Ok inference ->
                    Just
                        (Internal.Write.writeInference inference
                            ++ sep
                            ++ err
                        )

                Err _ ->
                    Just err


renderError : List Compiler.InferenceError -> String
renderError err =
    "-- ELM-CODEGEN ERROR --\n\n"
        ++ (err
                |> List.map Compiler.inferenceErrorToString
                |> String.join "\n\n"
           )
        ++ "\n\n"


{-| -}
declaration : String -> Expression -> Declaration
declaration name (Compiler.Expression toBody) =
    let
        body =
            toBody Compiler.startIndex

        resolvedType =
            body.annotation
                |> Result.mapError
                    renderError
                |> Result.andThen
                    (\sig -> Compiler.resolve sig.inferences sig.type_)
    in
    { documentation =
        Compiler.nodifyMaybe
            (renderDocumentation resolvedType body.annotation)
    , signature =
        case body.annotation of
            Ok sig ->
                case resolvedType of
                    Ok finalType ->
                        Just
                            (Compiler.nodify
                                { name = Compiler.nodify (Compiler.formatValue name)
                                , typeAnnotation =
                                    Compiler.nodify finalType
                                }
                            )

                    Err errMsg ->
                        Nothing

            Err _ ->
                Nothing
    , declaration =
        case body.expression of
            Exp.LambdaExpression lam ->
                Compiler.nodify
                    { name = Compiler.nodify (Compiler.formatValue name)
                    , arguments = lam.args
                    , expression = lam.expression
                    }

            _ ->
                Compiler.nodify
                    { name = Compiler.nodify (Compiler.formatValue name)
                    , arguments = []
                    , expression = Compiler.nodify body.expression
                    }
    }
        |> Declaration.FunctionDeclaration
        |> Compiler.Declaration Compiler.NotExposed body.imports


{-| For when you want the most control over a function being generated.

This is for when:

1.  You want your variable names to be exactly as provided
    (i.e. you don't want the variable name collision protection)
2.  You know exactly what type each variable should be.

-}
functionAdvanced : List ( String, Elm.Annotation.Annotation ) -> Expression -> Expression
functionAdvanced args fullExpression =
    case args of
        [] ->
            fullExpression

        _ ->
            Compiler.Expression <|
                \index ->
                    let
                        childIndex =
                            Compiler.dive index

                        expr =
                            case fullExpression of
                                Compiler.Expression toExpr ->
                                    toExpr childIndex
                    in
                    { expression =
                        Exp.LambdaExpression
                            { args =
                                List.map
                                    (\( name, ann ) -> Compiler.nodify (Pattern.VarPattern name))
                                    args
                            , expression = Compiler.nodify expr.expression
                            }
                    , annotation =
                        case expr.annotation of
                            Err err ->
                                Err err

                            Ok return ->
                                Ok
                                    { type_ =
                                        List.foldr
                                            (\( name, Compiler.Annotation ann ) fnbody ->
                                                Annotation.FunctionTypeAnnotation
                                                    (Compiler.nodify ann.annotation)
                                                    (Compiler.nodify fnbody)
                                            )
                                            return.type_
                                            args
                                    , inferences = return.inferences
                                    , aliases =
                                        List.foldl
                                            (\( _, ann ) gathered ->
                                                Compiler.mergeAliases (Compiler.getAliases ann) gathered
                                            )
                                            return.aliases
                                            args
                                    }
                    , imports = expr.imports
                    }


{-| You may run into situations where you don't know the number of arguments for a function at compile-time.

In that case you can use `function`. It follows the same pattern as the `fn*` functions.

Provide it with —

  - A list of argument names and an optional type
  - A function which will be given all the input arguments as `Expression`s.

-}
function : List ( String, Maybe Elm.Annotation.Annotation ) -> (List Expression -> Expression) -> Expression
function initialArgList toFullExpression =
    case initialArgList of
        [] ->
            toFullExpression []

        _ ->
            Compiler.Expression <|
                \index ->
                    let
                        childIndex =
                            Compiler.dive index

                        args =
                            List.foldl
                                (\( nameBase, maybeType ) found ->
                                    let
                                        ( name, newIndex ) =
                                            Compiler.getName nameBase found.index

                                        argType =
                                            Maybe.withDefault
                                                (Compiler.Annotation
                                                    { imports = []
                                                    , aliases = Compiler.emptyAliases
                                                    , annotation =
                                                        Annotation.GenericType
                                                            (Compiler.protectTypeName
                                                                nameBase
                                                                found.index
                                                            )
                                                    }
                                                )
                                                maybeType

                                        arg =
                                            value
                                                { importFrom = []
                                                , name = name
                                                , annotation = Just argType
                                                }
                                    in
                                    { index = newIndex
                                    , args = arg :: found.args
                                    , names = name :: found.names
                                    , types = Compiler.getInnerAnnotation argType :: found.types
                                    }
                                )
                                { args = []
                                , index = index
                                , names = []
                                , types = []
                                }
                                initialArgList

                        fullExpression =
                            toFullExpression (List.reverse args.args)

                        expr =
                            case fullExpression of
                                Compiler.Expression toExpr ->
                                    toExpr childIndex
                    in
                    { expression =
                        Exp.LambdaExpression
                            { args =
                                -- doing this to reverse things while building the patternlist
                                List.foldl
                                    (\n names -> Compiler.nodify (Pattern.VarPattern n) :: names)
                                    []
                                    args.names
                            , expression = Compiler.nodify expr.expression
                            }
                    , annotation =
                        case expr.annotation of
                            Err err ->
                                Err err

                            Ok return ->
                                -- args.types is already backwards, so this should work out ok
                                { type_ =
                                    List.foldl
                                        (\ann fnbody ->
                                            Annotation.FunctionTypeAnnotation
                                                (Compiler.nodify ann)
                                                (Compiler.nodify fnbody)
                                        )
                                        return.type_
                                        args.types
                                , inferences = return.inferences
                                , aliases =
                                    List.foldl
                                        (\( _, maybeAnn ) aliases ->
                                            case maybeAnn of
                                                Nothing ->
                                                    aliases

                                                Just ann ->
                                                    aliases
                                                        |> Compiler.mergeAliases
                                                            (Compiler.getAliases ann)
                                        )
                                        return.aliases
                                        initialArgList
                                }
                                    |> Ok
                    , imports = expr.imports
                    }


{-| Add a documentation comment to a declaration!
-}
withDocumentation : String -> Declaration -> Declaration
withDocumentation =
    Compiler.documentation


{-| By default, everything is exposed for your module.

However, you can tag specific declarations you want exposed, and then only those things will be exposed.

-}
expose : Declaration -> Declaration
expose =
    Compiler.expose


{-| You can also add a group tag to an exposed value. This will automatically group the `docs` statements in the module docs.

For precise control over what is rendered for the module comment, use [fileWith](#fileWith)

-}
exposeWith : { exposeConstructor : Bool, group : Maybe String } -> Declaration -> Declaration
exposeWith =
    Compiler.exposeWith


{-|

    import Elm.Annotation as Type

    Elm.portIncoming "receiveMessageFromTheWorld"
        [ Type.string
        , Type.int
        ]

Results in

    port receiveMessageFromTheWorld :
        (String -> Int -> msg)
        -> Sub msg

**Note** You generally only need one incoming and one outgoing port!

If you want to vary the messages going in and out of your app, don't use a huge number of ports, instead write Json encoders and decoders.

This will give you more flexibility in the future and save you having to wire up a bunch of stuff.

**Another note** - You may need to expose your port explicitly using `Elm.expose`

-}
portIncoming : String -> List Elm.Annotation.Annotation -> Declaration
portIncoming name args =
    { name = Compiler.nodify name
    , typeAnnotation =
        Compiler.nodify
            (case args of
                [] ->
                    Annotation.FunctionTypeAnnotation
                        (Compiler.nodify (Annotation.GenericType "msg"))
                        (Compiler.nodify sub)

                start :: remain ->
                    Annotation.FunctionTypeAnnotation
                        (groupAnn
                            (Compiler.nodify
                                (Compiler.getInnerAnnotation
                                    (Elm.Annotation.function
                                        args
                                        (Elm.Annotation.var "msg")
                                    )
                                )
                            )
                        )
                        (Compiler.nodify sub)
            )
    }
        |> Declaration.PortDeclaration
        |> Compiler.Declaration Compiler.NotExposed
            (List.concatMap Compiler.getAnnotationImports args)


groupAnn ann =
    Annotation.Tupled
        [ ann ]
        |> Compiler.nodify


sub : Annotation.TypeAnnotation
sub =
    Annotation.Typed
        (Compiler.nodify ( [ "Platform", "Sub" ], "Sub" ))
        [ Compiler.nodify (Annotation.GenericType "msg") ]


{-| Create a port that can send messages to the outside world!

    import Elm.Annotation as Type

    Elm.portOutgoing "tellTheWorld" Type.string

will generate

    port tellTheWorld : String -> Cmd msg

-}
portOutgoing : String -> Elm.Annotation.Annotation -> Declaration
portOutgoing name arg =
    { name = Compiler.nodify name
    , typeAnnotation =
        Compiler.nodify
            (Annotation.FunctionTypeAnnotation
                (Compiler.nodify (Compiler.getInnerAnnotation arg))
                (Compiler.nodify cmd)
            )
    }
        |> Declaration.PortDeclaration
        |> Compiler.Declaration Compiler.NotExposed (Compiler.getAnnotationImports arg)


cmd : Annotation.TypeAnnotation
cmd =
    Annotation.Typed
        (Compiler.nodify ( [ "Platform", "Cmd" ], "Cmd" ))
        [ Compiler.nodify (Annotation.GenericType "msg") ]



{- Infix operators!

   The goal is to make the following work


       one
           |> Elm.or two
           |> Elm.or three


       Elm.or one two




   We're not really worried about allowing operators to be partially applied in a way that results in the following code.

       (<=) 5

   I mean, come on, we're generating code.  Let's make it clearer.


   We're also not worried about recreating infix notation in this lib.  So no need to do:

       applyBinOp (int 2) plus (int 3)




-}


{-| Represents all of the binary operators allowed in Elm.
-}
type BinOp
    = BinOp String Infix.InfixDirection Int



-- {-| `>>`
-- -}
-- compose : Expression -> Expression -> Expression
-- compose =
--     applyBinOp (BinOp ">>" Infix.Left 9)
-- {-| `<<`
-- -}
-- composeLeft : Expression -> Expression -> Expression
-- composeLeft =
--     applyBinOp (BinOp "<<" Infix.Right 9)


{-| The to-the-power-of operator `^`
-}
power : Expression -> Expression -> Expression
power =
    applyNumber "^" Infix.Left


{-| `*`
-}
multiply : Expression -> Expression -> Expression
multiply =
    applyNumber "*" Infix.Left


{-| `/`
-}
divide : Expression -> Expression -> Expression
divide =
    applyInfix2 (BinOp "/" Infix.Left 7)
        (Internal.Types.function
            [ Internal.Types.float
            , Internal.Types.float
            ]
            Internal.Types.float
        )


{-| `//`
-}
intDivide : Expression -> Expression -> Expression
intDivide =
    applyInfix2 (BinOp "//" Infix.Left 7)
        (Internal.Types.function
            [ Internal.Types.int
            , Internal.Types.int
            ]
            Internal.Types.int
        )


{-| `+`
-}
plus : Expression -> Expression -> Expression
plus =
    applyNumber "+" Infix.Left


{-| `-`
-}
minus : Expression -> Expression -> Expression
minus =
    applyNumber "-" Infix.Left


{-| `++`
-}
append : Expression -> Expression -> Expression
append =
    applyInfix2
        (BinOp "++" Infix.Right 5)
        (Internal.Types.function
            [ Internal.Types.appendable
            , Internal.Types.appendable
            ]
            Internal.Types.appendable
        )


{-| `::`
-}
cons : Expression -> Expression -> Expression
cons =
    applyInfix2 (BinOp "::" Infix.Right 5)
        (Internal.Types.function
            [ Internal.Types.var "a"
            , Internal.Types.list (Internal.Types.var "a")
            ]
            (Internal.Types.list (Internal.Types.var "a"))
        )


{-| `==`
-}
equal : Expression -> Expression -> Expression
equal =
    applyInfix2 (BinOp "==" Infix.Left 4)
        (Internal.Types.function
            [ Internal.Types.var "a"
            , Internal.Types.var "a"
            ]
            Internal.Types.bool
        )


{-| `/=`
-}
notEqual : Expression -> Expression -> Expression
notEqual =
    applyInfix2 (BinOp "/=" Infix.Left 4)
        (Internal.Types.function
            [ Internal.Types.var "a"
            , Internal.Types.var "a"
            ]
            Internal.Types.bool
        )


{-| `<`
-}
lt : Expression -> Expression -> Expression
lt =
    applyInfix2 (BinOp "<" Infix.Non 4)
        (Internal.Types.function
            [ Internal.Types.comparable
            , Internal.Types.comparable
            ]
            Internal.Types.bool
        )


{-| `>`
-}
gt : Expression -> Expression -> Expression
gt =
    applyInfix2 (BinOp ">" Infix.Non 4)
        (Internal.Types.function
            [ Internal.Types.comparable
            , Internal.Types.comparable
            ]
            Internal.Types.bool
        )


{-| `<=`
-}
lte : Expression -> Expression -> Expression
lte =
    applyInfix2 (BinOp "<=" Infix.Non 4)
        (Internal.Types.function
            [ Internal.Types.comparable
            , Internal.Types.comparable
            ]
            Internal.Types.bool
        )


{-| `>=`
-}
gte : Expression -> Expression -> Expression
gte =
    applyInfix2 (BinOp ">=" Infix.Non 4)
        (Internal.Types.function
            [ Internal.Types.comparable
            , Internal.Types.comparable
            ]
            Internal.Types.bool
        )


{-| `&&`
-}
and : Expression -> Expression -> Expression
and =
    applyInfix2 (BinOp "&&" Infix.Right 3)
        (Internal.Types.function
            [ Internal.Types.bool
            , Internal.Types.bool
            ]
            Internal.Types.bool
        )


{-| `||`
-}
or : Expression -> Expression -> Expression
or =
    applyInfix2 (BinOp "||" Infix.Right 2)
        (Internal.Types.function
            [ Internal.Types.bool
            , Internal.Types.bool
            ]
            Internal.Types.bool
        )


{-| used in the `elm/parser` library

`|=`

-}
keep : Expression -> Expression -> Expression
keep =
    applyInfix2 (BinOp "|=" Infix.Left 5)
        -- Parser (a -> b) -> Parser a -> Parser b
        (Internal.Types.function
            [ Internal.Types.custom [ "Parser" ]
                "Parser"
                [ Internal.Types.var "a"
                , Internal.Types.var "b"
                ]
            , Internal.Types.custom [ "Parser" ]
                "Parser"
                [ Internal.Types.var "a"
                ]
            ]
            (Internal.Types.custom [ "Parser" ]
                "Parser"
                [ Internal.Types.var "b"
                ]
            )
        )


{-| `|.`
-}
skip : Expression -> Expression -> Expression
skip =
    applyInfix2 (BinOp "|." Infix.Left 6)
        (Internal.Types.function
            [ Internal.Types.custom [ "Parser" ]
                "Parser"
                [ Internal.Types.var "keep"
                ]
            , Internal.Types.custom [ "Parser" ]
                "Parser"
                [ Internal.Types.var "ignore"
                ]
            ]
            (Internal.Types.custom [ "Parser" ]
                "Parser"
                [ Internal.Types.var "keep"
                ]
            )
        )


{-| `</>` used in url parsing
-}
slash : Expression -> Expression -> Expression
slash =
    applyInfix2 (BinOp "</>" Infix.Right 7)
        --  Parser a b -> Parser b c -> Parser a c
        (Internal.Types.function
            [ Internal.Types.custom [ "Url", "Parser" ]
                "Parser"
                [ Internal.Types.var "a"
                , Internal.Types.var "b"
                ]
            , Internal.Types.custom [ "Url", "Parser" ]
                "Parser"
                [ Internal.Types.var "b"
                , Internal.Types.var "c"
                ]
            ]
            (Internal.Types.custom [ "Url", "Parser" ]
                "Parser"
                [ Internal.Types.var "a"
                , Internal.Types.var "c"
                ]
            )
        )


{-| `<?>` used in url parsing
-}
query : Expression -> Expression -> Expression
query =
    applyInfix2 (BinOp "<?>" Infix.Left 8)
        -- Parser a (query -> b) -> Parser query -> Parser a b
        (Internal.Types.function
            [ Internal.Types.custom [ "Url", "Parser" ]
                "Parser"
                [ Internal.Types.var "a"
                , Internal.Types.function
                    [ Internal.Types.var "query"
                    ]
                    (Internal.Types.var "b")
                ]
            , Internal.Types.custom [ "Url", "Parser", "Query" ]
                "Parser"
                [ Internal.Types.var "query"
                ]
            ]
            (Internal.Types.custom [ "Url", "Parser" ]
                "Parser"
                [ Internal.Types.var "a"
                , Internal.Types.var "b"
                ]
            )
        )


{-| `|>`

    Elm.value "thang"
        |> Elm.pipe (Elm.value "thang2")
        |> Elm.pipe (Elm.value "thang3")

Results in

    thang
        |> thang2
        |> thang3

-}
pipe : Expression -> Expression -> Expression
pipe r l =
    applyInfix2 (BinOp "|>" Infix.Left 0)
        (Internal.Types.function
            [ Internal.Types.var "a"
            , Internal.Types.function
                [ Internal.Types.var "a"
                ]
                (Internal.Types.var "b")
            ]
            (Internal.Types.var "b")
        )
        l
        r


{-| `<|`
-}
pipeLeft : Expression -> Expression -> Expression
pipeLeft =
    applyInfix2 (BinOp "<|" Infix.Right 0)
        (Internal.Types.function
            [ Internal.Types.function
                [ Internal.Types.var "a"
                ]
                (Internal.Types.var "b")
            , Internal.Types.var "a"
            ]
            (Internal.Types.var "b")
        )


applyInfix2 : BinOp -> Annotation.TypeAnnotation -> Expression -> Expression -> Expression
applyInfix2 (BinOp symbol dir _) infixAnnotation l r =
    Compiler.Expression <|
        \index ->
            let
                ( leftIndex, left ) =
                    Compiler.toExpressionDetails index l

                ( rightIndex, right ) =
                    Compiler.toExpressionDetails leftIndex r

                annotationIndex =
                    Compiler.next rightIndex
            in
            { expression =
                Exp.OperatorApplication symbol
                    dir
                    (Compiler.nodify left.expression)
                    (Compiler.nodify right.expression)
            , annotation =
                Compiler.applyType
                    (Ok
                        { type_ = infixAnnotation
                        , inferences = Dict.empty
                        , aliases = Compiler.emptyAliases
                        }
                    )
                    [ left
                    , right
                    ]
            , imports = left.imports ++ right.imports
            }


applyNumber : String -> Infix.InfixDirection -> Expression -> Expression -> Expression
applyNumber symbol dir l r =
    Compiler.Expression <|
        \index ->
            let
                ( leftIndex, left ) =
                    Compiler.toExpressionDetails index l

                ( rightIndex, right ) =
                    Compiler.toExpressionDetails leftIndex r

                annotationIndex =
                    Compiler.next rightIndex

                numberTypeName =
                    Compiler.protectTypeName
                        "number"
                        annotationIndex
            in
            { expression =
                Exp.OperatorApplication symbol
                    dir
                    (Compiler.nodify left.expression)
                    (Compiler.nodify right.expression)
            , annotation =
                Compiler.applyType
                    (Ok
                        { inferences = Dict.empty
                        , aliases = Compiler.emptyAliases
                        , type_ =
                            Annotation.FunctionTypeAnnotation
                                (Compiler.nodify
                                    (Annotation.GenericType numberTypeName)
                                )
                                (Compiler.nodify
                                    (Annotation.FunctionTypeAnnotation
                                        (Compiler.nodify
                                            (Annotation.GenericType numberTypeName)
                                        )
                                        (Compiler.nodify
                                            (Annotation.GenericType numberTypeName)
                                        )
                                    )
                                )
                        }
                    )
                    [ left
                    , right
                    ]
            , imports = left.imports ++ right.imports
            }


{-| -}
unsafe : String -> Declaration
unsafe source =
    Compiler.Block (String.trim source)


{-| -}
parse : String -> Result String { declarations : List Declaration }
parse source =
    case Elm.Parser.parse source of
        Err deadends ->
            Err "Uh oh"

        Ok raw ->
            let
                parsedFile =
                    Elm.Processing.process Elm.Processing.init
                        raw

                exposedList =
                    Compiler.denode parsedFile.moduleDefinition
                        |> Elm.Syntax.Module.exposingList

                declarations =
                    List.map
                        (\dec ->
                            let
                                declar =
                                    Compiler.denode dec
                            in
                            ( Node.range dec
                                |> (.start >> .row)
                            , Compiler.Declaration
                                (determineExposure declar exposedList)
                                []
                                declar
                            )
                        )
                        parsedFile.declarations

                comments =
                    List.map
                        (\nodedComment ->
                            ( Node.range nodedComment
                                |> (.start >> .row)
                            , Compiler.Comment
                                (Compiler.denode nodedComment)
                            )
                        )
                        parsedFile.comments
            in
            Ok
                { declarations =
                    List.sortBy
                        Tuple.first
                        (declarations ++ comments)
                        |> List.map Tuple.second
                }


determineExposure : Declaration.Declaration -> Expose.Exposing -> Compiler.Expose
determineExposure dec exposedDec =
    case exposedDec of
        Expose.All _ ->
            Compiler.Exposed { group = Nothing, exposeConstructor = True }

        Expose.Explicit nodes ->
            case dec of
                Declaration.FunctionDeclaration myFn ->
                    case Compiler.denode myFn.declaration of
                        implementation ->
                            case Compiler.denode implementation.name of
                                name ->
                                    if List.any (valueIsExposed name) nodes then
                                        Compiler.Exposed { group = Nothing, exposeConstructor = False }

                                    else
                                        Compiler.NotExposed

                Declaration.AliasDeclaration typeAlias ->
                    case Compiler.denode typeAlias.name of
                        name ->
                            if List.any (typeIsExposed name) nodes then
                                Compiler.Exposed { group = Nothing, exposeConstructor = False }

                            else
                                Compiler.NotExposed

                Declaration.CustomTypeDeclaration type_ ->
                    case Compiler.denode type_.name of
                        name ->
                            if List.any (typeIsExposed name) nodes then
                                Compiler.Exposed { group = Nothing, exposeConstructor = False }

                            else if List.any (typeConstructorIsExposed name) nodes then
                                Compiler.Exposed { group = Nothing, exposeConstructor = True }

                            else
                                Compiler.NotExposed

                Declaration.PortDeclaration sig ->
                    Compiler.NotExposed

                Declaration.InfixDeclaration infixDec ->
                    Compiler.NotExposed

                Declaration.Destructuring pattern exp ->
                    Compiler.NotExposed


valueIsExposed : String -> Node.Node Expose.TopLevelExpose -> Bool
valueIsExposed name node =
    case Compiler.denode node of
        Expose.InfixExpose _ ->
            False

        Expose.FunctionExpose fnName ->
            fnName == name

        Expose.TypeOrAliasExpose _ ->
            False

        Expose.TypeExpose _ ->
            False


typeIsExposed : String -> Node.Node Expose.TopLevelExpose -> Bool
typeIsExposed name node =
    case Compiler.denode node of
        Expose.InfixExpose _ ->
            False

        Expose.FunctionExpose fnName ->
            False

        Expose.TypeOrAliasExpose typeName ->
            name == typeName

        Expose.TypeExpose _ ->
            False


typeConstructorIsExposed : String -> Node.Node Expose.TopLevelExpose -> Bool
typeConstructorIsExposed name node =
    case Compiler.denode node of
        Expose.InfixExpose _ ->
            False

        Expose.FunctionExpose fnName ->
            False

        Expose.TypeOrAliasExpose typeName ->
            name == typeName

        Expose.TypeExpose myType ->
            name == myType.name

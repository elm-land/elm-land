module Internal.ImportsAndExposing exposing (sortAndDedupExposings, sortAndDedupImports)

import Elm.Syntax.Exposing exposing (ExposedType, Exposing(..), TopLevelExpose(..))
import Elm.Syntax.Import exposing (Import)
import Elm.Syntax.Node as Node exposing (Node(..))
import Elm.Syntax.Range exposing (emptyRange)



-- Sorting and deduplicating exposings.


sortAndDedupExposings : List TopLevelExpose -> List TopLevelExpose
sortAndDedupExposings tlExposings =
    List.sortWith topLevelExposeOrder tlExposings
        |> groupByExposingName
        |> List.map combineTopLevelExposes


topLevelExposeOrder : TopLevelExpose -> TopLevelExpose -> Order
topLevelExposeOrder tlel tler =
    case ( tlel, tler ) of
        ( InfixExpose _, InfixExpose _ ) ->
            compare (topLevelExposeName tlel) (topLevelExposeName tler)

        ( InfixExpose _, _ ) ->
            LT

        ( _, InfixExpose _ ) ->
            GT

        ( _, _ ) ->
            compare (topLevelExposeName tlel) (topLevelExposeName tler)


topLevelExposeName : TopLevelExpose -> String
topLevelExposeName tle =
    case tle of
        InfixExpose val ->
            val

        FunctionExpose val ->
            val

        TypeOrAliasExpose val ->
            val

        TypeExpose exposedType ->
            exposedType.name


groupByExposingName : List TopLevelExpose -> List (List TopLevelExpose)
groupByExposingName innerImports =
    let
        ( _, hdGroup, remGroups ) =
            case innerImports of
                [] ->
                    ( "", [], [ [] ] )

                hd :: _ ->
                    List.foldl
                        (\exp ( currName, currAccum, accum ) ->
                            let
                                nextName =
                                    topLevelExposeName exp
                            in
                            if nextName == currName then
                                ( currName, exp :: currAccum, accum )

                            else
                                ( nextName, [ exp ], currAccum :: accum )
                        )
                        ( topLevelExposeName hd, [], [] )
                        innerImports
    in
    (hdGroup :: remGroups) |> List.reverse


combineTopLevelExposes : List TopLevelExpose -> TopLevelExpose
combineTopLevelExposes exposes =
    case exposes of
        [] ->
            InfixExpose ""

        hd :: tl ->
            List.foldl
                (\exp result ->
                    case ( exp, result ) of
                        ( TypeExpose typeExpose, _ ) ->
                            case typeExpose.open of
                                Just _ ->
                                    exp

                                _ ->
                                    result

                        ( _, TypeExpose typeExpose ) ->
                            case typeExpose.open of
                                Just _ ->
                                    result

                                _ ->
                                    exp

                        ( _, _ ) ->
                            result
                )
                hd
                tl


joinMaybeExposings : Maybe Exposing -> Maybe Exposing -> Maybe Exposing
joinMaybeExposings maybeLeft maybeRight =
    case ( maybeLeft, maybeRight ) of
        ( Nothing, Nothing ) ->
            Nothing

        ( Just left, Nothing ) ->
            Just left

        ( Nothing, Just right ) ->
            Just right

        ( Just left, Just right ) ->
            joinExposings left right |> Just


joinExposings : Exposing -> Exposing -> Exposing
joinExposings left right =
    case ( left, right ) of
        ( All range, _ ) ->
            All range

        ( _, All range ) ->
            All range

        ( Explicit leftNodes, Explicit rightNodes ) ->
            List.append (denodeAll leftNodes) (denodeAll rightNodes)
                --|> sortAndDedupExposings
                |> nodifyAll
                |> Explicit


sortAndDedupExposing : Exposing -> Exposing
sortAndDedupExposing exp =
    case exp of
        All range ->
            All range

        Explicit nodes ->
            denodeAll nodes
                |> sortAndDedupExposings
                |> nodifyAll
                |> Explicit



-- Sorting and deduplicating imports.


sortAndDedupImports : List Import -> List Import
sortAndDedupImports imports =
    let
        impName imp =
            denode imp.moduleName
    in
    List.sortBy impName imports
        |> groupByModuleName
        |> List.map combineImports


groupByModuleName : List Import -> List (List Import)
groupByModuleName innerImports =
    let
        ( _, hdGroup, remGroups ) =
            case innerImports of
                [] ->
                    ( [], [], [ [] ] )

                hd :: _ ->
                    List.foldl
                        (\imp ( currName, currAccum, accum ) ->
                            let
                                nextName =
                                    denode imp.moduleName
                            in
                            if nextName == currName then
                                ( currName, imp :: currAccum, accum )

                            else
                                ( nextName, [ imp ], currAccum :: accum )
                        )
                        ( denode hd.moduleName, [], [] )
                        innerImports
    in
    (hdGroup :: remGroups) |> List.reverse


combineImports : List Import -> Import
combineImports innerImports =
    case innerImports of
        [] ->
            { moduleName = nodify []
            , moduleAlias = Nothing
            , exposingList = Nothing
            }

        hd :: tl ->
            let
                combinedImports =
                    List.foldl
                        (\imp result ->
                            { moduleName = imp.moduleName
                            , moduleAlias = or imp.moduleAlias result.moduleAlias
                            , exposingList =
                                joinMaybeExposings (denodeMaybe imp.exposingList) (denodeMaybe result.exposingList)
                                    |> nodifyMaybe
                            }
                        )
                        hd
                        tl
            in
            { combinedImports
                | exposingList =
                    Maybe.map (denode >> sortAndDedupExposing >> nodify)
                        combinedImports.exposingList
            }


or : Maybe a -> Maybe a -> Maybe a
or ma mb =
    case ma of
        Nothing ->
            mb

        Just _ ->
            ma



-- Helper functions


denode : Node a -> a
denode =
    Node.value


denodeAll : List (Node a) -> List a
denodeAll =
    List.map denode


denodeMaybe : Maybe (Node a) -> Maybe a
denodeMaybe =
    Maybe.map denode


nodify : a -> Node a
nodify exp =
    Node emptyRange exp


nodifyAll : List a -> List (Node a)
nodifyAll =
    List.map nodify


nodifyMaybe : Maybe a -> Maybe (Node a)
nodifyMaybe =
    Maybe.map nodify

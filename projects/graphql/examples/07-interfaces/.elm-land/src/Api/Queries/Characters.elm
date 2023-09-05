module Api.Queries.Characters exposing
    ( Data, new
    , Character
    )

{-|

@docs Data, new
@docs Character

-}

import Api.Queries.Characters.Character
import GraphQL.Decode
import GraphQL.Operation



-- OUTPUT


type alias Data =
    { characters : List Character
    }


type alias Character =
    Api.Queries.Characters.Character.Character



-- OPERATION


new : GraphQL.Operation.Operation Data
new =
    GraphQL.Operation.new
        { name = "Characters"
        , query = """
            query Characters {
              characters {
                __typename # 🌈 Injected by @elm-land/graphql ✨
                id
                name
                ...on Human {
                  hasHair
                }
                ...on Droid {
                  primaryFunction
                }
              }
            }
          """
        , variables = []
        , decoder = decoder
        }


decoder : GraphQL.Decode.Decoder Data
decoder =
    GraphQL.Decode.object Data
        |> GraphQL.Decode.field
            { name = "characters"
            , decoder =
                GraphQL.Decode.union
                    [ GraphQL.Decode.variant
                        { typename = "Human"
                        , onVariant = Api.Queries.Characters.Character.On_Human
                        , decoder =
                            GraphQL.Decode.object Api.Queries.Characters.Character.Human
                                |> GraphQL.Decode.field
                                    { name = "id"
                                    , decoder = GraphQL.Decode.id
                                    }
                                |> GraphQL.Decode.field
                                    { name = "name"
                                    , decoder = GraphQL.Decode.string
                                    }
                                |> GraphQL.Decode.field
                                    { name = "hasHair"
                                    , decoder = GraphQL.Decode.bool
                                    }
                        }
                    , GraphQL.Decode.variant
                        { typename = "Droid"
                        , onVariant = Api.Queries.Characters.Character.On_Droid
                        , decoder =
                            GraphQL.Decode.object Api.Queries.Characters.Character.Droid
                                |> GraphQL.Decode.field
                                    { name = "id"
                                    , decoder = GraphQL.Decode.id
                                    }
                                |> GraphQL.Decode.field
                                    { name = "name"
                                    , decoder = GraphQL.Decode.string
                                    }
                                |> GraphQL.Decode.field
                                    { name = "primaryFunction"
                                    , decoder =
                                        GraphQL.Decode.string
                                            |> GraphQL.Decode.maybe
                                    }
                        }
                    ]
                    |> GraphQL.Decode.list
            }

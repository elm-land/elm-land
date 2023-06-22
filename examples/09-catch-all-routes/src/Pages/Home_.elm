module Pages.Home_ exposing (page)

import Html exposing (..)
import Html.Attributes exposing (..)
import Route.Path
import View exposing (View)


type alias Link =
    { label : String
    , path : Route.Path.Path
    }


page : View msg
page =
    { title = "Homepage"
    , body =
        [ h1 [] [ text "🏡 Homepage" ]
        , p [] [ text "Click a link below to learn how URLs work in Elm Land" ]
        , section []
            [ h3 [] [ text "🧑\u{200D}💻 Users" ]
            , viewLinks
                [ { label = "@elm-land"
                  , path = Route.Path.User_ { user = "elm-land" }
                  }
                , { label = "@ryannhg"
                  , path = Route.Path.User_ { user = "ryannhg" }
                  }
                , { label = "@elm"
                  , path = Route.Path.User_ { user = "elm" }
                  }
                ]
            ]
        , section []
            [ h3 [] [ text "📦 Repos" ]
            , viewLinks
                [ { label = "@elm-land/vscode"
                  , path =
                        Route.Path.User__Repo_
                            { user = "elm-land"
                            , repo = "vscode"
                            }
                  }
                , { label = "@ryannhg/graphql"
                  , path =
                        Route.Path.User__Repo_
                            { user = "ryannhg"
                            , repo = "graphql"
                            }
                  }
                , { label = "@elm/compiler"
                  , path =
                        Route.Path.User__Repo_
                            { user = "elm"
                            , repo = "compiler"
                            }
                  }
                ]
            ]
        , section []
            [ h3 [] [ text "🗃 File Explorer" ]
            , viewLinks
                [ { label = "README from @elm-land/vscode"
                  , path =
                        Route.Path.User__Repo__Tree_Branch__ALL_
                            { user = "elm-land"
                            , repo = "vscode"
                            , branch = "main"
                            , all_ = [ "README.md" ]
                            }
                  }
                , { label = "`Decode.elm` from @ryannhg/graphql"
                  , path =
                        Route.Path.User__Repo__Tree_Branch__ALL_
                            { user = "ryannhg"
                            , repo = "graphql"
                            , branch = "main"
                            , all_ = [ "src", "GraphQL", "Decode.elm" ]
                            }
                  }
                , { label = "`Compile.hs` from @elm/compiler"
                  , path =
                        Route.Path.User__Repo__Tree_Branch__ALL_
                            { user = "elm"
                            , repo = "compiler"
                            , branch = "master"
                            , all_ = [ "compiler", "src", "Compile.hs" ]
                            }
                  }
                ]
            ]
        ]
    }


viewLinks : List Link -> Html msg
viewLinks links =
    ul [] (List.map viewLink links)


viewLink : Link -> Html msg
viewLink link =
    li []
        [ a [ Route.Path.href link.path ] [ text link.label ]
        ]

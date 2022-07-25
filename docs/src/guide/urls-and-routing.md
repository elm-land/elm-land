# Urls & Routing

For each page, Elm provides a `Route` type that has information about your current URL path, any dynamic parameters, query strings, hashes, etc

```elm
module Route exposing (Route)

import Route.Path exposing (Path)
import Url exposing (Url)

type alias Route params =
    { path : Route.Path.Path
    , params : params
    , query : Dict String String
    , hash : Maybe String
    , url : Url
    }
```


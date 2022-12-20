# Query parameters

### What we'll learn

- How to __get URL information__ from the current route
- How to __add query parameters__ that filter data
- How to make filters __run after refreshing the page__

<BrowserWindow src="/images/guide/query-parameters.gif" alt="Demo of table with filters and sorting" />



## Routes and URLs

For each page, Elm provides a `Route` type that has information about your current URL. This includes the current page you are on, dynamic route parameters, query strings, hashes, and more!

Depending on the current URL, the value of `route` might be slightly different.

Page | URLs | Elm file
:-- | :-- | :--
Homepage | `/` | `src/Pages/Home_.elm`
Blog Landing | `/blog` | `src/Pages/Blog.elm`
Blog Detail | `/blog/:id` | `src/Pages/Blog/Id_.elm`
Blog Topic Detail | `/blog/:topic/:id` | `src/Pages/Blog/Topic_/Id_.elm`

Let's look at an example for a few URLs:


### URL: `/`

Matches page: `./src/Pages/Home_.elm`

```elm
route : Route ()
route =
    { path = Route.Path.Home_
    , params = ()
    , query = Dict.fromList []
    , hash = Nothing
    , url = ...
    }
```


### URL: `/blog`

Matches page: `./src/Pages/Blog.elm`

```elm
route : Route ()    
route =
    { path = Route.Path.Blog
    , params = ()
    , query = Dict.fromList []
    , hash = Nothing
    , url = ...
    }
```


### URL: `/blog/hello-world`

Matches page: `./src/Pages/Blog/Id_.elm`

```elm
route : Route { id : String }
route =
    { path = Route.Path.Blog_Id_ { id = "hello-world" }
    , params = { id = "hello-world" }
    , query = Dict.fromList []
    , hash = Nothing
    , url = ...
    }
```


### URL: `/blog/tech/learning-elm`

Matches page: `./src/Pages/Blog/Topic_/Id_.elm`

```elm
route : Route { topic : String, id : String }
route =
    { path = Route.Path.Blog_Id_ { topic = "tech", id = "learning-elm" }
    , params = { id = "learning-elm" }
    , query = Dict.fromList []
    , hash = Nothing
    , url = ...
    }
```


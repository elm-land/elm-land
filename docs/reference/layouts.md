# "Layouts" module

This module is generated based on the current files in your `src/Layouts` folder. It is designed to be used with [Page.withLayout](/reference/page.html#page-withlayout) to specify what layout should be used on a page.

Every `Layouts` module will look a bit different, but all of them will include a custom type named `Layout`. That custom type will include variants for each available layout in your application.

Here's an example:

```elm
module Layouts exposing (Layout(..), map)

type Layout msg
    = Sidebar Layouts.Sidebar.Props
    | Header Layouts.Header.Props

-- ...
```

To create a `Layouts.Layout` value, you'll what to use a custom type variant like `Layouts.Sidebar`, and provide the correct props. That will return a valid layout that can be used with the `Page.withLayout` function.
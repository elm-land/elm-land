# Layouts

## Reusing UI across pages

It's common in a web application to have common UI shared across pages. For example, on Twitter, there is a sidebar layout that persists as you go from your feed to your profile page.

Let's add a sidebar layout to our Elm Land application, so we can easily navigate from one page to another.

```bash
npx elm-land add layout Sidebar
```

<code-group>
<code-block title="Terminal output">

```txt
🌈 New layout added!

You can edit your layout here:
👉 ./src/Layouts/Sidebar.elm
```

</code-block>
</code-group>

This will create a new file at `src/Layouts/Sidebar.elm` with the following contents:


<code-group>
<code-block title="src/Layouts/Sidebar.elm">

```elm
module Layouts.Sidebar exposing (layout)

import Html exposing (Html)
import Html.Attributes as Attr


layout : { page : Html msg } -> Html msg
layout { page } =
    Html.div
        [ Attr.class "layout" ]
        [ page ]
```

</code-block>
</code-group>
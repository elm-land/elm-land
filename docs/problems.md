# Problems

When there's a problem with your Elm code, the Elm compiler gives helpful error messages. It's important that you also get a great experience when using Elm Land, a framework with a few rules added on top of Elm.

Elm Land has it's own set of problems it reports at compile time, and this page is a collection of them. It also helps add more context in case you're unsure why the issue is a problem in the first place.

The goal with Elm Land error messages is to never report an error in a generated Elm file. If you experience any Elm errors inside of the `.elm-land/src` folder, please let us know in the `#report-a-bug` channel of the [Elm Land Discord](https://join.elm.land).

## Missing exposed type

Elm Land uses code generation to save you time during application development. The generated code needs to make some assumptions about what is being exposed by each of your pages, layouts, and other customized modules.

For example, Elm Land expects every page to expose these two types:

1. `Model` – Allows Elm Land to connect to automatically initialize your page when the URL changes
2. `Msg` - Allows Elm Land to connect your page's messages to the overall application


## Missing exposed value

Elm Land uses code generation to save you time during application development. The generated code needs to make some assumptions about what is being exposed by each of your pages, layouts, and other customized modules.

For example, Elm Land expects every page to expose the `page` function. Without it, the generated code cannot run your `init`, `update`, or `view` functions.


## Missing type annotation

Although type annotations are optional in Elm, Elm Land uses them to quickly verify that functions have the correct signature. This helps prevent strange errors in generated files.

For example, if the `page` function returned a `String` instead of a `Page Model Msg` you would get a weird error in generated code where the mismatch happened.

To fix this problem, please add in the recommended type annotation from the error message.


## Unexpected type annotation

This error can occur if a type annotation was changed on a value that Elm Land is using. For example, if the `page` function now returns a `String` instead of a `Page Model Msg`, Elm Land won't be able to connect it to the application.

To fix this problem, please use the recommended type annotation from the error message.

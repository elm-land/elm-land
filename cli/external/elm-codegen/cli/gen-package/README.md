# Generating bindings for an existing package


It's pretty common to want to generate code that uses a specific library.

This folder is a placeholder for the code that will generate helpers for a given package.

So if you wanted to work with the `Svg` package, you could run

`elm-codegen package elm/svg`

And a `Elm.Gen.Svg` package would be generated based on what's exposed from the svg package.
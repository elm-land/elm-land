# Writing a generator

Let's write some code to generate elm code!

Most of the things you'll be writing are `Expressions`.

For example:

```elm
import Elm

myFirstExpression : Elm.Expression
myFirstExpression =
    Elm.plus (Elm.int 42) (Elm.int 42)
```

Which, if you use `Elm.toString` on it

```elm
asAString : String
asAString =
    Elm.toString (Elm.plus (Elm.int 42) (Elm.int 42))
```

would generate exactly what you might think:

```elm
"42 + 42"
```

Whew, so impressive.

However, we need some more tricks if we want to generate a real Elm file.

In order to include something in a file, we need it to be a `Declaration`, which really just means we need to give it a name.

```elm
import Elm

myFirstDeclaration : Elm.Declaration
myFirstDeclaration =
    Elm.declaration "eightyFour"
        (Elm.plus (Elm.int 42) (Elm.int 42))
```

If we turn **this** into a string using `Elm.declarationToString`, we get the following:

```elm
eightyFour : Int
eightyFour =
    42 + 42
```

It was even able to figure out the type signature 💪

Finally, we can stuff a list of `Declarations` into `Elm.file` to get a proper file.

```elm

myFile : Elm.File
myFile =
 Elm.file [ "eightyFour" ]
    [ Elm.declaration "fortyTwo"
        (Elm.plus (Elm.int 42) (Elm.int 42))
    ]
```

**Note** — An `Elm.File` is just a record that has

```elm
type alias File =
    { path : String
    , contents : String
    }
```

So, looking at `myFile.contents` shows

```elm
module MyFirstFile exposing (..)

{-|-}

eightyFour : Int
eightyFour =
    42 + 42
```

There's a bunch more, but it's probably better covered by the [elm-codegen package documentation](https://elm-doc-preview.netlify.app/?repo=mdgriffith/elm-codegen).

Let's take a look at one final thing before you go!

💁 [Using packages](https://github.com/mdgriffith/elm-codegen/tree/main/guide/UsingPackages.md)

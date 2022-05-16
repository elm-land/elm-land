# Getting Started

Elm CodeGen is an Elm package and CLI tool.

The `elm-codegen` CLI tool mainly helps with two things.

- Running the generator and creating the actual files.
- [Installing package helpers](https://github.com/mdgriffith/elm-codegen/tree/main/guide/UsingPackages.md), which we'll cover a little later.

First to get you started, let's initialize a new project.

In a fresh directory, run `elm-codegen init` which will —

1. Create an `elm.codegen.json` file in your current directory. It tracks what package helpers you've installed.

2. Create a `codegen` folder.

   Just like `tests` go in your `tests` folder and `benchmarks` go in your `benchmarks` folder, `codegen` should be the standard place where codegen lives.

   This is where your codegen code will go, and it's where any package helpers you install will be located. Here's what is created in the `codegen` folder —

   - An `elm.json` file.
   - `Generate.elm` — This is your new generator and where you'll be working!
   - `Elm.Gen.elm` — This has a few ports that `elm-codegen` is expecting when it runs your generator. Take a peek inside, it's not very scary.
   - We'll also install helpers for `elm/core`.

Now that we've done that, we can run `elm-codegen run`!

This will run `codegen/Generate.elm` and create a `generated` folder with a `HelloWorld.elm` file in it 🎉

You should be good to proceed to the [Writing a Generator](https://github.com/mdgriffith/elm-codegen/tree/main/guide/WritingAGenerator.md) section, but before you go, let's quickly cover some other useful options in the `elm-codegen` CLI.

- `--output=generated` — Specify a different directory to generate files in.
- `--watch` — Watch the `.elm` files in the `codegen` directory and regenerate if anything changes.
- `--debug` — Allow `Debug.log` in your generator. This is off by default.
- `--flags={"myStuff": true}` — Pass flags to your genrator as inline `JSON`.
- `--flags-from=<file.json>` — Read a `JSON` file and pass it in to the generator as flags.

Great! Onward!

💁 [Writing a Generator](https://github.com/mdgriffith/elm-codegen/tree/main/guide/WritingAGenerator.md)

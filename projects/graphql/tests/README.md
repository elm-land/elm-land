# Tests for @elm-land/graphql

## Goals

This test suite was designed with two user-facing goals in mind:
1. Ensure that everything works as documented at https://elm.land/graphql
2. Catch unexpected regressions to provide a reliable experience

## Philosophy

The `@elm-land/graphql` plugin uses these tests to ensure that all our features work as expected. Rather than writing Elm unit tests on individual functions, here we have written tiny example projects that reflect features of the language.

For example, our first test `01-hello-world` makes sure that `elm-land graphql build` succeeds for the simplest possible GraphQL query, and that a project using it can use the generated code as expected.

## Running the test suite

Here's how to run the test suite:

```sh
# First-time install, build test dependencies, etc
npm run test:setup

# Actually runs the test suite
npm run test
```
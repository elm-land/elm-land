load helpers

@test "can run 'elm-land graphql'" {
  run elm-land graphql
  expectOutputContains "Elm Land"
}

@test "can run 'elm'" {
  run npx elm
  expectOutputContains "Elm 0.19.1"
}

@test "can compile 'examples/01-queries'" {
    cd examples/01-queries
    rm -rf .elm-land

    run elm-land graphql build
    expectToPass
    npx elm make src/Main.elm --output=/dev/null > /dev/null
}

@test "can compile 'examples/02-mutations'" {
    cd examples/02-mutations
    rm -rf .elm-land

    run elm-land graphql build
    expectToPass
    npx elm make src/Main.elm --output=/dev/null > /dev/null
}

@test "can compile 'examples/03-fragments'" {
    cd examples/03-fragments
    rm -rf .elm-land

    run elm-land graphql build
    expectToPass
    npx elm make src/Main.elm --output=/dev/null > /dev/null
}

@test "can compile 'examples/04-input-types'" {
    cd examples/04-input-types
    rm -rf .elm-land

    run elm-land graphql build
    expectToPass
    npx elm make src/Main.elm --output=/dev/null > /dev/null
}

@test "can compile 'examples/08-nested-input-types'" {
    cd examples/08-nested-input-types
    rm -rf .elm-land

    run elm-land graphql build
    expectToPass
    npx elm make src/Main.elm --output=/dev/null > /dev/null
}

@test "can compile 'examples/06-union-types'" {
    cd examples/06-union-types
    rm -rf .elm-land

    run elm-land graphql build
    expectToPass
    npx elm make src/Main.elm --output=/dev/null > /dev/null
}
load helpers

@test "can run 'elm-land graphql'" {
  run elm-land graphql
  expectOutputContains "Elm Land"
}

@test "can run 'elm'" {
  run npx elm
  expectOutputContains "Elm 0.19.1"
}

@test "can compile '01-hello-world'" {
    cd tests/01-hello-world
    rm -rf .elm-land

    run elm-land graphql build
    expectToPass
    npx elm make src/Main.elm --output=/dev/null > /dev/null

}
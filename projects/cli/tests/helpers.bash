# HELPERS

function expectToPass {
  [ "$status" -eq 0 ]
}

function expectToFail {
  [ "$status" -ne 0 ]
}

function expectFileExists {
  test -f $1
  expectToPass
}

function expectFileDoesNotExist {
  test ! -f $1
  expectToPass
}

function expectOutputContains {
  [[ $output == *$1* ]]
}

function expectOutputEquals {
  [[ $output == $1 ]]
}

function expectFileContains {
  run cat $1
  [[ $output == *$2* ]]
}

function printLastOutput {
  echo $output >&3
}

function cleanupTmpFolder {
  if [ -d "tests/tmp" ]; then
    rm -r tests/tmp
  fi
}

function expectElmExampleBuilds {
  run elm-land build
  expectToPass

  expectOutputContains "build was successful"

  rm -r .elm-land elm-stuff dist
  cd ../../projects/cli
}
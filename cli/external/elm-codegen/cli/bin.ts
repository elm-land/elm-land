/**/

import * as Commander from "commander"
import chalk from "chalk"
import * as Run from "./run"

const program = new Commander.Command()

const helpText = `
Welcome to ${chalk.cyan("elm-codegen")}!

Make sure to check out the ${chalk.yellow("guides")}:
    https://github.com/mdgriffith/elm-codegen#check-out-the-guide
`

program.version("0.1.0").name("elm-codegen").addHelpText("before", helpText)

program
  .command("init")
  .description(
    `
    Start an Elm CodeGen project.
    This will create a ${chalk.yellow("codegen")} directory and provide you with everything you need to get started.
`
  )
  .argument("[installDir]")
  .action(Run.init)

program
  .command("install")
  .description(
    `
    Install helpers for an ${chalk.yellow("Elm package")} or a local Elm file.
    ${chalk.cyan("elm-codegen install elm/json")}
    ${chalk.cyan("elm-codegen install codegen/helpers/LocalFile.elm")}
`
  )
  .argument("[package]")
  .argument("[version]")
  .action(Run.run_install)

program
  .command("run")
  .description(
    `
    Run ${chalk.yellow("codegen/Generate.elm")}.
    ${chalk.cyan("elm-codegen run")}

  You may pass it a specific Elm file to run.
`
  )
  .argument("[elmFile]")
  .option("--debug", "Run your generator in debug mode, allowing you to use Debug.log in your elm.", false)
  .option("--watch", "Watch the given file for changes and rerun the generator when a change is made.", false)
  .option("--output <dir>", "The directory where your generated files should go.", "generated")
  .option(
    "--flags-from <file>",
    "The file to feed to your elm app as flags.  If it has a json extension, it will be handed in as json."
  )
  .option("--flags <json>", "Json to pass to your elm app.  if --flags-from is given, that will take precedence.")
  .action(Run.run_generation_from_cli)

program.showHelpAfterError()
program.parseAsync()

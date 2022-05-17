/*

    elm-codegen Gen.elm --output=./dir
        -> compile the elm file and run it via the index.js runner

    elm-codegen Gen.elm --watch
        -> recompile and run when the file changes

    elm-codegen install elm/json --output=./dir
        -> generate bindings for the elm/json package based on it's docs.json
        -> puts generated code in ./dir

    elm-codegen install docs.json
        -> same as above, but from a local set of docs

    elm-codegen install Module.elm
        -> same as above, but from a local elm file itself

*/

import * as elm_compiler from "node-elm-compiler"
import * as path from "path"
import * as fs from "fs"
import { XMLHttpRequest } from "./run/vendor/XMLHttpRequest"
import * as Chokidar from "chokidar"
import fetch from "node-fetch"
import chalk from "chalk"
import templates from "./templates"
const gen_package = require("./gen-package")

// We have to stub this in the allow Elm the ability to make http requests.
// @ts-ignore
globalThis["XMLHttpRequest"] = XMLHttpRequest.XMLHttpRequest

const currentVersion = require("../package.json").version

async function run_generator(base: string, moduleName: string, elm_source: string, flags: any) {
  eval(elm_source)

  const promise = new Promise((resolve, reject) => {
    // @ts-ignore
    const app = this.Elm[moduleName].init({ flags: flags })
    if (app.ports.onSuccessSend) {
      app.ports.onSuccessSend.subscribe(resolve)
    }
    if (app.ports.onInfoSend) {
      app.ports.onInfoSend.subscribe((info: string) => console.log(info))
    }
    if (app.ports.onFailureSend) {
      app.ports.onFailureSend.subscribe(reject)
    }
  })
    .then((files: any) => {
      for (const file of files) {
        const fullpath = path.join(base, file.path)
        fs.mkdirSync(path.dirname(fullpath), { recursive: true })
        fs.writeFileSync(fullpath, file.contents)
      }
      if (files.length == 1) {
        console.log(format_block([`${chalk.cyan(base + path.sep)}${chalk.yellow(files[0].path)} was generated!`]))
      } else {
        console.log(format_block([`${chalk.yellow(files.length)} files generated in ${chalk.cyan(base)}!`]))
      }
    })
    .catch((errors) => {
      let formatted = ""

      if (!!errors[Symbol.iterator]) {
        for (const err of errors) {
          formatted = formatted + format_title(err.title) + "\n\n" + err.description + "\n"
        }
      } else {
        if (errors.message.contains("https://github.com/elm/core/blob/1.0.0/hints/2.md")) {
          formatted = `Problem with the flags given to your Elm application on initialization.\n\n\nAdd the ${chalk.cyan(
            "--debug"
          )} to see more details!` // Assuming this is an Elm init error.
        } else {
          formatted = chalk.cyan(errors.message)
        }
      }
      console.error(formatted)
    })
  return promise
}

function generate(debug: boolean, elm_file: string, moduleName: string, target_dir: string, base: string, flags: any) {
  try {
    const data = elm_compiler.compileToStringSync([elm_file], {
      cwd: base,
      optimize: !debug,
      processOpts: { stdio: [null, null, "inherit"] },
    })

    // @ts-ignore
    return new run_generator(target_dir, moduleName, data.toString(), flags)
  } catch (error: unknown) {
    // This is generally an elm make error from the elm_compiler
    console.log(error)
  }
}

const docs_generator = { cwd: "cli/gen-package", file: "src/Generate.elm", moduleName: "Generate" }

function format_title(title: string): string {
  const tail = "-".repeat(80 - (title.length + 2))
  return chalk.cyan("--" + title.toUpperCase() + tail)
}

function format_block(content: string[]) {
  return "\n    " + content.join("\n    ") + "\n"
}

async function run_package_generator(output: string, flags: any) {
  const promise = new Promise((resolve, reject) => {
    // @ts-ignore
    const app = gen_package.Elm.Generate.init({ flags: flags })
    if (app.ports.onSuccessSend) {
      app.ports.onSuccessSend.subscribe(resolve)
    }
    if (app.ports.onInfoSend) {
      app.ports.onInfoSend.subscribe((info: string) => console.log(info))
    }
    if (app.ports.onFailureSend) {
      app.ports.onFailureSend.subscribe(reject)
    }
  })
    .then((files: any) => {
      for (const file of files) {
        const fullpath = path.join(output, file.path)
        fs.mkdirSync(path.dirname(fullpath), { recursive: true })
        fs.writeFileSync(fullpath, file.contents)
      }
    })
    .catch((reason) => {
      console.error(format_title(reason.title), "\n\n" + reason.description + "\n")
    })
  return promise
}

// INSTALL
//   Install bindings for a package
async function install_package(
  pkg: string,
  install_dir: string,
  version: string | null,
  codeGenJson: CodeGenJson
): Promise<CodeGenJson> {
  if (version == null) {
    const searchResp = await fetch("https://elm-package-cache-psi.vercel.app/search.json")
    const search = await searchResp.json()
    for (let found of search) {
      if (found.name == pkg) {
        version = found.version
        break
      }
    }
    if (version == null) {
      console.log(format_block([`No package found for ${chalk.yellow(pkg)}`]))
      process.exit()
    }
  }
  const docsResp = await fetch(`https://elm-package-cache-psi.vercel.app/packages/${pkg}/${version}/docs.json`)
  const docs = await docsResp.json()

  // let codeGenJson = getCodeGenJson(install_dir)

  if (codeGenJson.version != currentVersion) {
    console.log(
      chalk.cyan("elm.codegen.json") +
        " says you are on version " +
        chalk.yellow(codeGenJson.version) +
        `, but you're running version ` +
        chalk.yellow(currentVersion)
    )
    process.exit()
  }
  if (codeGenJson.dependencies && codeGenJson.dependencies.packages && pkg in codeGenJson.dependencies.packages) {
    console.log(chalk.yellow(pkg) + ` is already installed!`)
    if (codeGenJson.dependencies.packages[pkg] != version) {
      console.log(
        `If you want to change versions, adjust ` +
          chalk.cyan("elm.codegen.json") +
          " and run " +
          chalk.cyan("elm-codegen install")
      )
    }
    process.exit(1)
  }

  try {
    run_package_generator(install_dir, { docs: docs })
    codeGenJson.dependencies.packages[pkg] = version
    // fs.writeFileSync(path.join(install_dir, "elm.codegen.json"), codeGenJsonToString(codeGenJson))
    return codeGenJson
  } catch (error: unknown) {
    console.log(`There was an issue generating docs for ${pkg}`)
    // @ts-ignore
    console.log(format_block([error]))
    process.exit(1)
  }
}

type CodeGenJson = {
  version: string
  dependencies: { packages: { [key: string]: string }; local: string[] }
}

function getCodeGenJsonDir(): string {
  if (fs.existsSync("elm.codegen.json")) {
    return "."
  } else if (fs.existsSync("codegen/elm.codegen.json")) {
    return "codegen"
  }

  console.log(
    format_block([
      "Looks like there's no " + chalk.yellow("elm.codegen.json") + ".",
      "Run " + chalk.cyan("elm-codegen init") + " to generate one!",
    ])
  )
  process.exit(1)
}

function getCodeGenJson(cwd: string): CodeGenJson {
  let stringContents = ""
  try {
    stringContents = fs.readFileSync(path.join(cwd, "elm.codegen.json")).toString()
  } catch (error) {
    console.log(
      format_block([
        "Looks like there's no " + chalk.yellow("elm.codegen.json") + ".",
        "Run " + chalk.cyan("elm-codegen init") + " to generate one!",
      ])
    )
    process.exit(1)
  }
  return json2CodeGenConfig(stringContents)
}

function json2CodeGenConfig(stringJson: string): CodeGenJson {
  try {
    let codeGenJson = JSON.parse(stringJson)
    return {
      version: codeGenJson["elm-codegen-version"],
      dependencies: { packages: codeGenJson["codegen-helpers"].packages, local: codeGenJson["codegen-helpers"].local },
    }
  } catch (exception_var) {
    // TODO: convert this exception to a more useful error message
    console.log(format_block(["Looks like there's an issue with " + chalk.yellow("elm.codegen.json") + "."]))
    process.exit(1)
  }
}

function codeGenJsonToString(codeGen: CodeGenJson): string {
  let obj: any = {}
  obj["elm-codegen-version"] = codeGen.version
  obj["codegen-helpers"] = codeGen.dependencies
  return JSON.stringify(obj, null, 4)
}

function codeGenJsonDefault(): CodeGenJson {
  let codeGenJson = JSON.parse(templates.init.elmCodegenJson())
  codeGenJson["elm-codegen-version"] = currentVersion

  return json2CodeGenConfig(JSON.stringify(codeGenJson))
}

// INIT
//    Start a new elm-codegen project
//    Generates some files and installs `core`
export async function init(desiredInstallDir: string | null) {
  const install_dir = desiredInstallDir || "codegen"

  const base = path.join(".", install_dir)
  // create folder
  if (fs.existsSync(base)) {
    console.log(format_block(["Looks like there's already a " + chalk.cyan(install_dir) + " folder."]))
    process.exit(1)
  }
  if (fs.existsSync(path.join(base, "elm.codegen.json"))) {
    console.log(
      format_block(["Looks like there's already a " + chalk.cyan(path.join(base, "elm.codegen.json")) + " file."])
    )
    process.exit(1)
  }

  const codeGenJson = codeGenJsonDefault()

  fs.mkdirSync(base)
  fs.mkdirSync(path.join(base, "Elm"))

  fs.writeFileSync(path.join(base, "elm.json"), templates.init.elmJson())
  fs.writeFileSync(path.join(base, "Generate.elm"), templates.init.starter())
  fs.writeFileSync(path.join(base, "Elm", "Gen.elm"), templates.init.elmGen())
  const updatedCodeGenJson = await install_package("elm/core", install_dir, null, codeGenJson)

  fs.writeFileSync(path.join(base, "elm.codegen.json"), codeGenJsonToString(updatedCodeGenJson))

  console.log(
    format_block([
      "Welcome to " + chalk.yellow("elm-codegen") + "!",
      "",
      "I've created the " + chalk.cyan(install_dir) + " folder and added some files.",
      chalk.cyan(path.join(base, "Generate.elm")) + " is a good place to start to see how everything works!",
      "",
      "Run your generator by running " + chalk.yellow("elm-codegen run"),
    ])
  )
}

async function reinstall_everything(install_dir: string, codeGenJson: CodeGenJson) {
  console.log("Installing dependencies from " + chalk.yellow("elm.codegen.json"))

  const emptyCodeGenJson = codeGenJsonDefault()

  for (let [key, version] of Object.entries(codeGenJson.dependencies.packages)) {
    // `version` is a string
    // install_package returns a new CodeGenJson,
    // but we already know it should be exactly like the one we have

    // @ts-ignore
    await install_package(key, install_dir, version, emptyCodeGenJson)
  }
  const elmSources = []

  for (const item of codeGenJson.dependencies.local) {
    console.log("Installing " + item)
    if (item.endsWith(".json")) {
      console.log("From json " + item)
      let docs = JSON.parse(fs.readFileSync(item).toString())
      run_package_generator(install_dir, { docs: docs })
    } else if (item.endsWith(".elm")) {
      elmSources.push(fs.readFileSync(item).toString())
    }
  }
  if (elmSources.length > 0) {
    run_package_generator(install_dir, { elmSource: elmSources })
  }
  console.log(chalk.green("Success!"))
}

// INIT
//    Start a new elm-codegen project
//    Generates some files and installs `core`
async function make(elm_file: string, moduleName: string, target_dir: string, base: string, flags: any) {
  try {
    const data = elm_compiler.compileToStringSync([elm_file], {
      cwd: base,
      optimize: true,
      processOpts: { stdio: [null, null, "inherit"] },
    })

    // @ts-ignore
    return new run_generator(target_dir, moduleName, data.toString(), flags)
  } catch (error: unknown) {
    // This is generally an elm make error from the elm_compiler
    console.log(error)
  }
}

function clear(dir: string) {
  fs.readdir(dir, (err, files) => {
    if (err) throw err
    for (const file of files) {
      fs.unlink(path.join(dir, file), (err) => {
        if (err) throw err
      })
    }
  })
}

export async function run_install(pkg: string, version: string | null) {
  const install_dir = getCodeGenJsonDir()
  let codeGenJson = getCodeGenJson(install_dir)
  const codeGenJsonPath = path.join(install_dir, "elm.codegen.json")
  if (!!pkg) {
    // Package specified
    if (pkg.endsWith(".json")) {
      //
      // Install local docs file
      if (codeGenJson.dependencies.local.includes(pkg)) {
        console.log(format_block([chalk.cyan(pkg) + " is already installed!"]))
        process.exit(1)
      }
      console.log(format_block(["Adding " + chalk.cyan(pkg) + " to local dependencies and installing."]))
      let docs = JSON.parse(fs.readFileSync(pkg).toString())
      run_package_generator(install_dir, { docs: docs })
      codeGenJson.dependencies.local.push(pkg)
      fs.writeFileSync(codeGenJsonPath, codeGenJsonToString(codeGenJson))
    } else if (pkg.endsWith(".elm")) {
      //
      // Install local elm file
      if (pkg in codeGenJson.dependencies.local) {
        console.log(format_block([chalk.cyan(pkg) + " is already installed!"]))
        process.exit(1)
      }
      run_package_generator(install_dir, { elmSource: [fs.readFileSync(pkg).toString()] })
      codeGenJson.dependencies.local.push(pkg)
      fs.writeFileSync(codeGenJsonPath, codeGenJsonToString(codeGenJson))
    } else {
      //
      // Install from elm package
      console.log("Installing " + chalk.cyan(pkg) + " in " + chalk.yellow(install_dir))
      const updatedCodeGenJson = await install_package(pkg, install_dir, version, codeGenJson)
      fs.writeFileSync(codeGenJsonPath, codeGenJsonToString(updatedCodeGenJson))
      console.log(chalk.green("Success!"))
    }
  } else {
    // elm-codegen install
    // means reinstall all packages
    reinstall_everything(install_dir, codeGenJson)
  }
}

export type Options = {
  debug: boolean
  output: string
  flags: unknown
  cwd: string | null
}

export async function run(elmFile: string, options: Options) {
  const moduleName = path.parse(elmFile).name
  generate(options.debug, elmFile, moduleName, options.output, options.cwd || ".", options.flags)
}

export type CliOptions = {
  debug: boolean
  output: string
  flagsFrom: string | null
  flags: string | null
  watch: boolean
}

export async function run_generation_from_cli(desiredElmFile: string | null, options: CliOptions) {
  let elmFile = "Generate.elm"
  let cwd = "./codegen"

  if (desiredElmFile != null) {
    cwd = "."
    elmFile = desiredElmFile
  }
  let fullSourcePath = path.join(cwd, elmFile)
  let output = path.join(cwd, options.output)

  if (!fs.existsSync(fullSourcePath)) {
    console.log(
      format_block([
        "I wasn't able to find " + chalk.yellow(fullSourcePath) + ".",
        "Have you set up a project using " + chalk.cyan("elm-codegen init") + "?",
      ])
    )
    process.exit(0)
  }

  // prepare flags
  let flags: any | null = null
  if (options.flagsFrom) {
    if (options.flagsFrom.endsWith(".json")) {
      flags = JSON.parse(fs.readFileSync(options.flagsFrom).toString())
    } else {
      flags = fs.readFileSync(options.flagsFrom).toString()
    }
  } else if (options.flags) {
    flags = JSON.parse(options.flags)
  }

  const moduleName = path.parse(elmFile).name

  if (options.watch) {
    //         clear(output)
    generate(options.debug, elmFile, moduleName, output, cwd, flags)
    Chokidar.watch(path.join(cwd, "**", "*.elm"), { ignored: path.join(output, "**") }).on("all", (event, path) => {
      console.log("\nFile changed, regenerating")
      generate(options.debug, elmFile, moduleName, output, cwd, flags)
    })
  } else {
    //         skipping clearing files because in my test case it was failing with permission denied all the time.
    //         clear(output)
    generate(options.debug, elmFile, moduleName, output, cwd, flags)
  }
}

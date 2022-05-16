const fs = require("fs").promises
const path = require("path")
const { Elm } = require("./dist/worker.js")
const { exec, execSync } = require("child_process")
const XMLHttpRequest = require("./vendor/XMLHttpRequest").XMLHttpRequest
const root = path.join(__dirname, "..", "..")

// We have to stub this in the allow ELm the ability to make http requests.
globalThis["XMLHttpRequest"] = XMLHttpRequest


const main = (base) =>
  new Promise((resolve, reject) => {
    const app = Elm.Worker.init({ flags: {  } })
    app.ports.onSuccess.subscribe(resolve)
    app.ports.onFailure.subscribe(reject)
  })
    .then((files) => {
        for (file of files) {
            fs.writeFile((path.join(base, file.path)), file.contents, { encoding: "utf-8" })
        }

    })
    .then((_) => console.info("Success!"))
    .catch((reason) => console.error("Failure", reason))

main(path.join(root,"gen"))

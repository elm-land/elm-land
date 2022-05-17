import * as Run from "./run"

export type Options = {
  debug: boolean
  output: string
  flags: unknown
  cwd: string | null
}

//
export async function run(targetFile: string, options: Options) {
  return Run.run(targetFile, options)
}

// Would be cool to provide a way to run an app by only specifying it's subscriptions
// export async function runWith(targetFile: string, options: Options, app: Promise<any>) {
//   return Run.run(targetFile, options)
// }

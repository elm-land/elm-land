// The bundled Elm compiler: make `elm` mean the compiler version elm-land
// ships with.
//
// vite-plugin-elm-watch runs plain `elm` from PATH. Without this, which
// compiler runs depends on how the user's package manager hoisted the
// different `elm` packages in node_modules, and on any global `elm`.
//
// Strata (each layer only calls the ones above it):
//   Value     Platform               { platform, arch }
//   Port      ModuleResolver         (id) => absolute path, throws when missing
//   Collect   resolveFromElmPackage  the real resolver (reads node_modules)
//   Promote   binaryFileName, binaryPackageId, findElmBinaryFolder,
//             pathKeyOf, prependToPath                       (pure)
//   Boundary  useBundledElmCompiler  the only function that changes the env

import { createRequire } from 'module'
import path from 'path'

/** @typedef {{ platform: string, arch: string }} Platform */
/** @typedef {(id: string) => string} ModuleResolver */

// ---- Promote (pure) --------------------------------------------------------

/** @param {Platform} platform */
export const binaryFileName = ({ platform }) =>
  platform === 'win32' ? 'elm.exe' : 'elm'

/** @param {Platform} platform  e.g. "@elm_binaries/linux_x64/elm" */
export const binaryPackageId = (platform) =>
  `@elm_binaries/${platform.platform}_${platform.arch}/${binaryFileName(platform)}`

/**
 * The folder holding the native Elm binary, or null when it can't be
 * resolved (callers then keep whatever `elm` is already on the PATH).
 *
 * @param {Platform} platform
 * @param {ModuleResolver} resolve
 * @returns {string | null}
 */
export const findElmBinaryFolder = (platform, resolve) => {
  try {
    return path.dirname(resolve(binaryPackageId(platform)))
  } catch (_) {
    return null
  }
}

/**
 * Windows env var names are case-insensitive, and Node exposes "Path" there.
 *
 * @param {Record<string, string | undefined>} env
 */
export const pathKeyOf = (env) =>
  Object.keys(env).find(name => name.toUpperCase() === 'PATH') || 'PATH'

/**
 * A PATH value with `folder` first, not repeated later, and without empty
 * entries (an empty entry means "current directory" on POSIX).
 *
 * @param {string | undefined} currentPath
 * @param {string} folder
 * @param {string} delimiter
 */
export const prependToPath = (currentPath, folder, delimiter) => {
  let rest = (currentPath || '').split(delimiter).filter(entry => entry && entry !== folder)
  return [folder, ...rest].join(delimiter)
}

// ---- Collect ---------------------------------------------------------------

// The binary packages are dependencies of the `elm` package, so resolve
// them from there: under pnpm they are not visible from elm-land itself.
/** @type {ModuleResolver} */
export const resolveFromElmPackage = (id) => {
  let elmPackageJson = createRequire(import.meta.url).resolve('elm/package.json')
  return createRequire(elmPackageJson).resolve(id)
}

// ---- Boundary --------------------------------------------------------------

/**
 * Point PATH at elm-land's own Elm compiler. Child processes (like the one
 * vite-plugin-elm-watch spawns) inherit it.
 *
 * @param {{ env?: Record<string, string | undefined>, platform?: Platform,
 *           resolve?: ModuleResolver, delimiter?: string }} [ports]
 * @returns {string | null} the folder put on the PATH, if any
 */
export const useBundledElmCompiler = ({
  env = process.env,
  platform = { platform: process.platform, arch: process.arch },
  resolve = resolveFromElmPackage,
  delimiter = path.delimiter
} = {}) => {
  let folder = findElmBinaryFolder(platform, resolve)

  if (folder) {
    let key = pathKeyOf(env)
    env[key] = prependToPath(env[key], folder, delimiter)
  }

  return folder
}

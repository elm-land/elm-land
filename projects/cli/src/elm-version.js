// The project's "elm-version" against the compiler elm-land ships with.
//
// Elm applications must name the exact compiler version in elm.json. When a
// project made with an older elm-land says "0.19.1", the compiler only
// reports "ELM VERSION MISMATCH". This catches it first and says how to fix it.
//
// Strata (each layer only calls the ones above it):
//   Value     ElmVersionCheck   { status: 'ok' }
//                             | { status: 'mismatch', projectVersion, compilerVersion }
//   Port      Colors            { cyan, pink }: (text) => text
//             ReadElmJson       () => string, throws when there is no elm.json
//   Promote   compilerVersionOf, checkElmVersion, describeElmVersionMismatch  (pure)
//   Collect   bundledCompilerVersion, readUserElmJson
//   Boundary  projectElmVersionProblem   (reads files, returns the message)

import { createRequire } from 'module'
import fs from 'fs'
import path from 'path'

/**
 * @typedef {{ status: 'ok' } | { status: 'mismatch', projectVersion: string, compilerVersion: string }} ElmVersionCheck
 * @typedef {{ cyan: (text: string) => string, pink: (text: string) => string }} Colors
 */

// ---- Promote (pure) --------------------------------------------------------

/**
 * The npm `elm` package is versioned "<compiler>-<packaging revision>".
 *
 * @param {string} packageVersion  e.g. "0.19.3-0"
 * @returns {string}               e.g. "0.19.3"
 */
export const compilerVersionOf = (packageVersion) =>
  packageVersion.replace(/^(\d+\.\d+\.\d+).*$/, '$1')

/**
 * Only applications pin an exact version; packages use a range, and
 * anything unreadable is left for the compiler to explain.
 *
 * @param {string} elmJsonText
 * @param {string} compilerVersion
 * @returns {ElmVersionCheck}
 */
export const checkElmVersion = (elmJsonText, compilerVersion) => {
  let elmJson
  try {
    elmJson = JSON.parse(elmJsonText)
  } catch (_) {
    return { status: 'ok' }
  }

  let isApplication = elmJson && elmJson.type === 'application'
  let projectVersion = isApplication ? elmJson['elm-version'] : undefined

  if (typeof projectVersion === 'string' && projectVersion !== compilerVersion) {
    return { status: 'mismatch', projectVersion, compilerVersion }
  }
  return { status: 'ok' }
}

/**
 * @param {{ projectVersion: string, compilerVersion: string }} mismatch
 * @param {Colors} colors
 * @returns {string}
 */
export const describeElmVersionMismatch = ({ projectVersion, compilerVersion }, { cyan, pink }) => [
  `    Your ${cyan('elm.json')} says this app needs Elm ${pink(projectVersion)}, but this`,
  `    version of Elm Land uses Elm ${pink(compilerVersion)}.`,
  '',
  `    To fix this, change this line in ${cyan('elm.json')}:`,
  '',
  `        "elm-version": "${projectVersion}"`,
  '',
  `    to:`,
  '',
  `        "elm-version": "${compilerVersion}"`,
].join('\n')

// ---- Collect ---------------------------------------------------------------

export const bundledCompilerVersion = () => {
  let require = createRequire(import.meta.url)
  return compilerVersionOf(require('elm/package.json').version)
}

export const readUserElmJson = () =>
  fs.readFileSync(path.join(process.cwd(), 'elm.json'), { encoding: 'utf-8' })

// ---- Boundary --------------------------------------------------------------

/**
 * @param {{ intro: { error: (text: string) => string }, colors: Colors,
 *           readElmJson?: () => string, compilerVersion?: () => string }} ports
 * @returns {string | null} a message for the terminal, or null when all is well
 */
export const projectElmVersionProblem = ({
  intro,
  colors,
  readElmJson = readUserElmJson,
  compilerVersion = bundledCompilerVersion
}) => {
  let elmJsonText
  try {
    elmJsonText = readElmJson()
  } catch (_) {
    // No elm.json yet: nothing to compare
    return null
  }

  let check = checkElmVersion(elmJsonText, compilerVersion())
  if (check.status === 'ok') return null

  return [
    '',
    intro.error(`found an ${colors.cyan('Elm version')} mismatch`),
    describeElmVersionMismatch(check, colors),
    ''
  ].join('\n')
}

// Vite build errors that deserve a friendlier explanation.
//
// Strata:
//   Value     KnownBuildError  { kind: 'missing-file' | 'missing-package',
//                                dependencyName, importer }
//   Port      Colors           { cyan, pink }: (text) => text
//   Promote   parseViteBuildError, describeKnownBuildError   (pure)
//
// The Boundary (rejecting the build with this text) stays in effects.js.

/**
 * @typedef {{ kind: 'missing-file' | 'missing-package', dependencyName: string, importer: string }} KnownBuildError
 * @typedef {{ cyan: (text: string) => string, pink: (text: string) => string }} Colors
 */

// Rollup (Vite <= 7):    Could not resolve './x.js' from src/interop.js
// Rolldown (Vite >= 8):  [UNRESOLVED_IMPORT] Could not resolve './x.js' in src/interop.js
const missingFilePattern = /Could not resolve '([^']+)' (?:from|in) ([^\n]+)/

// Vite (all versions):   [vite]: Rollup|Rolldown failed to resolve import "x" from "src/interop.js".
const missingPackagePattern = /failed to resolve import ("[^"]+") from "([^"]+)"/

/**
 * @param {string} message
 * @returns {KnownBuildError | null}
 */
export const parseViteBuildError = (message) => {
  let missingFile = missingFilePattern.exec(message)
  if (missingFile) {
    return { kind: 'missing-file', dependencyName: missingFile[1], importer: missingFile[2].trim() }
  }

  let missingPackage = missingPackagePattern.exec(message)
  if (missingPackage) {
    return { kind: 'missing-package', dependencyName: missingPackage[1], importer: missingPackage[2] }
  }

  return null
}

/**
 * @param {KnownBuildError} known
 * @param {Colors} colors
 * @returns {string}
 */
export const describeKnownBuildError = (known, { cyan, pink }) => {
  switch (known.kind) {
    case 'missing-file':
      return [
        `    The file ${cyan(known.importer)} tried to import`,
        `    another file at ${pink(`"${known.dependencyName}"`)}, but it wasn't found.`,
        '',
        '    Maybe the file was deleted?'
      ].join('\n')

    case 'missing-package':
      return [
        `    The file ${cyan(known.importer)} tried to import`,
        `    an NPM package named ${pink(known.dependencyName)}, but it wasn't found.`,
        '',
        `    Make sure to run ${cyan('npm install')} before running this command.`
      ].join('\n')
  }
}

// Recognizes the Vite build errors that deserve a friendlier explanation.
//
// Pure: takes the error message text, returns plain data (or null when
// the message is not one we know how to explain).

// Rollup (Vite <= 7):    Could not resolve './x.js' from src/interop.js
// Rolldown (Vite >= 8):  [UNRESOLVED_IMPORT] Could not resolve './x.js' in src/interop.js
const missingFilePattern = /Could not resolve '([^']+)' (?:from|in) ([^\n]+)/

// Vite (all versions):   [vite]: Rollup|Rolldown failed to resolve import "x" from "src/interop.js".
const missingPackagePattern = /failed to resolve import ("[^"]+") from "([^"]+)"/

/**
 * @param {string} message
 * @returns {{ kind: 'missing-file' | 'missing-package', dependencyName: string, importer: string } | null}
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

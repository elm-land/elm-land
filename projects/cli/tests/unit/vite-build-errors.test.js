import { test } from 'node:test'
import assert from 'node:assert/strict'
import { parseViteBuildError } from '../../src/vite-build-errors.js'

test('missing relative file, Rolldown (Vite 8) wording', () => {
  let message = [
    'Build failed with 2 errors:',
    '',
    "[UNRESOLVED_IMPORT] Could not resolve './does-not-exist.js' in src/interop.js",
    '   ╭─[ src/interop.js:1:8 ]'
  ].join('\n')

  assert.deepEqual(parseViteBuildError(message), {
    kind: 'missing-file',
    dependencyName: './does-not-exist.js',
    importer: 'src/interop.js'
  })
})

test('missing relative file, Rollup (Vite 5) wording', () => {
  let message = "Could not resolve './does-not-exist.js' from src/interop.js\nfile: /app/src/interop.js"

  assert.deepEqual(parseViteBuildError(message), {
    kind: 'missing-file',
    dependencyName: './does-not-exist.js',
    importer: 'src/interop.js'
  })
})

test('missing npm package keeps the quoted package name', () => {
  let message = '[vite]: Rolldown failed to resolve import "left-pad" from "/app/src/interop.js".\nThis is most likely unintended'

  assert.deepEqual(parseViteBuildError(message), {
    kind: 'missing-package',
    dependencyName: '"left-pad"',
    importer: '/app/src/interop.js'
  })
})

test('unknown messages are not recognized', () => {
  assert.equal(parseViteBuildError('Something else went wrong'), null)
  assert.equal(parseViteBuildError(''), null)
})

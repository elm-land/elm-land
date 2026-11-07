import fc from 'fast-check'
import { trifecta } from './trifecta.js'
import { parseViteBuildError, describeKnownBuildError } from '../../src/vite-build-errors.js'

// ---- Promote: parseViteBuildError -------------------------------------------

const rolldownMissingFile = [
  'Build failed with 2 errors:',
  '',
  "[UNRESOLVED_IMPORT] Could not resolve './does-not-exist.js' in src/interop.js",
  '   ╭─[ src/interop.js:1:8 ]'
].join('\n')

trifecta({
  name: 'parseViteBuildError',
  subject: parseViteBuildError,
  cases: {
    'rolldown-missing-file': [rolldownMissingFile],
    'rollup-missing-file': ["Could not resolve './x.js' from src/interop.js\nfile: /app/src/interop.js"],
    'importer-with-trailing-space': ["Could not resolve '../lib/a.js' in src/interop.ts   \nmore"],
    'rolldown-missing-package': ['[vite]: Rolldown failed to resolve import "left-pad" from "/app/src/interop.js".\nThis is most likely unintended'],
    'rollup-missing-package': ['[vite]: Rollup failed to resolve import "@scope/pkg" from "src/interop.ts".'],
    'both-mentioned': ['[vite]: Rolldown failed to resolve import "a" from "b".\nCould not resolve \'./c.js\' in d.js'],
    'unknown': ['Transform failed with 1 error: Unexpected token'],
    'empty': ['']
  },
  property: {
    arbitrary: fc.tuple(
      fc.stringMatching(/^[./a-zA-Z0-9_@-]{1,20}$/),
      fc.stringMatching(/^[/a-zA-Z0-9_.-]{1,20}$/),
      fc.constantFrom('from', 'in'),
      fc.constantFrom('', 'Build failed with 1 error:\n\n[UNRESOLVED_IMPORT] '),
      fc.constantFrom('', '\n   ╭─[ x ]', '\nfile: /app/x')
    ).map(([dependencyName, importer, wording, before, after]) =>
      [`${before}Could not resolve '${dependencyName}' ${wording} ${importer}${after}`, dependencyName, importer]),
    holds: ([, dependencyName, importer], known) =>
      known !== null && known.kind === 'missing-file'
      && known.dependencyName === dependencyName && known.importer === importer
  },
  mutants: {
    'rollup-wording-only': (message) => {
      let match = /Could not resolve '([^']+)' from ([^\n]+)/.exec(message)
      return match ? { kind: 'missing-file', dependencyName: match[1], importer: match[2].trim() } : null
    },
    'no-trim': (message) => {
      let known = parseViteBuildError(message)
      let raw = /Could not resolve '[^']+' (?:from|in) ([^\n]+)/.exec(message)
      return known && raw && known.kind === 'missing-file' ? { ...known, importer: raw[1] } : known
    },
    'strips-package-quotes': (message) => {
      let known = parseViteBuildError(message)
      return known && known.kind === 'missing-package' ? { ...known, dependencyName: known.dependencyName.replaceAll('"', '') } : known
    },
    'package-checked-first': (message) => {
      let match = /failed to resolve import ("[^"]+") from "([^"]+)"/.exec(message)
      return match ? { kind: 'missing-package', dependencyName: match[1], importer: match[2] } : parseViteBuildError(message)
    },
    'never-recognizes': () => null
  },
  sentinels: ['rollup-wording-only', 'never-recognizes']
})

// ---- Promote: describeKnownBuildError (Colors port injected) -----------------

// Visible markers instead of ANSI codes, so a swapped color shows in the golden
const markers = { cyan: (text) => `<cyan>${text}</cyan>`, pink: (text) => `<pink>${text}</pink>` }

trifecta({
  name: 'describeKnownBuildError',
  subject: describeKnownBuildError,
  cases: {
    'missing-file': [{ kind: 'missing-file', dependencyName: './does-not-exist.js', importer: 'src/interop.js' }, markers],
    'missing-package': [{ kind: 'missing-package', dependencyName: '"left-pad"', importer: '/app/src/interop.ts' }, markers]
  },
  property: {
    arbitrary: fc.tuple(
      fc.record({
        kind: fc.constantFrom('missing-file', 'missing-package'),
        dependencyName: fc.stringMatching(/^[./a-z@-]{1,15}$/),
        importer: fc.stringMatching(/^[/a-z.]{1,15}$/)
      }),
      fc.constant(markers)
    ),
    holds: ([known], text) =>
      text.split('\n').length === 4
      && text.includes(`<cyan>${known.importer}</cyan>`)
      && text.includes(known.dependencyName)
  },
  mutants: {
    'swapped-colors': (known, { cyan, pink }) => describeKnownBuildError(known, { cyan: pink, pink: cyan }),
    'file-name-unquoted': (known, colors) =>
      describeKnownBuildError(known, colors).replace(`"${known.dependencyName}"`, known.dependencyName),
    'one-message-for-both': (known, colors) => describeKnownBuildError({ ...known, kind: 'missing-file' }, colors),
    'npm-advice-for-pnpm-users-dropped': (known, colors) =>
      describeKnownBuildError(known, colors).split('\n').slice(0, 2).join('\n')
  },
  sentinels: ['swapped-colors', 'npm-advice-for-pnpm-users-dropped']
})

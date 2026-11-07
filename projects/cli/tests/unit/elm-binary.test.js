import { test } from 'node:test'
import assert from 'node:assert/strict'
import { spawnSync } from 'node:child_process'
import fs from 'node:fs'
import path from 'node:path'
import fc from 'fast-check'
import { trifecta } from './trifecta.js'
import {
  binaryPackageId,
  findElmBinaryFolder,
  pathKeyOf,
  prependToPath,
  resolveFromElmPackage,
  useBundledElmCompiler
} from '../../src/elm-binary.js'

// ---- Promote: prependToPath -------------------------------------------------

// Entries never contain a delimiter
const entry = fc.stringMatching(/^[a-zA-Z0-9_./\\ -]{0,12}$/)

trifecta({
  name: 'prependToPath',
  subject: prependToPath,
  cases: {
    'absent': ['/usr/bin:/bin', '/elm', ':'],
    'already-first': ['/elm:/usr/bin', '/elm', ':'],
    'in-the-middle': ['/usr/bin:/elm:/bin', '/elm', ':'],
    'listed-twice': ['/elm:/usr/bin:/elm', '/elm', ':'],
    'empty-entries': ['/usr/bin::/bin:', '/elm', ':'],
    'empty-string': ['', '/elm', ':'],
    'undefined': [undefined, '/elm', ':'],
    'windows': ['C:\\Windows;C:\\elm;C:\\Tools', 'C:\\elm', ';']
  },
  property: {
    // The folder is mixed into the entries, or the dedup rule is never exercised
    arbitrary: fc.tuple(entry.filter(e => e !== ''), fc.constantFrom(':', ';'))
      .chain(([folder, delimiter]) =>
        fc.array(fc.oneof(entry, fc.constant(folder)), { maxLength: 8 })
          .map(entries => [entries.join(delimiter), folder, delimiter])),
    holds: ([current, folder, delimiter], output) => {
      let parts = output.split(delimiter)
      let others = current.split(delimiter).filter(e => e && e !== folder)
      return parts[0] === folder
        && parts.filter(p => p === folder).length === 1
        && !parts.includes('')
        && JSON.stringify(parts.slice(1)) === JSON.stringify(others)
    }
  },
  mutants: {
    'identity': (current) => current,
    'append-instead-of-prepend': (current, folder, delimiter) =>
      [...(current || '').split(delimiter).filter(e => e && e !== folder), folder].join(delimiter),
    'no-dedup': (current, folder, delimiter) =>
      [folder, ...(current || '').split(delimiter).filter(e => e)].join(delimiter),
    'keeps-empty-entries': (current, folder, delimiter) =>
      [folder, ...(current || '').split(delimiter).filter(e => e !== folder)].join(delimiter),
    'ignores-delimiter': (current, folder) =>
      [folder, ...(current || '').split(':').filter(e => e && e !== folder)].join(':')
  },
  sentinels: ['append-instead-of-prepend', 'no-dedup', 'keeps-empty-entries']
})

// ---- Promote: findElmBinaryFolder -------------------------------------------

const fakeNodeModules = (id) => `/nm/${id}`
const nothingInstalled = () => { throw Object.assign(new Error('Cannot find module'), { code: 'MODULE_NOT_FOUND' }) }

trifecta({
  name: 'findElmBinaryFolder',
  subject: findElmBinaryFolder,
  cases: {
    'linux-x64': [{ platform: 'linux', arch: 'x64' }, fakeNodeModules],
    'darwin-arm64': [{ platform: 'darwin', arch: 'arm64' }, fakeNodeModules],
    'windows-asks-for-exe': [{ platform: 'win32', arch: 'x64' }, (id) => id.endsWith('.exe') ? `/nm/${id}` : nothingInstalled()],
    'not-installed': [{ platform: 'linux', arch: 'x64' }, nothingInstalled]
  },
  property: {
    arbitrary: fc.tuple(
      fc.record({ platform: fc.constantFrom('linux', 'darwin', 'win32'), arch: fc.constantFrom('x64', 'arm64') }),
      fc.constant(fakeNodeModules)
    ),
    holds: ([platform], folder) => folder === `/nm/@elm_binaries/${platform.platform}_${platform.arch}`
  },
  mutants: {
    'never-exe': (platform, resolve) => {
      try { return path.dirname(resolve(`@elm_binaries/${platform.platform}_${platform.arch}/elm`)) } catch (_) { return null }
    },
    'returns-file-not-folder': (platform, resolve) => {
      try { return resolve(binaryPackageId(platform)) } catch (_) { return null }
    },
    'ignores-arch': (platform, resolve) => findElmBinaryFolder({ ...platform, arch: 'x64' }, resolve),
    'throws-when-missing': (platform, resolve) => path.dirname(resolve(binaryPackageId(platform)))
  },
  sentinels: ['returns-file-not-folder', 'ignores-arch']
})

// ---- Promote: pathKeyOf -----------------------------------------------------

trifecta({
  name: 'pathKeyOf',
  subject: pathKeyOf,
  cases: {
    'posix': [{ HOME: '/home/me', PATH: '/bin' }],
    'windows': [{ Path: 'C:\\Windows', SystemRoot: 'C:\\Windows' }],
    'lowercase': [{ path: '/bin' }],
    'missing': [{ HOME: '/home/me' }],
    'lookalike-only': [{ PATHEXT: '.EXE', MANPATH: '/usr/man' }]
  },
  property: {
    arbitrary: fc.tuple(
      fc.constantFrom('PATH', 'Path', 'path', 'pAtH').chain(key =>
        fc.dictionary(fc.stringMatching(/^[A-Z_]{1,8}$/).filter(k => k !== 'PATH'), fc.string())
          .map(others => ({ ...others, [key]: '/bin' })))
    ),
    holds: ([env], key) => key.toUpperCase() === 'PATH' && env[key] === '/bin'
  },
  mutants: {
    'always-PATH': () => 'PATH',
    'case-sensitive': (env) => Object.keys(env).find(name => name === 'PATH') || 'PATH',
    'substring-match': (env) => Object.keys(env).find(name => name.toUpperCase().includes('PATH')) || 'PATH'
  },
  sentinels: ['always-PATH', 'case-sensitive']
})

// ---- Boundary: useBundledElmCompiler (ports injected, no monkeypatching) ----

test('boundary: puts the bundled compiler first on the given env', () => {
  let env = { Path: 'C:\\Windows;C:\\elm-global' }

  let folder = useBundledElmCompiler({
    env,
    platform: { platform: 'win32', arch: 'x64' },
    resolve: (id) => `C:\\nm\\${id}`,
    delimiter: ';'
  })

  assert.equal(folder, path.dirname('C:\\nm\\@elm_binaries/win32_x64/elm.exe'))
  assert.deepEqual(env, { Path: `${folder};C:\\Windows;C:\\elm-global` })
})

test('boundary: leaves the env alone when no compiler is bundled', () => {
  let env = { PATH: '/usr/bin' }

  let folder = useBundledElmCompiler({ env, platform: { platform: 'linux', arch: 'x64' }, resolve: nothingInstalled, delimiter: ':' })

  assert.equal(folder, null)
  assert.deepEqual(env, { PATH: '/usr/bin' })
})

// ---- Collect: the real resolver against this install ------------------------

test('collect: the installed elm package provides an Elm 0.19.3 binary for this machine', () => {
  let file = resolveFromElmPackage(binaryPackageId({ platform: process.platform, arch: process.arch }))
  assert.ok(fs.existsSync(file), `${file} should exist`)

  let result = spawnSync(file, ['--version'], { encoding: 'utf-8' })
  assert.equal(result.stdout.trim(), '0.19.3')
})

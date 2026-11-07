import { test } from 'node:test'
import assert from 'node:assert/strict'
import fs from 'node:fs'
import os from 'node:os'
import path from 'node:path'
import fc from 'fast-check'
import { searchForWorkspaceRoot } from 'vite'
import { trifecta } from './trifecta.js'
import { hostFromEnv, displayHost, isNetworkExposed, allowedFsRoots } from '../../src/dev-server-options.js'

const hostname = fc.stringMatching(/^[a-z0-9][a-z0-9.-]{0,20}$/)

// ---- Promote: hostFromEnv ---------------------------------------------------

trifecta({
  name: 'hostFromEnv',
  subject: hostFromEnv,
  cases: {
    'unset': [{}],
    'empty': [{ HOST: '' }],
    'blank': [{ HOST: '   ' }],
    'all-interfaces': [{ HOST: '0.0.0.0' }],
    'ipv6-all': [{ HOST: '::' }],
    'loopback': [{ HOST: '127.0.0.1' }],
    'named': [{ HOST: 'my-laptop.local' }],
    'padded': [{ HOST: ' 0.0.0.0 ' }],
    'other-vars-only': [{ PORT: '3000', HOSTNAME: 'box' }]
  },
  property: {
    // without HOST the server stays on localhost; with HOST, it is used as given.
    // args are [env, host]: the subject reads only env, `host` is what went into it
    arbitrary: fc.tuple(
      fc.option(hostname, { nil: undefined }),
      fc.dictionary(fc.constantFrom('PORT', 'HOSTNAME', 'NODE_ENV'), fc.string())
    ).map(([host, others]) => [{ ...others, ...(host === undefined ? {} : { HOST: host }) }, host]),
    holds: ([, host], output) => output === (host === undefined ? 'localhost' : host)
  },
  mutants: {
    'old-default-all-interfaces': (env) => env.HOST || '0.0.0.0',
    'no-trim': (env) => env.HOST || 'localhost',
    'reads-hostname': (env) => (env.HOST || env.HOSTNAME || 'localhost').trim(),
    'ignores-env': () => 'localhost'
  },
  sentinels: ['old-default-all-interfaces', 'ignores-env']
})

// ---- Promote: displayHost ---------------------------------------------------

trifecta({
  name: 'displayHost',
  subject: displayHost,
  cases: {
    'all-interfaces': ['0.0.0.0'],
    'ipv6-all': ['::'],
    'ipv6-all-bracketed': ['[::]'],
    'localhost': ['localhost'],
    'loopback': ['127.0.0.1'],
    'named': ['my-laptop.local']
  },
  property: {
    // a concrete host is shown as is; only wildcard addresses are replaced
    arbitrary: fc.oneof(hostname, fc.constantFrom('0.0.0.0', '::', '[::]')).map(h => [h]),
    holds: ([host], output) => output === (isNetworkExposed(host) ? 'localhost' : host)
  },
  mutants: {
    'ipv4-only': (host) => host === '0.0.0.0' ? 'localhost' : host,
    'always-localhost': () => 'localhost',
    'identity': (host) => host
  },
  sentinels: ['always-localhost', 'identity']
})

// ---- Promote: allowedFsRoots (port injected) --------------------------------

test('allowedFsRoots: is exactly what the workspace search returns for the project folder', () => {
  let asked = []
  let roots = allowedFsRoots('/projects/app', (folder) => { asked.push(folder); return '/projects/app' })
  assert.deepEqual(roots, ['/projects/app'])
  assert.deepEqual(asked, ['/projects/app'])
})

// ---- Collect: with Vite's real workspace search -----------------------------

const tempTree = (files) => {
  let root = fs.mkdtempSync(path.join(os.tmpdir(), 'elm-land-fs-'))
  for (let [rel, content] of Object.entries(files)) {
    fs.mkdirSync(path.dirname(path.join(root, rel)), { recursive: true })
    fs.writeFileSync(path.join(root, rel), content)
  }
  return root
}

test('allowedFsRoots: a standalone project allows only its own folder, not the folders above it', () => {
  let root = tempTree({ 'parent/project/package.json': '{}', 'parent/project/elm-land.json': '{}' })
  try {
    let project = path.join(root, 'parent', 'project')
    let roots = allowedFsRoots(project, searchForWorkspaceRoot)
    assert.deepEqual(roots, [project])
    assert.ok(!roots.includes(path.resolve(project, '../..')))
  } finally {
    fs.rmSync(root, { recursive: true, force: true })
  }
})

test('allowedFsRoots: a project inside a pnpm workspace allows the workspace root', () => {
  let root = tempTree({ 'mono/pnpm-workspace.yaml': 'packages:\n  - apps/*\n', 'mono/package.json': '{}', 'mono/apps/web/package.json': '{}' })
  try {
    let roots = allowedFsRoots(path.join(root, 'mono', 'apps', 'web'), searchForWorkspaceRoot)
    assert.deepEqual(roots, [path.join(root, 'mono')])
  } finally {
    fs.rmSync(root, { recursive: true, force: true })
  }
})

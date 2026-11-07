import { test } from 'node:test'
import assert from 'node:assert/strict'
import fc from 'fast-check'
import { trifecta } from './trifecta.js'
import {
  bundledCompilerVersion,
  checkElmVersion,
  compilerVersionOf,
  describeElmVersionMismatch,
  projectElmVersionProblem
} from '../../src/elm-version.js'

const version = fc.tuple(fc.nat(9), fc.nat(99), fc.nat(99)).map(parts => parts.join('.'))

// ---- Promote: compilerVersionOf ---------------------------------------------

trifecta({
  name: 'compilerVersionOf',
  subject: compilerVersionOf,
  cases: {
    'packaging-revision': ['0.19.3-0'],
    'multi-digit-revision': ['0.19.1-14'],
    'plain': ['0.19.1'],
    'two-digit-parts': ['1.20.300-beta.2']
  },
  property: {
    arbitrary: fc.tuple(version, fc.oneof(fc.constant(''), fc.nat(99).map(n => `-${n}`))).map(([v, suffix]) => [v + suffix, v]),
    holds: ([, expected], output) => output === expected
  },
  mutants: {
    'identity': (v) => v,
    'major-minor-only': (v) => v.split('.').slice(0, 2).join('.'),
    'single-digit-parts': (v) => v.replace(/^(\d\.\d\.\d).*$/, '$1')
  },
  sentinels: ['identity', 'major-minor-only']
})

// ---- Promote: checkElmVersion ------------------------------------------------

const app = (elmVersion) => JSON.stringify({ type: 'application', 'source-directories': ['src'], 'elm-version': elmVersion })

trifecta({
  name: 'checkElmVersion',
  subject: checkElmVersion,
  cases: {
    'matching-app': [app('0.19.3'), '0.19.3'],
    'old-app': [app('0.19.1'), '0.19.3'],
    'newer-app': [app('0.19.4'), '0.19.3'],
    'package-range': [JSON.stringify({ type: 'package', 'elm-version': '0.19.0 <= v < 0.20.0' }), '0.19.3'],
    'no-type': [JSON.stringify({ 'elm-version': '0.19.1' }), '0.19.3'],
    'no-elm-version': [JSON.stringify({ type: 'application' }), '0.19.3'],
    'invalid-json': ['{ "type": "application", ', '0.19.3'],
    'json-null': ['null', '0.19.3']
  },
  property: {
    arbitrary: fc.tuple(version, version).map(([project, compiler]) => [app(project), compiler, project]),
    holds: ([, compiler, project], check) =>
      project === compiler
        ? check.status === 'ok'
        : check.status === 'mismatch' && check.projectVersion === project && check.compilerVersion === compiler
  },
  mutants: {
    'always-ok': () => ({ status: 'ok' }),
    'checks-packages-too': (text, compiler) => {
      let json = JSON.parse(text)
      return json['elm-version'] && json['elm-version'] !== compiler
        ? { status: 'mismatch', projectVersion: json['elm-version'], compilerVersion: compiler }
        : { status: 'ok' }
    },
    'only-older-is-a-mismatch': (text, compiler) => {
      let check = checkElmVersion(text, compiler)
      return check.status === 'mismatch' && check.projectVersion > compiler ? { status: 'ok' } : check
    },
    'swapped-versions': (text, compiler) => {
      let check = checkElmVersion(text, compiler)
      return check.status === 'mismatch'
        ? { ...check, projectVersion: check.compilerVersion, compilerVersion: check.projectVersion }
        : check
    }
  },
  sentinels: ['always-ok', 'swapped-versions']
})

// ---- Promote: describeElmVersionMismatch (Colors port injected) --------------

const markers = { cyan: (text) => `<cyan>${text}</cyan>`, pink: (text) => `<pink>${text}</pink>` }

trifecta({
  name: 'describeElmVersionMismatch',
  subject: describeElmVersionMismatch,
  cases: {
    'upgrade-from-0.19.1': [{ projectVersion: '0.19.1', compilerVersion: '0.19.3' }, markers],
    'ahead-of-elm-land': [{ projectVersion: '0.19.4', compilerVersion: '0.19.3' }, markers]
  },
  property: {
    arbitrary: fc.tuple(fc.record({ projectVersion: version, compilerVersion: version }), fc.constant(markers)),
    holds: ([{ projectVersion, compilerVersion }], text) =>
      text.includes(`"elm-version": "${projectVersion}"`)
      && text.includes(`"elm-version": "${compilerVersion}"`)
      && text.indexOf(`"elm-version": "${projectVersion}"`) < text.indexOf(`"elm-version": "${compilerVersion}"`)
  },
  mutants: {
    'fix-points-backwards': (mismatch, colors) =>
      describeElmVersionMismatch({ projectVersion: mismatch.compilerVersion, compilerVersion: mismatch.projectVersion }, colors),
    'no-colors': (mismatch) => describeElmVersionMismatch(mismatch, { cyan: t => t, pink: t => t }),
    'no-fix-shown': (mismatch, colors) => describeElmVersionMismatch(mismatch, colors).split('\n').slice(0, 2).join('\n')
  },
  sentinels: ['fix-points-backwards', 'no-fix-shown']
})

// ---- Boundary: projectElmVersionProblem (ports injected) ---------------------

const intro = { error: (text) => `ERROR ${text}` }

test('boundary: an old project gets the upgrade instructions', () => {
  let problem = projectElmVersionProblem({
    intro,
    colors: markers,
    readElmJson: () => app('0.19.1'),
    compilerVersion: () => '0.19.3'
  })

  assert.match(problem, /^\nERROR found an <cyan>Elm version<\/cyan> mismatch\n/)
  assert.ok(problem.includes('"elm-version": "0.19.3"'))
})

test('boundary: a matching project, or no elm.json at all, is fine', () => {
  let compilerVersion = () => '0.19.3'
  assert.equal(projectElmVersionProblem({ intro, colors: markers, readElmJson: () => app('0.19.3'), compilerVersion }), null)
  assert.equal(projectElmVersionProblem({
    intro,
    colors: markers,
    readElmJson: () => { throw Object.assign(new Error('ENOENT'), { code: 'ENOENT' }) },
    compilerVersion
  }), null)
})

// ---- Collect: the installed compiler and the init template agree ------------

test('collect: the bundled compiler is 0.19.3 and the init template asks for it', async () => {
  let { default: template } = await import('../../src/templates/elm.json', { with: { type: 'json' } })
  assert.equal(bundledCompilerVersion(), '0.19.3')
  assert.equal(template['elm-version'], bundledCompilerVersion())
})

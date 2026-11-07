// Trifecta testing for pure functions: golden + property + mutation.
//
//   golden    locks the exact output for every named case (tests/unit/golden/<name>.json)
//   property  checks an invariant over generated inputs (fast-check)
//   mutation  runs deliberately broken versions of the subject; each one must
//             disagree with the golden on at least one case, which proves the
//             cases are diverse enough to catch that bug
//
// Goldens are only (re)written with UPDATE_GOLDEN=1. A missing golden fails,
// so a wrong first run can't silently become the truth. Read new goldens
// before committing them.

import { describe, test } from 'node:test'
import assert from 'node:assert/strict'
import fs from 'node:fs'
import path from 'node:path'
import url from 'node:url'
import fc from 'fast-check'

const goldenFolder = path.join(path.dirname(url.fileURLToPath(import.meta.url)), 'golden')

// JSON is the golden format, so compare everything through it
const normalize = (value) => JSON.parse(JSON.stringify(value === undefined ? null : value))

const runCases = (fn, cases) =>
  Object.fromEntries(
    Object.entries(cases).map(([caseName, args]) => {
      try {
        return [caseName, normalize(fn(...args))]
      } catch (error) {
        return [caseName, { threw: String(error && error.message) }]
      }
    })
  )

/**
 * @param {{
 *   name: string,
 *   subject: (...args: any[]) => any,
 *   cases: Record<string, any[]>,
 *   property: { arbitrary: fc.Arbitrary<any[]>, holds: (args: any[], output: any) => boolean, numRuns?: number },
 *   mutants: Record<string, (...args: any[]) => any>,
 *   sentinels?: string[]
 * }} spec
 *
 * `sentinels` names mutants the PROPERTY must also reject, which shows the
 * property is not vacuous.
 */
export const trifecta = ({ name, subject, cases, property, mutants, sentinels = [] }) => {
  if (Object.keys(cases).length === 0) throw new Error(`trifecta ${name}: no cases`)
  if (!property) throw new Error(`trifecta ${name}: no property`)
  if (Object.keys(mutants).length === 0) throw new Error(`trifecta ${name}: no mutants`)

  let goldenPath = path.join(goldenFolder, `${name}.json`)

  describe(`trifecta: ${name}`, () => {
    test('golden', () => {
      let actual = runCases(subject, cases)

      if (process.env.UPDATE_GOLDEN === '1') {
        fs.mkdirSync(goldenFolder, { recursive: true })
        fs.writeFileSync(goldenPath, JSON.stringify(actual, null, 2) + '\n')
      }

      assert.ok(fs.existsSync(goldenPath), `missing ${goldenPath}; run with UPDATE_GOLDEN=1 and review it`)
      assert.deepEqual(actual, JSON.parse(fs.readFileSync(goldenPath, 'utf-8')))
    })

    test('property', () => {
      fc.assert(
        fc.property(property.arbitrary, (args) => property.holds(args, subject(...args))),
        { numRuns: property.numRuns || 200 }
      )
    })

    for (let [mutantName, mutant] of Object.entries(mutants)) {
      test(`mutant "${mutantName}" is killed by the golden cases`, () => {
        let golden = JSON.parse(fs.readFileSync(goldenPath, 'utf-8'))
        let mutated = runCases(mutant, cases)
        let killedBy = Object.keys(cases).filter(caseName =>
          JSON.stringify(mutated[caseName]) !== JSON.stringify(golden[caseName]))

        assert.ok(killedBy.length > 0, `mutant "${mutantName}" agrees with every golden case: add a case that separates it`)
      })
    }

    for (let mutantName of sentinels) {
      test(`mutant "${mutantName}" is rejected by the property`, () => {
        let mutant = mutants[mutantName]
        assert.ok(mutant, `sentinel "${mutantName}" is not a declared mutant`)
        let result = fc.check(
          fc.property(property.arbitrary, (args) => property.holds(args, mutant(...args))),
          { numRuns: property.numRuns || 200 }
        )
        assert.ok(result.failed, `the property accepts mutant "${mutantName}": it is too weak`)
      })
    }
  })
}

let nodeElmCompiler = require('node-elm-compiler')

let compile = async (path : string) : Promise<ElmError | undefined> => {
  return toRawJsonString(path).then(parse)
}

let toRawJsonString = async (path : string) : Promise<string> => {
  return nodeElmCompiler
    .compileToString([path], { report: 'json' })
    .catch((err : { message: string }) => err.message.slice('Compilation failed\n'.length))
}


export type ElmError
  = CompilerReportError
  | ReportError


type ReportError = {
  type: 'error'
  path: null | string
  title: string
  message: ElmErrorMessage[]
}

type CompilerReportError = {
  type: 'compile-errors'
  errors: ElmCompilerError[]
}

type ElmCompilerError = {
  path: string
  name: string
  problems: ElmCompilerProblem[]
}

type ElmCompilerProblem = {
  title: string
  region: ElmErrorRegion
  message: ElmErrorMessage[]
}

type ElmErrorRegion = {
  start: { line: number, column: number }
  end: { line: number, column: number }
}

type ElmErrorColor
  = 'RED'
  | 'MAGENTA'
  | 'YELLOW'
  | 'GREEN'
  | 'CYAN'
  | 'BLUE'
  | 'BLACK'
  | 'WHITE'

type ElmErrorMessage = string | ElmErrorStyledMessage

type ElmErrorStyledMessage = {
  bold: boolean
  underline: boolean
  color: ElmErrorColor | Lowercase<ElmErrorColor> | null
  string: string
}


const parse = (rawErrorString: string): ElmError | undefined => {
  // The error returned from node-elm-compiler's error.message
  // contains this string before the JSON blob:
  const nodeElmCompilerPreamble = `Compilation failed\n`

  const normalizedJsonString =
    (rawErrorString.indexOf(nodeElmCompilerPreamble) === 0)
      ? rawErrorString.slice(nodeElmCompilerPreamble.length)
      : rawErrorString

  try {
    // Doing this `as` cast here is dangerous, because 
    // the caller can pass arbitrary JSON:
    const json = JSON.parse(normalizedJsonString) as ElmError

    // To potentially prevent this cast from leading to
    // unexpected errors, we validate it at least has
    // the expected "type" values
    if (json.type === 'compile-errors' || json.type === 'error') {
      return json
    } else {
      console.error(`JSON is valid, but result is not an Elm error`, rawErrorString)
      return undefined
    }
  } catch (e) {
    console.error(`Failed to decode an Elm error`, rawErrorString)
    return undefined
  }
}

// INTERNALS

/**
 * Converts strings to styled messages, so we can easily
 * apply formatting using an Array.map in view code
 */
 const normalizeErrorMessages = (messages: ElmErrorMessage[]): ElmErrorStyledMessage[] => {
  return messages.map(msg => {
    return typeof msg === 'string'
      ? { bold: false, underline: false, color: 'WHITE', string: msg }
      : msg
  })
}

const header = (error: ElmCompilerError, problem: ElmCompilerProblem, cwd_?: string): string => {
  const MAX_WIDTH = 80
  const SPACER = '-'
  const SPACING_COUNT = 2
  const PREFIX = '-- '
  const left = problem.title
  const cwd = cwd_ || process.cwd() as string
  const absolutePath = error.path
  const relativePath = absolutePath.slice(cwd.length + 1)

  const dashCount = MAX_WIDTH - left.length - PREFIX.length - SPACING_COUNT - relativePath.length

  return `${PREFIX}${left} ${SPACER.repeat(dashCount)} ${relativePath}`
}


const escapeHtml = (str: string): string =>
  str
    .split('<').join('&lt;')
    .split('>').join('&gt;')

export const toColoredTerminalOutput = (elmError: ElmError): string => {
  // TERMINAL ASCII CODES
  const code = (num: number) => "\u001b[" + num + "m"
  const reset = code(0)
  const bold = code(1)
  const underline = code(4)
  const colors: Record<ElmErrorColor, number> = {
    RED: 31,
    MAGENTA: 35,
    YELLOW: 33,
    GREEN: 32,
    CYAN: 36,
    BLUE: 34,
    BLACK: 30,
    WHITE: 37
  }

  const render = (message: ElmErrorMessage[]): string => {
    const messages = normalizeErrorMessages(message)
    return messages.map((msg) => {
      let str = ''
      if (msg.bold) { str += bold }
      if (msg.underline) { str += underline }
      if (msg.color) {
        str += code(colors[msg.color.toUpperCase() as ElmErrorColor])
      }
      str += msg.string
      str += reset
      return str
    }).join('')
  }

  switch (elmError.type) {
    case 'compile-errors':
      const output: string[] = elmError.errors.reduce((output, error) => {
        const problems = error.problems.map(problem => {
          return [
            (code(colors.CYAN) + header(error, problem) + reset),
            render(problem.message)
          ].join('\n\n\n')
        })
        return output.concat(problems)
      }, [] as string[])

      return output.join('\n\n')
    case 'error':
      return render(elmError.message)
  }
}

export default {
  compile,
  toRawJsonString,
  toColoredTerminalOutput
}
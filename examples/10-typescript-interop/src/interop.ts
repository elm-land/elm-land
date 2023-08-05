import * as String from './string'

// This returns the flags passed into your Elm application
export const flags = async ({ env }: ElmLand.FlagsArgs) => {
  return {}
}

// This function is called after your Elm app starts
export const onReady = ({ app, env }: ElmLand.OnReadyArgs) => {
  console.log('Elm is ready', app)
  app.ports?.outgoing?.subscribe?.((message: unknown) => {
    console.log(message)
    askTheUserAQuestion()
  })
}

const askTheUserAQuestion = () => {
  const answer = window.prompt('What is your favorite animal?')

  if (answer) {
    const length: number = String.getLengthOfString(answer)
    const units: string = length === 1 ? 'letter' : 'letters'
    const response: string =
      `Did you know that "${answer}" is ${length} ${units} long?`

    window.alert(response)
  }
}

// Type definitions for Elm Land
namespace ElmLand {
  export interface FlagsArgs {
    env: Record<string, string>
  }
  export interface OnReadyArgs {
    env: Record<string, string>
    app: { ports?: Record<string, Port> }
  }
  export interface Port {
    send?: (data: unknown) => void
    subscribe?: (callback: (data: unknown) => unknown) => void
  }
}

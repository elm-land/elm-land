import * as String from './string'

// Types for Elm Land interop functions
namespace ElmLand {

  export type FlagsFunction =
    ({ env }: { env: Record<string, string> }) => unknown
  
  export type OnReadyFunction = ({ env, app }: {
    env: Record<string, string>,
    app : { ports?: Record<string, Port> }
  }) => void
  
  export type Port = {
    subscribe?: (callback: (data: unknown) => void) => void,
    unsubscribe?: (callback: (data: unknown) => void) => void,
    send?: (data: unknown) => void
  }
}

export const flags : ElmLand.FlagsFunction = () => {

}

export const onReady : ElmLand.OnReadyFunction = ({ app, env }) => {
  app.ports?.outgoing?.subscribe?.((message : unknown) => {
    console.log(message)
    askTheUserAQuestion()
  })
}


const askTheUserAQuestion = () => {
  let answer = window.prompt('What is your favorite animal?')
  
  if (answer) {
    let length : number = String.getLengthOfString(answer)
    let units : string = length === 1 ? 'letter' : 'letters'
    let response : string = `Did you know that "${answer}" is ${length} ${units} long?`
  
    window.alert(response)
  }
}
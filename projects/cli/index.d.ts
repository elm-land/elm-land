declare namespace ElmLand {
  /**
   * This function is called before your Elm application
   * starts, and its return value is passed in as the `Flags`
   * for your application.
   */
  export type Flags = ({ env } : {
    env : Record<string, string>
  }) => Json | void
  
  /**
   * This function is called _after_ your Elm application
   * starts, and allows you to access ports. The return value is
   * ignored.
   */
  export type OnReady = ({ env, app } : { 
    env : Record<string, string>
    app : { ports?: Record<string, Port> } 
  }) => void

  type Port
    = { subscribe: (fn: (data: Json) => void) => void, send: undefined }
    | { send: (data: Json) => void, subscribe: undefined }

  type Json = string | number | boolean | { [key: string]: Json } | Json[] | null
}
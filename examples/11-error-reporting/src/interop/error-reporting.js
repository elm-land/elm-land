import * as Sentry from "@sentry/browser"
import { BrowserTracing } from "@sentry/tracing"

// Set up Sentry to handle runtime exceptions thrown from JavaScript
export const init = ({ env }) => {
  if (!env.SENTRY_DSN) {
    console.warn(`To run this example, please provide a SENTRY_DSN environment variable`)
    console.info(`See the README.md for more details`)
  }
  Sentry.init({
    dsn: env.SENTRY_DSN,
    integrations: [new BrowserTracing()],
    tracesSampleRate: 1.0,
    environment:
      (env.NODE_ENV === 'production')
        ? 'production'
        : 'development'
  });
}

// Listen for errors from Elm, and report them to Sentry
export const handlePorts = (ports) => {
  ports.sendHttpErrorToSentry.subscribe(sendHttpError)
  ports.sendJsonDecodeErrorToSentry.subscribe(sendJsonDecodeError)
}

const sendHttpError = (event) => {
  Sentry.captureEvent({
    message: 'HTTP_ERROR',
    extra: {
      "URL": event.url,
      "Response": event.response,
      "Http.Error": event.error
    }
  })
}

const sendJsonDecodeError = (event) => {
  Sentry.captureEvent({
    message: 'JSON_DECODE_ERROR',
    extra: {
      "URL": event.url,
      "Response": event.response,
      "Json.Decode.Error": event.error
    }
  })
}
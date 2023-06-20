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
  ports.outgoing.subscribe(({ tag, data }) => {
    switch (tag) {
      case 'SEND_HTTP_ERROR':
        return sendHttpError(data)
      case 'SEND_JSON_DECODE_ERROR':
        return sendJsonDecodeError(data)
      default:
        return sendUnexpectedPortError(tag, data)
    }
  })
}

const sendHttpError = (event) => {
  Sentry.withScope((scope) => {
    if (event.response) {
      scope.addAttachment({
        filename: event.url,
        data: event.response
      })
    }
    Sentry.captureEvent({
      message: `${event.method} ${event.url} – ${event.error}`,
      tags: {
        'kind': 'Http.Error',
        'elm.http.method': event.method,
        'elm.http.url': event.url,
      }
    })
  })
}

const sendJsonDecodeError = (event) => {
  Sentry.withScope((scope) => {
    scope.addAttachment({
      filename:
        (event.url.endsWith('.json'))
          ? event.url
          : `${event.url}.json`,
      data: event.response
    })
    Sentry.captureEvent({
      message: `${event.method} ${event.url} – ${event.title}`,
      tags: {
        'kind': 'Json.Decode.Error',
        'elm.http.method': event.method,
        'elm.http.url': event.url,
      },
      extra: {
        "Json.Decode.Error": event.error
      }
    })
  })
}

const sendUnexpectedPortError = (tag, data) => {
  Sentry.captureEvent({
    message: `Elm Ports – Unexpected "${tag}" port`,
    tags: {
      kind: 'Elm.Ports'
    },
    extra: data
  })
}
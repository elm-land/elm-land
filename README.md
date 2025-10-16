# Elm Land

[![Npm package version](https://badgen.net/npm/v/elm-land?6)](https://npmjs.com/package/@cekrem/elm-land) [![BSD-3 Clause](https://img.shields.io/github/license/elm-land/elm-land)](https://github.com/elm-land/elm-land/blob/main/LICENSE)

[![Discord](https://badgen.net/discord/members/vnmYFfySbH?icon=discord&label)](https://join.elm.land) [![Twitter](https://badgen.net/badge/icon/twitter?icon=twitter&label&color=00acee)](https://twitter.com/elmland_) [![GitHub](https://badgen.net/badge/icon/github?icon=github&label&color=4078c0)](https://www.github.com/elm-land/elm-land)

[![Elm Land: Reliable web apps for everyone](https://github.com/elm-land/elm-land/raw/main/docs/elm-land-banner.jpg)](https://elm.land)

## 🌱 About this fork

This is a friendly, thankful and respectful fork of [Elm Land](https://github.com/elm-land/elm-land), solving one specific problem: **enabling pages and layouts to react to shared messages**.

### The problem

Elm Land already gives pages access to the latest shared **state** (via `Shared.Model`), but there's no way for pages to react to **messages** that happen in the shared layer - like when a WebSocket message arrives, when a subscription fires, or when any event occurs that updates the shared state. Pages can respond to URL changes using `Page.withOnUrlChanged`, but not to things that _happen_ in the shared layer at a point in time.

### The solution

This fork adds `Page.withOnSharedMsg` and `Layout.withOnSharedMsg`, following the same pattern as existing Elm Land APIs:

```elm
page : Shared.Model -> Route () -> Page Model Msg
page shared route =
    Page.new
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
        |> Page.withOnSharedMsg
            (\sharedMsg ->
                case sharedMsg of
                    Shared.Msg.ItemsSaved ->
                        ShowSuccessToast

                    _ ->
                        NoOp
            )
```

### Installation

```bash
npm install --save-dev @cekrem/elm-land
```

This allows pages and layouts to "subscribe" to shared state changes, making reactive UI updates natural and eliminating the need for manual synchronization workarounds.

There's a [PR](https://github.com/elm-land/elm-land/pull/205) open on this, but according to Ryan it will probably not be merged until Elm Land is out of beta (and when it is, his own solution will be more thorough).

**Only use this fork if you need the functionality described above!**

---

## Welcome to our repo

The code for this GitHub project is broken down into smaller projects:

- **[elm-land](./projects/cli/)** - The CLI tool, available at [npmjs.org/elm-land](https://npmjs.org/elm-land)
- **[@elm-land/docs](./docs/)** - The official website, available at [elm.land](https://elm.land)

### Tooling

This repo also includes a few tooling projects, separated out for anyone else making tooling for Elm:

- **[@elm-land/elm-error-json](./projects/tooling/elm-error-json/)** - Render the Elm compiler's JSON error output as full-color HTML or colored ASCII terminal output

- **[@elm-land/codegen](./projects/tooling/codegen/)** - a lightweight codegen library used internally by the Elm Land CLI

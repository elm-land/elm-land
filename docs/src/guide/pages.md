# Pages

When you created a new project with `elm-land init`, it came along with a homepage in the file `src/Pages/Home_.elm`.

When users visit the `/` route in their web browser, they will see the content in that page.

## Adding another page

If we wanted our users to see a _different_ page when they visit `/sign-in`, we can use the Elm Land CLI tool to create that new page:

```sh
npx elm-land add page /sign-in
```

If you still have your server running from the last guide (with the `npx elm-land server` command), you can visit [http://localhost:1234/sign-in](http://localhost:1234/sign-in) to see your new page:

```txt
/sign-in
```
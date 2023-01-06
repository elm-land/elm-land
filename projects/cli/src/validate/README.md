# @elm-land/validate
> Make sure users don't see errors in generated code!

## Overview

When a user forgets to expose a value like `page` from a page file, this
would lead to an error message in a generated file.

One of the design goals of Elm Land is to never show errors in files not
written by the user.

This Elm module validates the pages, layouts, and other files to provide
nicer error messages.
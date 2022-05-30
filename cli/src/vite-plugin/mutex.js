/**
 * This approach comes from snowpack-plugin-elm by Marc Walter
 * https://github.com/marc136/snowpack-plugin-elm
 *
 * To avoid gets an error: "It looks like some of the information cached in elm-stuff/ has been corrupted." from Elm compiler
 * Elm compiler uses elm-stuff dir for cache which is expected not to be touched by other thread's compilation
 */
const queue = []
let locked = false

const acquireLock = async () => {
  await new Promise((resolve) => {
    if (!locked) {
      resolve()
      return
    }
    queue.push(resolve)
  })

  locked = true

  return () => {
    queue.shift()?.()
    if (queue.length === 0) {
      locked = false
    }
  }
}

module.exports = {
  acquireLock
}
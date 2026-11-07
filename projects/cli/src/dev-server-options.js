// Pure decisions about where the dev server listens. No I/O: callers pass the env in.

// Addresses that mean "every network interface" rather than one host
const wildcardHosts = ['0.0.0.0', '::', '[::]']

/**
 * The host `elm-land server` listens on.
 *
 * Defaults to `localhost`, so only this machine can reach the dev server. The dev
 * server can read project files and open them in an editor, which is fine for the
 * developer but not for everyone on the same network. Set `HOST=0.0.0.0` to opt in
 * to network access (containers, testing on a phone).
 *
 * @param {Record<string, string | undefined>} env
 * @returns {string}
 */
export const hostFromEnv = (env) => {
  let host = (env.HOST || '').trim()
  return host === '' ? 'localhost' : host
}

/**
 * The host to show in the "ready at http://..." message. A wildcard address is not
 * something you can open in a browser, so show `localhost` for it.
 *
 * @param {string} host
 * @returns {string}
 */
export const displayHost = (host) =>
  wildcardHosts.includes(host) ? 'localhost' : host

/**
 * Folders the dev server may serve files from: the project, or the monorepo that
 * contains it (Vite's own workspace-root search, passed in so this stays pure).
 *
 * This used to be ['../..'], written when Vite's root was `.elm-land/server`, where
 * it meant the project folder. Once the root became the project folder itself, it
 * allowed two folders ABOVE the project instead.
 *
 * @param {string} projectFolder
 * @param {(folder: string) => string} searchForWorkspaceRoot
 * @returns {string[]}
 */
export const allowedFsRoots = (projectFolder, searchForWorkspaceRoot) =>
  [searchForWorkspaceRoot(projectFolder)]

/**
 * @param {string} host
 * @returns {boolean} true when the server is reachable from other machines
 */
export const isNetworkExposed = (host) =>
  wildcardHosts.includes(host)


export const flags = ({ env } : { env : Record<string, string> }) => {
  console.log('before app load', env)
}
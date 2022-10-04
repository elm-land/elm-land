export const flags = ({ env }) => {
  return {
    token: env['GITHUB_API_TOKEN']
  }
} 
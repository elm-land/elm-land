let run = async () => {
  return {
    message: '🌈 Server ready at http://localhost:1234',
    files: [],
    effects: [
      { kind: 'runServer', options: { port: 1234 } }
    ]
  }
}

module.exports = {
  Server: {
    run
  }
}
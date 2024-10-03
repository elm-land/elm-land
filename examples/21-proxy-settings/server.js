// An example server that listens on port 3000 and returns the path of the request.
require("node:http")
  .createServer((req, res) => {
    res.end(req.url);
  })
  .listen(3000);

path = require 'path'
port = 3000

express = require("express")
server = express.createServer()

buildPath = path.join(__dirname, '..', 'build')


server.configure ->
    server.set 'views', buildPath
    server.use express.static buildPath

index_html = require('fs').readFileSync(path.join(buildPath, "index.html"))

index = (req, res) ->
  res.header('Content-Type', 'text/html')
  res.end(index_html)


server.get('/',            index)
server.get('/welcome',     index)
server.get('/more',        index)
server.get('/login',       index)
server.get('/register',    index)
server.get('/:id@:domain', index)


console.log("starting server on port " + port)
server.listen(parseInt(port, 10))

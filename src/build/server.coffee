path = require 'path'
config = require 'jsconfig'
express = require 'express'
browserify = require 'browserify'
{ createReadStream } = require 'fs'
cwd = path.join(__dirname, "..", "..")

config.defaults path.join(cwd, "config.js")

config.cli
    host: ['host', ['b', "build server listen address", 'host']]
    port: ['port', ['p', "build server listen port",  'number']]

config.load (args, opts) ->

    server = express.createServer()

    buildPath = path.join(cwd, "assets")

    server.configure ->
        server.set 'views', buildPath
        javascript = browserify
                mount  : '/web/js/app.js'
                require: [path.join(cwd, "src", "main")]
                verbose: yes
                watch  : yes
                cache  : off
                fastmatch: on

        server.use javascript
        server.use express.static buildPath

    index_html = path.join(buildPath, "index.html")

    index = (req, res) ->
        res.header 'Content-Type', 'text/html'
        createReadStream(index_html).pipe(res)


    server.get '/',            index
    server.get '/welcome',     index
    server.get '/more',        index
    server.get '/login',       index
    server.get '/register',    index
    server.get '/:id@:domain', index


    server.listen config.port, config.host
    console.log "build server listening on %s:%s ...", config.host, config.port

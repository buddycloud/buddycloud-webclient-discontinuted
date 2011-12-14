eco = require 'eco'
nib = require 'nib'
path = require 'path'
stylus = require 'stylus'
config = require 'jsconfig'
express = require 'express'
browserify = require 'browserify'
{ createReadStream } = require 'fs'
cwd = path.join(__dirname, "..", "..")

config.defaults path.join(cwd, "config.js")

config.cli
    host: ['host', ['b', "build server listen address", 'host']]
    port: ['port', ['p', "build server listen port",  'number']]
    build:['build',[off, "build and pack everything together" ]]

config.load (args, opts) ->

    server = express.createServer()

    buildPath = path.join(cwd, "assets")

    server.configure ->

        javascript = browserify
                mount  : '/web/js/app.js'
                verbose: no
                watch  : yes
                cache  : off
                fastmatch: not config.build
                require: [
                    jquery  :'jquery-browserify'
                    backbone:'backbone-browserify'
                    path.join(cwd, "src", "main")
                ]
                extensions:
                    '.eco': (source) ->
                        "module.exports = #{eco.precompile source}"
                    'modernizr.js': (source) ->
                        # modernizr needs the full global window namespace
                        "!function(){#{source}}.call(window)"
                    'strophe.js': (source) ->
                        # expose MD5 lib because we need that for gravatar too
                        source += ";window.MD5=MD5"
                        source

        if config.build
            # minification
            javascript.register 'post', require 'uglify-js'

        stylePath = path.join(cwd, "src", "styles")
        server.use stylus.middleware
            dest : path.join(buildPath, "web", "css")
            src  : stylePath
            paths: [stylePath]
            debug: yes
            compile: (css, filename) ->
                style = stylus css,
                    filename: filename
                    compress: config.build or config.css.compress
                    force: config.css.force
                    warn: config.css.warn
                style.use nib()

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

    server.get '/web/js/store.js', (req, res) ->
        res.header 'Content-Type', 'text/javascript'
        createReadStream(require.resolve 'store/store+json2.min').pipe(res)

    server.listen config.port, config.host
    if config.build
        require './packaging' # this puts everything in a tarball
    else
        console.log "build server listening on %s:%s …",config.host,config.port

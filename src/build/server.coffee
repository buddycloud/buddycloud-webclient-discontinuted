require 'colors'
eco = require 'eco'
nib = require 'nib'
path = require 'path'
stylus = require 'stylus'
config = require 'jsconfig'
express = require 'express'
browserify = require 'browserify'
{ createReadStream } = require 'fs'
{ Compiler } = require 'dt-compiler'
{ wrap_prefix } = require './util'


snippets = ["main"
    "channel/index", "channel/posts", "channel/post"
    "channel/topicpost", "channel/comments"
    "sidebar/index", "sidebar/search", "sidebar/entry"
]


cwd = path.join(__dirname, "..", "..")
config.defaults path.join(cwd, "config.js")

buildPath = path.join(cwd, "assets")
designPath = path.join(cwd, "src", "_design")

config.cli
    host: ['host', ['b', "build server listen address", 'host']]
    port: ['port', ['p', "build server listen port",  'number']]
    build:['build',[off, "build and pack everything together" ]]
    dev:  [off, "enable build server code reload"]

config.load (args, opts) ->

    pending = 0
    done = ->
#         console.log "fin", pending
        start_server(args, opts) unless --pending

    sources = {}
    for name in snippets
        # reloaded by node-dev on fs change
        snippet = require("../templates/#{name}")
        (sources[snippet.src] ?= []).push
            select: snippet.select
            snippet:name

    for filename, selectors of sources
        design = new Compiler
        design.load(path.join(buildPath, filename))
        console.log "loading #{filename} …".yellow
        for selector in selectors
            pending++
            console.log "* compiling #{selector.snippet}".bold.black
            design.build
                select: selector.select
                watch:  yes
                done:   done
                dest:   path.join(designPath, selector.snippet) + ".js"
    0

start_server = (args, opts) ->

    server = express.createServer()

    server.configure ->

        javascript = browserify
                mount  : '/web/js/app.js'
                verbose: yes
                watch  : yes
                cache  : on
                require: [
                    jquery  :'jquery-browserify'
                    backbone:'backbone-browserify'
                    path.join(cwd, "src", "init")
                ]
                extensions:
                    '.html': (source) ->
                        source = source
                            .replace(/'/g, "\\'") # don't let html escape itself
                            .replace(/\n/g, "\\n'+\n'") # new lines
                        "module.exports=function(){return '#{source}'}"
                    'modernizr.js': (source) ->
                        # modernizr needs the full global window namespace
                        "!function(){#{source}}.call(window)"
                    'strophe.js': (source) ->
                        # expose MD5 lib because we need that for gravatar too
                        source += ";window.MD5=MD5"
                        source
                    '.eco': (source) -> "module.exports=#{require('eco').precompile source}"

        if config.build
            # minification
            javascript.register 'post', require 'uglify-js'

        stylePath = path.join(cwd, "src", "styles")
        server.use wrap_prefix "/web/css", stylus.middleware
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
        # this puts everything in a tarball
        pack = require './packaging'
        url = "http://#{config.host}:#{config.port}"
        pack url, "build.tar.gz"
    else
        console.log "build server listening on %s:%s …".magenta,
            config.host, config.port

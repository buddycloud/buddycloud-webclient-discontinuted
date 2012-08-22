require 'colors'
nib = require 'nib'
path = require 'path'
stylus = require 'stylus'
config = require 'jsconfig'
express = require 'express'
browserify = require 'browserify'
{ createReadStream } = require 'fs'
{ Compiler } = require 'dt-compiler'
{ wrap_prefix, Watcher } = require './util'


snippets = ["main"
    "channel/index", "channel/posts", "channel/post"
    "channel/topicpost", "channel/comments", "channel/edit"
    "channel/details/index", "channel/details/list", "channel/details/user"
    "channel/follow_notification", "channel/pending_notification"
    "channel/error_notification", "channel/private"
    "sidebar/index", "sidebar/minimal", "sidebar/search", "sidebar/entry"
    "userbar/index"
    "authentication/overlay"
    "create_topic_channel/index"
    "discover/index", "discover/group", "discover/list", "discover/entry"
    "discover/startpage"
]


cwd = path.join(__dirname, "..", "..")
config.defaults path.join(cwd, "devconfig.js")

designPath = path.join(cwd, "src", "_design")

config.cli
    host: ['host', ['b', "build server listen address", 'host']]
    port: ['port', ['p', "build server listen port",  'number']]
    assets:['assets', ['a', "path to assets folder", 'path']]
    build:['build',[off, "build and pack everything together" ]]
    design:['design',[off, "enable build server on the fly style reload"]]
    dev:['dev',[off, "enable code reload and development tools in the browser"]]
    restart:[off, "enable build server restart"]

config.load (args, opts) ->

    config.port++ if config.build
    config.assets = path.resolve(cwd, config.assets)

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
        design.load(path.join(config.assets, filename))
        console.log "loading #{filename} …".yellow
        for selector in selectors
            pending++
            console.log "* compiling #{selector.snippet}".bold.black
            design.build
                select: selector.select
                watch:  not config.build and config.watch
                done:   done
                path:   designPath
                dest:   "#{selector.snippet}.js"
    0

start_server = (args, opts) ->

    server = express.createServer()

    server.configure ->
        server.use express.favicon(path.join(config.assets, "favicon.ico"))

        watching =  not config.build and config.watch
        debugging = not config.build and config.dev
        console.log "debug mode".bold.yellow if debugging
        console.log "bundling app.js …".yellow
        javascript = browserify
                mount  : '/web/js/app.js'
                debug  : debugging
                watch  : watching
                cache  : on
                require: [
                    'br-jquery'
                ]
        console.log "watching code …".magenta if watching
        javascript.alias('jquery', 'br-jquery')

        javascript.register '.html', (source) ->
            "module.exports=function(){return '#{JSON.stringify source}'};"
        javascript.register 'modernizr.js', (source) ->
            # modernizr needs the full global window namespace
            "!function(){#{source}}.call(window);"
        javascript.register 'strophe.js', (source) ->
            # expose MD5 lib because we need that for gravatar too
            source += ";window.MD5=MD5;"
            source

        javascript.addEntry(path.join(cwd, "src", "init.coffee"))

        javascript.use(require('shimify'))

        if config.build
            # minification
            javascript.register 'post', require 'uglify-js'

        stylePath = path.join(cwd, "src", "styles")
        server.use wrap_prefix "/web/css", stylus.middleware
            dest : path.join(config.assets, "web", "css")
            src  : stylePath
            paths: [stylePath]
            debug: yes
            compile: (css, filename) ->
                style = stylus css,
                    filename: filename
                    compress: config.build or config.css.compress
                    force: config.css.force
                    warn: config.css.warn
                watcher?.watch filename
                style.on 'end', ->
                    process.nextTick ->
                        for imp in style.options._imports
                            watcher?.watch imp.path
                style.use nib()

        server.use javascript
        server.use express.static config.assets

    index_html = path.join(config.assets, "index.html")

    index = (req, res) ->
        res.header 'Content-Type', 'text/html'
        createReadStream(index_html).pipe(res)


    server.get '/',            index
    server.get '/welcome',     index
    server.get '/more',        index
    server.get '/login',       index
    server.get '/register',    index
    server.get '/discover',    index
    server.get '/:id@:domain', index
    server.get '/create-topic-channel', index

    server.get '/web/js/store.js', (req, res) ->
        res.header 'Content-Type', 'text/javascript'
        createReadStream(require.resolve 'store/store+json2.min').pipe(res)

    # this stuff runs on the client for live reloading css (including stylus compiling)
    server.get '/web/js/livecss.js', (req, res) ->
        res.header 'Content-Type', 'text/javascript'
        res.end "(" + ( ->
            io.connect()
                .on 'connect', () ->
                    console.log "connected to build server."
                .on 'changed', (filepath) ->
                    console.log "file", filepath, "changed."
                    q = '?reload=' + new Date().getTime()
                    $('link[rel="stylesheet"]').each ->
                        @href = @href.replace /\?.*|$/, q
        ) + ")()"

    if config.design
        watcher = new Watcher
        watcher.on 'changed', (filepath) ->
            console.log "file #{filepath} changed.".cyan.bold
        console.log "watching stylus files …".magenta
        io = require('socket.io').listen server
        io.sockets.on 'connection', (socket) ->
            listener = (path) ->
                socket.emit('changed', path)
            watcher.on('changed', listener)
            socket.on 'disconnect', ->
                watcher.removeListener('changed', listener)


    server.listen config.port, config.host

    if config.build
        # this puts everything in a tarball
        pack = require './packaging'
        pack "build.tar.gz"
    else
        console.log "build server listening on %s:%s …".magenta,
            config.host, config.port

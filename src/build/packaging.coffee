fs = require 'fs'
tar = require 'tar'
zlib = require 'zlib'
http = require 'http'
url = require 'url'
{Stream} = require('stream')
{Buffer} = require('buffer')
config = require 'jsconfig'

spiderDir = (root, path) ->
    results = []
    for f in fs.readdirSync("#{root}/#{path}")
        path2 = "#{path}/#{f}"
        fn = "#{root}/#{path2}"
        stats = fs.statSync fn
        if stats.isDirectory()
            results.push spiderDir(root, path2)...
        else if stats.isFile()
            results.push path2
    results

entries = [
    ""
    "config.js"
    "web/js/app.js"
    "web/js/store.js"
    "web/css/main.css"
].concat spiderDir("assets", "web/fonts"), spiderDir("assets", "public")

onError = (e) ->
    console.error e.stack or e.message or e
    process.exit 1


# Consumes entire document and emits 'complete' afterwards
class BufferingStream extends Stream
    constructor: ->
        super

        @buffers = []
        @length = 0
        @writable = yes

    write: (data) ->
        if data?
            @buffers.push data
            @length += data.length
        return true

    end: (data) ->
        if data?
            @write data
        buffer = new Buffer(@length)
        offset = 0
        for b in @buffers
            b.copy buffer, offset
            offset += b.length
        @emit 'complete', buffer

# Emit a whole document at once
class BufferedStream extends Stream
    constructor: ->
        super

    run: (body) ->
        @emit 'data', body
        process.nextTick =>
            @emit 'end'

    # Stub
    pause: ->

    # Stub
    resume: ->

module.exports = (baseUrl, tarPath) ->
    tarPack = new tar.Pack(noProprietary: yes)
    tarPack.
        on('error', onError).
        pipe(zlib.Gzip()).
        on('error', onError).
        pipe(fs.createWriteStream(tarPath)).
        on('error', onError).
        on 'close', ->
            console.log "Built #{tarPath}"
            process.exit 0

    idle = yes

    pushNextEntry = ->
        return unless idle
        idle = no

        entry = entries.shift()
        if entry?
            u = url.parse("#{baseUrl}/#{entry}")
            req = http.get
                host: u.hostname
                port: u.port
                path: u.path
            path = if u.path == "/" then "/index.html" else u.path
            path = path.replace /^\/+/, ""
            req.on 'response', (res) ->
                # No Content-Length means we cannot pipe(). tar.Pack
                # needs to know a file's size beforehand though, so we
                # need to buffer the HTTP body.
                buffering = new BufferingStream()
                res.pipe(buffering)
                buffering.on 'complete', (body) ->
                    stream = new BufferedStream()
                    stream.props =
                        path: path
                        mode: 0755
                        size: body.length
                        uid: 1000
                        gid: 1000
                        uname: 'www'
                        gname: 'nogroup'
                    stream.root = path: "."
                    stream.path = path
                    flushed = tarPack.add stream
                    stream.run body

                    idle = yes
                    if flushed
                        process.nextTick pushNextEntry
                    else
                        # Waiting for data to be flushed, continue
                        # on 'drain'
            req.on 'error', onError
        else
            tarPack.end()

    tarPack.on 'drain', pushNextEntry
    pushNextEntry()


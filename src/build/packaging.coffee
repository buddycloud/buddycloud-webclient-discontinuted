tar = require 'tar'
zlib = require 'zlib'
http = require 'http'
url = require 'url'
config = require 'jsconfig'
PostBuffer = require 'bufferstream/postbuffer'
{ spiderDir, BufferedStream } = require './util'
{ createWriteStream } = require 'fs'

onError = (e) ->
    console.error "#{e.stack or e.message or e}".red
    process.exit 1


entries = [
    ""
    "config.js"
    "web/js/app.js"
    "web/js/store.js"
    "web/css/main.css"
].concat spiderDir("assets", "web/fonts"), spiderDir("assets", "public")



module.exports = (baseUrl, tarPath) ->
    tarPack = new tar.Pack(noProprietary: yes)
    tarPack
        .on('error', onError)
        .pipe(zlib.Gzip())
        .on('error', onError)
        .pipe(createWriteStream(tarPath))
        .on('error', onError)
        .on 'close', ->
            console.log "Built #{tarPath}".bold.green
            process.exit 0

    idle = yes

    pushNextEntry = ->
        return unless idle
        idle = no

        entry = entries.shift()
        unless entry?
            return tarPack.end()


        msg = "GET".cyan+" "+"/#{entry}".magenta+" "+"…".bold.black
        process.stdout.write msg

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
            new PostBuffer(res).onEnd (body) ->
                console.log "","#{body?.length}".green,".".bold.black
                stream = new BufferedStream
                time = new Date().getTime() / 1000
                stream.props =
                    path: path
                    mode: 0755
                    size: body.length
                    uid: 1000
                    gid: 1000
                    uname: 'www'
                    gname: 'nogroup'
                    mtime: time
                    atime: time
                    ctime: time
                stream.root = path: "."
                stream.path = path
                flushed = tarPack.add stream
                stream.run body

                idle = yes
                if flushed
                    process.nextTick pushNextEntry
                # else - Waiting for data to be flushed, continue
        req.on 'error', onError

    tarPack.on 'drain', pushNextEntry
    pushNextEntry()


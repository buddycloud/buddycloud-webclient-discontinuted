{ createWriteStream } = require 'fs'
request = require 'request'
async = require 'async'
config = require 'jsconfig'
BufferStream = require 'bufferstream'
{ Pack:Tarball } = require 'tarball'
{ spiderDir } = require './util'

onError = (e) ->
    console.error "#{e.stack or e.message or e}".red
    process.exit 1


entries = [
    "index.html"
    "config.js"
    "favicon.ico"
    "web/js/app.js"
    "web/js/store.js"
    "web/css/main.css"
].concat spiderDir("assets", "web/fonts"), spiderDir("assets", "public")



module.exports = (tarPath) ->
    tarball = new Tarball {noProprietary:yes},
        compress:on
        defaults:
            uname:'www'
            gname:'nogroup'
            uid: 1000
            gid: 1000
            mode: 00644

    tarball
        .on('error', onError)
        .pipe(createWriteStream(tarPath))
        .on('error', onError)
        .on 'close', ->
            console.log "Built #{tarPath}".bold.green
            process.exit 0

    # using mapSeries because we dont to glutter the terminal
    async.mapSeries( entries
    ,(entry, done) ->
        msg = "GET".cyan+" "+"/#{entry}".magenta+" "+"…".bold.black
        process.stdout.write msg
        request("http://#{config.host}:#{config.port}/#{entry}")
            .on('error', onError)
            .on 'response', (res) ->
                stream = new BufferStream disabled:yes # no splitting needed
                stream.path = entry # res.path can't be set
                stream.props = size:res.headers['content-length']
                tarball.append stream, ->
                    console.log "","#{stream.props.size}".green,".".bold.black
                    done()
                res.pipe(stream)
    ,(err) ->
        onError(err) if err?
        tarball.end()
    )


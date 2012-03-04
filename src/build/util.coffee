fs = require 'fs'
{ EventEmitter } = require 'events'


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


wrap_prefix = (prefix, middleware) ->
    return (req, res, next) ->
        if req.url.indexOf(prefix) is 0
            old_url = req.url
            req.url = req.url[prefix.length..]
            middleware req, res, ->
                req.url = old_url
                next(arguments...)
        else
            next()


watchFile = (filepath, callback) ->
    pending = no
    fs.watchFile filepath, (curr, prev) ->
        return if pending
        pending = yes
        if curr.mtime isnt prev.mtime
            # modified, wait a little before reloading
            # since modifications tend to come in waves
            setTimeout ->
                try
                    callback?(filepath)
                    pending = no
                catch err
                    console.error "#{e}".red.bold,"\n#{e?.stack}"
            , 11


class Watcher extends EventEmitter
    constructor: () ->
        @watched = {}

    watch: (files...) ->
        for file in files
            continue if @watched[file]
            @watched[file] = true
            watchFile(file, @emit.bind(this, 'changed'))


# exports

module.exports = {
    spiderDir
    wrap_prefix
    Watcher
}


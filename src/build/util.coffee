fs = require 'fs'
{ Stream } = require 'stream'


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


## this is just need to please tar
# Emit a whole document at once
class BufferedStream extends Stream
    run: (body) ->
        @emit 'data', body
        process.nextTick =>
            @emit 'end'

    resume: -> # stub
    pause: -> # stub



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


# exports

module.exports = {
    BufferedStream
    spiderDir
    wrap_prefix
}


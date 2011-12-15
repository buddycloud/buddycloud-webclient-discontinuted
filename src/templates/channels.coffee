unless process.title is 'browser'
    return module.exports =
        src: "streams.html"
        select: () ->
            @select "#channels", ".channel"


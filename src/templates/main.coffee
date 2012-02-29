unless process.title is 'browser'
    return module.exports =
        src: "streams.html"
        select: () ->
            @select "body > div", "*"


{ Template } = require 'dynamictemplate'
jqueryify = require 'dt-jquery'
design = require '../_design/main'
{ load_indicate } = require './util'


module.exports = design (view) ->
    return jqueryify new Template schema:5, ->

        @$div id:'editbar', ->
            @once('replace', load_indicate(this).clear)
            view.bind 'subview:editbar', @replace
            view.bind 'show', @show
            view.bind 'hide', @hide

        @$div id:'sidebar', ->
            @once('replace', load_indicate(this).clear)
            view.bind('subview:sidebar', @replace)

        @$div id:'content', ->
            indicator = load_indicate this
            view.bind 'subview:content', (tag) =>
                if indicator?
                    indicator.clear()
                    delete indicator

                console.log "content", tag
                @add(tag)

            view.bind 'show', @show
            view.bind 'hide', @hide





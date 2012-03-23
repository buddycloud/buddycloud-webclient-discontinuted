unless process.title is 'browser'
    return module.exports =
        src: "streams.html"
        select: () ->
            @select "body > div", "*"


{ Template } = require 'dynamictemplate'
design = require '../_design/main'
{ load_indicate } = require './util'


module.exports = design (view) ->
    return new Template schema:5, ->

        @$div class:'editbar', ->
            @once('replace', load_indicate(this).clear)
            view.bind('subview:editbar', @replace)
            view.bind('show', @show)
            view.bind('hide', @hide)

        @$div class:'sidebar', ->
            @once('replace', load_indicate(this).clear)
            view.bind('subview:sidebar', @replace)

        @$div id:'content', ->
            indicator = load_indicate this
            view.bind 'subview:content', (tag) =>
                if indicator?
                    indicator.clear()
                    delete indicator

                console.error "content", tag
                @ready =>
                    @_jquery?.parent().append(tag._jquery ? tag)
                    @_jquery?.detach()
                    @_jquery = tag._jquery ? tag

            view.bind('show', @show)
            view.bind('hide', @hide)





unless process.title is 'browser'
    return module.exports =
        src: "streams.html"
        select: () ->
            @select ".sidebar",
                ".channel:not(.personal), .personal.channel > *, div.search > *"


{ Template } = require 'dynamictemplate'
design = require '../../_design/sidebar/index'
{ load_indicate } = require '../util'

module.exports = design (view) ->
    return new Template schema:5, ->
        @$div class:'sidebar', ->
            @$div class:'personal channel', ->
                @remove() if app.users.isAnonymous(app.users.current)
                #@text "loading personal channel …"
                view.bind('subview:personalchannel', @replace)
            # nav.actionBar
            @$div class:'search', ->
                @once('replace', load_indicate(this).clear)
                view.bind('subview:searchbar', @replace)
            @$div id:'channels', ->
                @$div -># antiscroll
                    # channel ...
                    view.bind('subview:entry', @add)
            @$button id: 'create_topic_channel', ->
                if app.users.isAnonymous(app.users.current) or
                  not config.topic_domain?
                    @remove()

unless process.title is 'browser'
    return module.exports =
        src: "streams.html"
        select: () ->
            @select "#sidebar",
                ".channel:not(.personal), .personal.channel > *, div.search > *"


{ Template } = require 'dynamictemplate'
jqueryify = require 'dt-jquery'
design = require '../../_design/sidebar/index'

module.exports = design (view) ->
    return jqueryify new Template schema:5, ->
        @$div id:'sidebar', ->
            @$div ->
                @$div class:'personal channel', ->
                    @remove() if app.users.isAnonymous(app.users.current)
                    #@text "loading personal channel …"
                    view.bind('subview:personalchannel', @replace)
                @$div class:'search', ->
                    @text "loading searchbar …"
                    view.bind('subview:searchbar', @replace)
                @$div id:'channels', ->
                    @$div -># antiscroll
                        # channel ...
                        view.bind('subview:entry', @add)

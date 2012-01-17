unless process.title is 'browser'
    return module.exports =
        src: "streams.html"
        select: () ->
            @select "body > div", "*"


{ Template } = require 'dynamictemplate'
jqueryify = require 'dt-jquery'
design = require '../_design/main'

module.exports = design (view) ->
    return jqueryify new Template schema:5, ->

        @$div id:'editbar', ->
            @text "loading editbar …"
            view.bind('subview:editbar', @replace)

        @$div id:'sidebar', ->
            @text "loading sidebar …"
            view.bind('subview:sidebar', @replace)

        @$div id:'content', ->
            loading = yes
            @text "loading content …"
            view.bind 'subview:content', (tag) =>
                @text("", force:yes) if loading
                loading = no

                console.log "content", tag
                @add(tag)







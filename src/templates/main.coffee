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
            view.bind 'subview:editbar', (tag) =>
                @text "", force:yes
                @_jquery?.replaceWith(tag._jquery ? tag)
#                 @emit 'jquery:replace', tag

        @$div id:'sidebar', ->
            @text "loading sidebar …"
            view.bind 'subview:sidebar', (tag) =>
                @text "", force:yes
                @_jquery?.replaceWith(tag._jquery ? tag)
#                 @emit 'jquery:replace', tag

        @$div id:'content', ->
            @text "loading content …"
            view.bind 'subview:content', (tag) =>
                @text "", force:yes
#                 @attach(tag)
                console.log "content", tag
                @_jquery?.append(tag._jquery ? tag)
#                 @emit 'jquery:replace', tag







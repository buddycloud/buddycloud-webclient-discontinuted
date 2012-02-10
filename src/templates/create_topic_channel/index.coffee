unless process.title is 'browser'
    return module.exports =
        src: "create_topic_channel.html"
        select: () ->
            @select "div.channelView"


{ Template } = require 'dynamictemplate'
jqueryify = require 'dt-jquery'
design = require '../../_design/create_topic_channel/index'

module.exports = design (view) ->
    return jqueryify new Template schema:5, ->
        @$div class:'channelView', ->
            @$form class: "stream clearfix", ->
                @$div class: "location dual", ->
                    @remove()
                @$div class: "access", ->
                    @remove()
                @$div class: "role", ->
                    @remove()

            @$nav class: "bottom clearfix", ->
                @$div class: "button callToAction"
                @$div class: 'button', ->
                    # Discard button, where to return on click?
                    @remove()

            view.bind 'hide', @remove

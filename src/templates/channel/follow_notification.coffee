unless process.title is 'browser'
    return module.exports =
        src: "streams.html"
        select: () ->
            @select ".notification:first"


{ Template } = require 'dynamictemplate'
jqueryify = require 'dt-jquery'
design = require '../../_design/channel/follow_notification'


module.exports = design (view) ->
    return jqueryify new Template schema:5, ->
        @$article class: 'notification', ->
            @$section ->
                @$img ->
                    @attr 'src'
                @$span class: 'name', ->
                    @text view.model.get('id')

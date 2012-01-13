unless process.title is 'browser'
    return module.exports =
        src: "streams.html"
        select: () ->
            el = @select ".channelDetails .channelList:first", "img, .adminAction"
            el.find('h3').text ""
            el


{ Template } = require 'dynamictemplate'
jqueryify = require 'dt-jquery'
design = require '../../../_design/channel/details/list'


module.exports = design (view) ->
    return jqueryify new Template schema:5, ->
        @$section class: 'channelList', ->
            @$h3 ->
                @text "#{view.title} "
                @$span class: 'count', ->
                    @text "0"

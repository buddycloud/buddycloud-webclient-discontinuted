unless process.title is 'browser'
    return module.exports =
        src: "streams.html"
        select: () ->
            el = @select ".notification:first" , "*"
            el.find('p, span').text("")
            return el


{ Template } = require 'dynamictemplate'
jqueryify = require 'dt-jquery'
design = require '../../_design/channel/error_notification'


module.exports = design (view) ->
    return jqueryify new Template schema:5, ->
        @$article class: 'notification', ->
            @$section ->
                @$p ->
                    view.bind 'error', (text) =>
                        console.error "render error", text
                        @text text ? ""

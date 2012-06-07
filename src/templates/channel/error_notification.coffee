unless process.title is 'browser'
    return module.exports =
        src: "streams.html"
        select: () ->
            el = @select ".notification:first" , "*"
            el.find('p, span').text("")
            return el


{ Template } = require 'dynamictemplate'
design = require '../../_design/channel/error_notification'
{ addClass } = require '../util'

module.exports = design (view) ->
    return new Template {view:view,schema:5}, ->
        notification = @$article class: 'notification', ->
            @$section ->
                @$p ->
                    view.bind 'error', (text) =>
                        addClass(@,"visible")
                        @text text ? ""

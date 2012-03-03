unless process.title is 'browser'
    return module.exports =
        src: "streams.html"
        select: () ->
            @select ".notification:first", "section > *"


{ Template } = require 'dynamictemplate'
jqueryify = require 'dt-jquery'
design = require '../../_design/channel/pending_notification'


module.exports = design (view) ->
    return jqueryify new Template schema:5, ->
        @$article class: 'notification', ->
            view.bind 'visible', =>
                # TODO: use upcoming ready() in templates here:
                notifclass = @attr('class')
                if notifclass.indexOf('visible') is -1
                    @attr 'class', "#{notifclass} visible"
            view.bind 'invisible', =>
                @attr 'class', @attr('class').replace('visible', "")
                setTimeout(@remove, 2000) # wait for css animation

            @$section ->
                @$p ->
                    @text "Your subscription to this channel is pending owner approval"

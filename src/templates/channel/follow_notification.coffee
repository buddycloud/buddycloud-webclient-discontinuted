unless process.title is 'browser'
    return module.exports =
        src: "streams.html"
        select: () ->
            el = @select ".notification:first"
            el.find('.name').text("")
            el.find('.positive').text("")
            return el


{ Template } = require 'dynamictemplate'
jqueryify = require 'dt-jquery'
design = require '../../_design/channel/follow_notification'


module.exports = design (view) ->
    user = app.users.get_or_create(id: view.model.get('id'))

    return jqueryify new Template schema:5, ->
        @$article class: 'notification', ->
            view.bind 'visible', =>
                # TODO: use upcoming ready() in templates here:
                notifclass = @attr('class')
                if notifclass.indexOf('visible') is -1
                    @attr 'class', "#{notifclass} visible"
            view.bind 'invisible', =>
                @attr 'class', @attr('class').replace('visible', "")

            view.bind 'granted', =>
                @attr 'class', "#{@attr 'class'} log granted"
            view.bind 'denied', =>
                @attr 'class', "#{@attr 'class'} log denied"

            @$section ->
                @$img ->
                    @attr 'src', user.avatar
                @$span class: 'name', ->
                    @text view.model.get('id')

                @$div class: 'controls', ->
                    @$div class: "button small positive light", ->
                        @text "Grant #{view.model.get('id')} to join"

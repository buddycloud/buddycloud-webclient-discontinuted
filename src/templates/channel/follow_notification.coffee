unless process.title is 'browser'
    return module.exports =
        src: "streams.html"
        select: () ->
            el = @select ".notification:first"
            el.find('.name').text("")
            el.find('.positive').text("")
            return el


{ Template } = require 'dynamictemplate'
design = require '../../_design/channel/follow_notification'
{ addClass, removeClass } = require '../util'


module.exports = design (view) ->
    user = app.users.get_or_create(id: view.model.get('id'))

    return new Template schema:5, ->
        @$article class: 'notification', ->
            view.bind 'visible', =>
                addClass(@,"visible")
            view.bind 'invisible', =>
                removeClass(@,"visible")
                setTimeout(@remove, 2000) # wait for css animation

            view.bind 'granted', =>
                addClass(@,"log", "granted")
            view.bind 'denied', =>
                addClass(@,"log", "denied")

            @$section ->
                @$img ->
                    @attr 'src', user.avatar
                    @attr 'title', view.model.get('id')
                    @attr 'onerror', 'app.avatar_fallback(this)'
                @$div class:'info', ->
                    @$span class:'name', ->
                        @text "#{view.model.get 'id'} "

                @$div class: 'controls', ->
                    @$div class: "positive", ->
                        @text "Grant #{view.model.get('id')} to join"

                    # Don't let users click twice
                    view.bind 'loading', @hide

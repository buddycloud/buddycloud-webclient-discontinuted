formatdate = require 'formatdate'
{ BaseView } = require '../base'
{ EventHandler } = require '../../util'

class exports.PostView extends BaseView
    template: require '../../templates/channel/post'

    initialize: ({@type}) ->
        super
#         @model.bind 'change', throttle_callback(50, @render) FIXME

    render: (callback) ->
        super ->
            @rendered = yes
#         @$('.name').attr href: @author?.get('jid') or "?"
            formatdate.hook @el, update: off
            callback?.call(this)

    events:
        'click .name': 'clickAuthor'
        'click .avatar': 'clickAuthor'

    clickAuthor: EventHandler ->
        app.router.navigate @get('author')?.get('jid'), true

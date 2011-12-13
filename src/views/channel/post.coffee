formatdate = require 'formatdate'
{ BaseView } = require '../base'
{ EventHandler, throttle_callback } = require '../../util'

class exports.PostView extends BaseView
    template: require '../../templates/channel/post.eco'

    initialize: ({@parent, @type}) =>
        super
        @model.bind 'change', throttle_callback(50, @render)

    render: =>
        @post = @model.toJSON() # data
        @author = @model.author # model
        super
        @$('.name').attr href: @author?.get('jid') or "?"
        formatdate.hook @el, update: off

    events:
        'click .name': 'clickAuthor'
        'click .avatar': 'clickAuthor'

    clickAuthor: EventHandler ->
        app.router.navigate @author.get('jid'), true

{ BaseView } = require 'views/base'
{ EventHandler } = require 'util'


class exports.PostView extends BaseView
    template: require 'templates/channel/post'

    initialize: ({@parent, @type}) =>
        super
        @model.bind 'change', @render
        @model.author.bind 'change', @render

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

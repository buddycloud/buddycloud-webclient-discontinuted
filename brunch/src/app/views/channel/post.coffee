{ BaseView } = require 'views/base'

class exports.PostView extends BaseView
    template: require 'templates/channel/post'

    initialize: ({@parent, @type}) =>
        super

    render: =>
        @post = @model.toJSON() # data
        @author = @model.author # model
        super
        @$('.name').attr href: @author.get('jid') or "?"
        formatdate.hook @el, update: off

    events:
        'click .name': 'clickAuthor'
        'click .avatar': 'clickAuthor'

    clickAuthor: (ev) =>
        ev?.preventDefault()
        app.router.setCurrentChannel @author.get('jid')
        no # normal http anchor behavior
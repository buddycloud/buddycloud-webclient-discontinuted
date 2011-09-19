{ BaseView } = require('views/base')

class exports.PostView extends BaseView
    template: require 'templates/channel/post'

    render: =>
        @post = @model.toJSON() # data
        @author = @model.author # model
        super
        formatdate.hook @el, update: off

    events:
        'click .name': 'clickAuthor'
        'click .avatar': 'clickAuthor'

    clickAuthor: =>
        app.router.navigate @author.get('jid'), true
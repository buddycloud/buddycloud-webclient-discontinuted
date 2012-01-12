formatdate = require 'formatdate'
{ BaseView } = require '../base'
{ EventHandler } = require '../../util'

class exports.PostView extends BaseView
    template: require '../../templates/channel/post'

    initialize: ({@type}) ->
        super

    events:
        'click .name': 'clickAuthor'
        'click .avatar': 'clickAuthor'

    clickAuthor: EventHandler ->
        app.router.navigate @model.get('author')?.jid, true


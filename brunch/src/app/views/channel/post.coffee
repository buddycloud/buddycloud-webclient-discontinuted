
class exports.PostView extends Backbone.View
    template: require 'templates/channel/post'

    initialize: ({@parent}) ->
        @el = $("<div>").attr id:@cid

    render: =>
        @post = @model.toJSON()
        @author = @model.author
        old = @el; old.replaceWith @el = $(@template this).attr id:@cid
        formatdate.hook @el, update:off
        @delegateEvents()

    events:
        'click .name': 'clickAuthor'
        'click .avatar': 'clickAuthor'

    clickAuthor: =>
        app.router.navigate @author.get('jid'), true
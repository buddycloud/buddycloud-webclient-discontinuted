{ BaseView } = require '../base'
{ EventHandler } = require '../../util'


# expects a channel model
class exports.DiscoverListEntryView extends BaseView
    template: require '../../templates/discover/entry'

    initialize: ({@model, @parent}) ->
        @statusnode = @model.nodes.get_or_create(id: 'status')
        @statusnode.bind 'post', @update_status
        @parent.on('destroy', @destroy)
        @update_status()
        unless @status
            app.handler.data.get_node_posts @statusnode

    update_status: =>
        @status = @statusnode.posts.first()?.get('content')?.value
        @trigger 'status', @status

    events:
        click: 'on_click'

    on_click: =>
        app.router.navigate @model.get('id'), yes

    destroy: =>
        return if @destroyed
        delete @statusnode
        delete @status
        super

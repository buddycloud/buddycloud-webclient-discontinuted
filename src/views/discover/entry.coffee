{ BaseView } = require '../base'
{ EventHandler } = require '../../util'


# expects a channel model
class exports.DiscoverListEntryView extends BaseView
    template: require '../../templates/discover/entry'

    initialize: ({@model}) ->
        @statusnode = @model.nodes.get_or_create(id: 'status')
        @statusnode.bind 'post', @update_status
        @update_status()
        unless @status
            app.handler.data.get_node_posts @statusnode

    update_status: =>
        @status = @statusnode.posts.at(0)?.get('content')?.value
        @trigger 'status', @status


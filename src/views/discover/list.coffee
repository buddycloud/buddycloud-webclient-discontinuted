{ BaseView } = require '../base'
{ EventHandler } = require '../../util'
{ DiscoverListEntryView } = require './entry'


# expects a Channels collection as model
class exports.DiscoverListView extends BaseView
    template: require '../../templates/discover/list'

    initialize: ({@name, @model, @id}) ->
        @model.bind 'add', @add_entry

    add_entry: (entry) =>
        view = new DiscoverListEntryView(model: entry, parent: this)
        view.bind 'template:create', (tpl) =>
            @trigger 'subview:entry', tpl
        view.render()
#         view.render =>
#             @trigger 'subview:entry', view.el

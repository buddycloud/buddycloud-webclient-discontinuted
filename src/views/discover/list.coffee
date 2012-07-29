{ BaseView } = require '../base'
{ EventHandler } = require '../../util'
{ DiscoverListEntryView } = require './entry'


# expects a Channels collection as model
class exports.DiscoverListView extends BaseView
    template: require '../../templates/discover/list'

    initialize: ({@name, @model, @id}) ->

    add_entry: (entry) =>
        i = @model.indexOf(entry)
        view = new DiscoverListEntryView(model: entry, parent: this)
        view.bind 'template:create', (tpl) =>
            @trigger 'subview:entry', i, tpl
        view.render()

    render: (callback) ->
        super ->
            callback?()
            @model.bind 'add', @add_entry
            @model.forEach     @add_entry

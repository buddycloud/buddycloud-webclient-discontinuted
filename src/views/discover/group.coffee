{ BaseView } = require '../base'
{ EventHandler } = require '../../util'
{ DiscoverListView } = require './list'


# manages a list of channel collections
class exports.DiscoverGroupView extends BaseView
    template: require '../../templates/discover/group'

    initialize: ({@name, @id, lists}) ->
        @views = {}
        super

        for id, listOpts of lists
            opts = Object.create(listOpts)
            opts.id = id
            @views[id] =
                new DiscoverListView opts


    render: (callback) ->
        super ->
            for _, view of @views
                view.bind 'template:create', (tpl) =>
                    @trigger 'subview:list', tpl
                view.render()
#                 do (view) => view.render =>
#                     @trigger 'subview:list', view.el
            callback?.call(this)




{ BaseView } = require '../base'
{ EventHandler } = require '../../util'
{ DiscoverListView } = require './list'


# manages a list of channel collections
class exports.DiscoverGroupView extends BaseView
    template: require '../../templates/discover/group'

    initialize: ({@name, @id, lists}) ->
        @views = {}
        super

        for id, name of lists
            @views[id] = new DiscoverListView {id, name}


    render: (callback) ->
        super ->
            for _, view of @views
                do (view) => view.render =>
                    @trigger 'subview:list', view.el
            callback?.call(this)




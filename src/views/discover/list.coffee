{ BaseView } = require '../base'
{ EventHandler } = require '../../util'
{ DiscoverListEntryView } = require './entry'


# expects a Channels collection as model
class exports.DiscoverListView extends BaseView
    template: require '../../templates/discover/list'

    initialize: ({@name, @id}) ->


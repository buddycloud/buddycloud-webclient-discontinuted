{ Model } = require 'models/base'

class exports.Metadata extends Model
    type:'unspecified' # should be overriden by extending classes

    initialize: ({@parent, @id}) ->
        @localStorage = new Store "metadata-#{@type}-#{@id}"
        @fetch()
        @bind 'change',(args...) =>
            app.debug "EV metadata change", @id, arguments
            args.unshift "change:#{@type}:metadata"
            @parent.trigger.apply @parent, args

{ Metadata } = require 'models/metadata/base'

class exports.NodeMetadata extends Metadata
    type: 'node'

    query: ->
        app.handler.data.get_node_metadata @parent, (metadata) =>
            app.debug "GOT node metadata", @id, this, metadata
            @save metadata

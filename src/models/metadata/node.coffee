{ Metadata } = require './base'

class exports.NodeMetadata extends Metadata
    type: 'node'

    query: ->
        app.handler.data.get_node_metadata @parent, (metadata) =>
            @save metadata

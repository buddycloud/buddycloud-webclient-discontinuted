{ Metadata } = require './base'

class exports.UserMetadata extends Metadata
    type: 'user'

    initialize: (opts = {}) ->
        opts.id ?= opts.parent.get 'id'
        super opts

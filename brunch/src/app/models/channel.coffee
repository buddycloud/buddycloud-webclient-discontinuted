{ NodeStore } = require 'collections/node'
{ gravatar } = require 'helper'

class exports.Channel extends Backbone.Model
    initialize: ->
        @nodes = new NodeStore this
        @avatar = gravatar @get('jid'), s:50, d:'retro'
        @nodes.bind 'all', => @trigger.apply this, arguments
        @nodes.fetch()


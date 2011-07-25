{ Topics } = require 'collections/topic'
{ Node } = require 'models/node/skeleton'

class exports.ChannelNode extends Node

    initialize: ->
        @topics = new Topics
        super

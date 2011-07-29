{ TopicPosts } = require 'collections/topicpost'
{ Node } = require 'models/node/skeleton'

class exports.ChannelNode extends Node

    initialize: ->
        result = super
        @posts = new TopicPosts # overwriting default Posts
        result

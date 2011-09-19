{ TopicPosts } = require 'collections/topicpost'
{ Node } = require 'models/node/base'

class exports.PostsNode extends Node

    initialize: ->
        result = super
        @posts = new TopicPosts # overwriting default Posts
        result

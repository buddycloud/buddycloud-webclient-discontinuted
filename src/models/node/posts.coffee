{ TopicPosts } = require '../../collections/topicpost'
{ Node } = require './base'

class exports.PostsNode extends Node

    initialize: ->
        # overwriting default Posts
        @posts = new TopicPosts parent:this
        @posts.on('change:updated', @trigger.bind(this, 'post:updated'))
        super

{ Posts } = require 'collections/post'
{ Post } = require 'models/post'

class exports.TopicPost extends Post

    initialize: ->
        @comments = new Posts(parent: this)
        super

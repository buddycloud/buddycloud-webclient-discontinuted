{ Posts } = require 'collections/post'
{ Post } = require 'models/post'

class exports.Topic extends Backbone.Model

    initialize: ->
        @opener = new Post # FIXME no new
        @comments = new Posts

{ Posts } = require 'collections/post'
{ Node } = require 'models/node/skeleton'

class exports.MoodNode extends Node

    initialize: ->
        @posts = new Posts
        super

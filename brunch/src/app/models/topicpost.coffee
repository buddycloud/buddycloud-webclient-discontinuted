{ Posts } = require 'collections/post'
{ Post } = require 'models/post'

##
# Is "opener" along with additional "comments"
class exports.TopicPost extends Post

    initialize: ->
        @comments = new Posts(parent: this)
        super

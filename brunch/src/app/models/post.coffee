{ PostMetadata } = require 'models/metadata/post'
#{ User } = require 'models/user'

class exports.Post extends Backbone.Model

    initialize: ->
        @metadata = new PostMetadata this, @get('id')
        @author = null # new User # FIXME no new
        @content = null # FIXME

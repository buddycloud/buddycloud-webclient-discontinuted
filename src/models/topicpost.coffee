{ Comments } = require '../collections/post'
{ Post } = require './post'

##
# Is "opener" along with additional "comments"
class exports.TopicPost extends Post

    initialize: ->
        @comments = new Comments parent:this
        super

    # Also dives into comments
    get_last_update: () ->
        last_post = @get_update_time()
        last_comment = @comments.last()?.get_update_time()
        if last_comment > last_post
            return last_comment
        else
            return last_comment
#
{ Posts } = require 'collections/post'
{ Post } = require 'models/post'

##
# Is "opener" along with additional "comments"
class exports.TopicPost extends Post

    initialize: ->
        @comments = new Posts parent:this
        # Bubble changes up:
        @comments.bind 'all', =>
            @trigger 'change'
        super

    # Also dives into comments
    get_last_update: =>
        last = super
        # Comments are sorted newest last
        last1 = @comments.at(@comments.length)?.get_last_update()
        if last1 and last1 > last
            last = last1
        last

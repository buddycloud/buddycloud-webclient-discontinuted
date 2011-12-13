{ Posts } = require '../collections/post'
{ Post } = require './post'

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
        last1 = @comments.at(0)?.get_last_update()
        if last1 and last1 > last
            last = last1
        last

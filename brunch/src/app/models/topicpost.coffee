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
        @comments.bind 'change:unread', =>
            @trigger 'change:unread'
        super

    # Also dives into comments
    get_last_update: =>
        last = super
        @comments.each (comment) ->
            last1 = comment.get_last_update()
            if last < last1
                last = last1
        last

    count_unread: ->
        count = 0
        if @get('unread')
            count++
        count += @comments.count_unread()
        count

    mark_read: ->
        @unset 'unread'
        @comments.mark_read()

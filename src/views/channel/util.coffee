{ gravatar } = require '../../util'

exports.setupInlineMention = (element) ->
    @getPostsNode()
    if !@postsNode?
        return
    followers = []
    @postsNode.subscribers.forEach (subscriber) ->
        if subscriber.get('subscription') is 'none'
            return
        jid = subscriber.get 'id'
        followers[jid] = {jid:jid, avatar: "#{gravatar jid}"}
    if @autocomplete?
        # Just update followers
        @autocomplete.setLookup followers
        return
    @autocomplete = $(element).autocomplete(
        lookup: followers
        minChars: 1
        zIndex: 9999
        searchPrefix: '@'
        noCache: true
        dataKey: 'jid'
        delimiter: ' '
    )
    @autocomplete.template = (entry,  formatResult, currentValue, suggestion) ->
        entry = formatResult suggestion, entry, currentValue
        return "<img class=\"avatar\" src=\"#{@options.lookup.suggestions[suggestion].avatar}\"/><span class=\"entry\">#{entry}</span>"
    @postsNode.on 'subscriber:update', (user) =>
        @setupInlineMention(element)


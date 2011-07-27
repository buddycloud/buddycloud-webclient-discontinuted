
# The channel shows channel content
class exports.ChannelView extends Backbone.View
    template: require 'templates/channel/show'

    initialize: ({@parent}) ->
        @el = $("<div>").attr id:@cid
        @model.bind 'change:node:metadata', @render

    render: =>
        @update_attributes()
        old = @el; old.replaceWith @el = $(@template this).attr id:@cid
        @info = @el.find('.channelDetails')
        #@el.find('.info.button').click => @info.toggleClass('hidden')

    update_attributes: ->
        if (channel = @model.nodes.get 'channel')
            @channel = channel.toJSON yes
        if (mood = @model.nodes.get 'mood')
            @mood = mood.toJSON yes
        if (geo = @model.nodes.get 'geo')
            @geo = geo.toJSON yes
        #permissions
        affiliation = app.users.current.affiliations.get(@model.nodes.get('channel')?.get 'nodeid')
        @user =
            followingThisChannel: affiliation in ["owner", "publisher", "moderator", "member", "outcast"]
            hasRightToPost: affiliation in ["owner", "publisher", "moderator", "member"]


# this shows a list of user avatars

class exports.UserList extends Backbone.View
    template: require 'templates/channel/details/list'

    initialize: ({@parent, @usertypes, @name}) ->
        @el = $(@template this).attr id:@cid
        app.users.bind 'add', @render
        super

    render: =>
        @update_attributes()
        old = @el; old.replaceWith @el = $(@template this).attr id:@cid

    update_attributes: ->
        @users = []
        nodeid = "/user/#{@model.get 'id'}/posts"
        @usertypes.forEach (type) =>
            @users = @users.concat app.users.filter_by type, nodeid

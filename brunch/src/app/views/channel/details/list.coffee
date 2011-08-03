{ UserAdmin } = require 'views/channel/details/admin/user'

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

        @el.find('.list').find('.user').each (i, user) =>
            user = $(user)
            user.click =>
                @admin?.remove()
                unless user.attr("data-user") is @admin?.model.get 'id' # does hide
                    @admin = new UserAdmin
                        model:app.users.get user.attr "data-user"
                        parent:this
                        number: i
                    do @admin.render
                    @admin.el.insertAfter user
                else
                    delete @admin

    update_attributes: ->
        @users = []
        nodeid = "/user/#{@model.get 'id'}/posts"
        @usertypes.forEach (type) =>
            @users = @users.concat app.users.filter_by type, nodeid

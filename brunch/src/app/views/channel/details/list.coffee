{ UserAdmin } = require 'views/channel/details/admin/user'
{ BaseView } = require('views/base')

# this shows a list of user avatars

class exports.UserList extends BaseView
    template: require 'templates/channel/details/list'

    initialize: ({@parent, @usertypes, @name}) ->
        super
        app.users.bind 'add', @render

    render: =>
        @update_attributes()
        super

        @el.find('.list').find('.user').each (i, user) =>
            user = $(user)
            userid = user.attr "data-user"
            user.dblclick ->
                app.router.navigate userid, true
            user.click =>
                @admin?.remove()
                unless userid is @admin?.model.get 'id' # does hide
                    @admin = new UserAdmin
                        model:app.users.get userid
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

{ UserAdmin } = require 'views/channel/details/admin/user'
{ BaseView } = require('views/base')
{ EventHandler } = require 'util'

# this shows a list of user avatars

class exports.UserList extends BaseView
    template: require 'templates/channel/details/list'

    initialize: ({@parent, @title}) ->
        super
        @model.bind 'add', @render
        @model.bind 'remove', @render

    events:
        'click .list a': 'clickUser'

    render: =>
        @update_attributes()
        super

    # @model can be a users (followers) or channels (following)
    # collection
    update_attributes: ->
        @users = @model.map (user) ->
            if user.has('jid')
                user
            else
                app.users.get user.get('id')

    clickUser: EventHandler (ev) =>
        userid = $(ev.currentTarget).attr 'href'
        app.router.navigate userid, true

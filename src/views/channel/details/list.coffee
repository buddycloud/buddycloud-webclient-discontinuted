{ UserAdmin } = require './admin/user'
{ BaseView } = require '../../base'
{ EventHandler, compare_by_id, throttle_callback } = require '../../../util'

# this shows a list of user avatars

class exports.UserList extends BaseView
    template: require '../../../templates/channel/details/list.eco'

    initialize: ({@parent, @title}) ->
        super
        render_callback = throttle_callback(50, @render)
        @model.bind 'add', render_callback
        @model.bind 'remove', render_callback

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
        @users = @users.filter (user) ->
            user?.has 'jid'
        @users = @users.sort compare_by_id

    clickUser: EventHandler (ev) =>
        userid = $(ev.currentTarget).attr 'href'
        app.router.navigate userid, true

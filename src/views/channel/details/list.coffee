{ BaseView } = require '../../base'
{ EventHandler } = require '../../../util'
{ UserInfoView } = require './user'

class exports.ChannelDetailsList extends BaseView
    template: require '../../../templates/channel/details/list'

    events:
        'click .showAll': 'showAll'
        'click .avatar': 'showUser'
        'dblclick .avatar': 'clickUser'

    initialize: ({@title, @load_more, @ignore_users}) ->
        super

        @showing_all = no
        @showing_count = 0
        @showing_users = {}

        @info = new UserInfoView parent:this

        @ready =>
            @add_all()
            @model.bind 'add', @add_user
            @model.bind 'remove', @remove_user

            if @model.length < 8
                @load_more(false)

    add_user: (user) =>
        user_id = user.get('id')

        show = =>
            @showing_count++
            @showing_users[user_id] = yes
            @trigger 'add', user

        unless @showing_users[user_id] or
               (@ignore_users and @ignore_users.indexOf(user_id) >= 0)
            # Is not already shown
            if @showing_all
                # Expanded by "show all"
                show()
            else if not @showing_all and @showing_count < 8
                show()

    remove_user: (user) =>
        user_id = user.get('id')
        if @showing_users[user_id]
            delete @showing_users[user_id]
            @showing_count--
            @trigger 'remove', user

            # Fill spot that is left
            @add_one()

    add_one: =>
        hidden = @model.filter (user1) =>
            not @showing_users[user1.get('id')]
        if not @showing_all and hidden?[0]?
            @add_user hidden[0]

    add_all: =>
        @model.each @add_user

    showAll: EventHandler ->
        @showing_all = yes
        @add_all()
        @trigger 'show:all'
        @load_more(true)

    showUser: EventHandler (ev) ->
        el = $(ev.target)
        user = app.users.get_or_create(id:el.data('userid')) # FIXME UGLY
        @info.set_user user, el

    clickUser: EventHandler (ev) ->
        userid = $(ev.target).data('userid') # FIXME UGLY
        app.router.navigate userid, true if userid



{ BaseView } = require '../../base'
{ EventHandler } = require '../../../util'

class exports.UserInfoView extends BaseView
    template: require '../../../templates/channel/details/user'

    events:
        'click .channelInfo h4': 'navigate'
        'click .changeRoleButton': 'on_click_changeRoleButton'
        'click .banUserButton': 'on_click_banUserButton'
        'click .cancelButton': 'on_click_cancel'
        'click .okButton': 'on_click_ok'
        'change select': 'on_change_select'

    initialize: () ->
        super
        @once('template:create', (@_tpl) => )
        @parent.parent.parent.bind('update:affiliations', # ugly
               @trigger.bind(this, 'update:affiliations'))
        @parent.parent.parent.bind('update:permissions',  # ugly
               @trigger.bind(this, 'update:permissions'))

    render: =>
        @rendering = yes
        super

    tpl: (callback) ->
        return callback?(@_tpl) if @_tpl
        @once('template:create', callback)

    navigate: EventHandler ->
        if @currentjid?
            app.router.navigate @currentjid, true

    on_click_changeRoleButton: EventHandler ->
        @changing_role = yes
        @trigger 'click:changeRole'

    on_click_banUserButton: EventHandler ->
        @banning = yes
        @trigger 'click:banUser'

    on_click_cancel: EventHandler ->
        # Remove this popup
        @set_user null

    on_click_ok: EventHandler ->
        userid = @parent.parent.parent.model.get 'id'
        if @changing_role
            affiliation = @$('select').val()
        else if @banning
            affiliation = 'outcast'
        else
            affiliation = 'none'
        app.handler.data.set_channel_affiliation userid, @currentjid, affiliation, (err) =>
            unless err
                # Remove:
                @on_click_cancel()

    on_change_select: (ev) ->
        @trigger 'update:select:affiliation', $(ev.target).attr('value')

    set_user: (user) ->
        return @trigger 'update:select:none'unless user?
        delete @changing_role
        delete @banning
        @currentjid = user.get 'id'
        @trigger 'update:select:user', user
        do @render unless @rendering



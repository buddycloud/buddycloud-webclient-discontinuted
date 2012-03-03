{ BaseView } = require '../../base'
{ EventHandler } = require '../../../util'

arrowpos = ['first', 'second', 'third', 'fourth']

class exports.UserInfoView extends BaseView
    template: require '../../../templates/channel/details/user'

    events:
        'click .channelInfo h4': 'navigate'
        'click .cancelButton': 'on_click_cancel'
        'click .okButton': 'on_click_ok'
        'change select': 'on_change_select'

    initialize: () ->
        @mode = 'show'
        super
        @render()

    navigate: EventHandler ->
        if @currentjid?
            app.router.navigate @currentjid, true

    on_click_cancel: EventHandler ->
        # Remove this popup
        # HACK: fix set_user()!
        @set_no_user()

    on_click_ok: EventHandler ->
        userid = @parent.parent.parent.model.get 'id'
        affiliation = @$('select').val()
        app.handler.data.set_channel_affiliation userid, @currentjid, affiliation, (err) =>
            unless err
                # Remove:
                @on_click_cancel()

    on_change_select: ->
        @trigger 'update:select:affiliation'

    set_no_user: ->
        @ready =>
            # prepare
            @el.detach()
            @_olduser?.removeClass('selected')
            # close
            return delete @_olduser

    set_user: (user, el) ->
        @ready =>
            # prepare
            @el.detach()
            @_olduser?.removeClass('selected')
            # close when visible
            if @_olduser?.data('userid') is user.get('id')
                return delete @_olduser
            # update
            @trigger 'user:update', user
            @currentjid = user.get 'id'
            imgs = $("img", el.parent())
            # update arrow
            for cls in arrowpos
                @el.removeClass(cls)
            idx = imgs.index(el)
            @el.addClass(arrowpos[idx%4]) if idx isnt -1
            # add it to the dom
            row = idx - idx%4 + 3
            if imgs.length < 4 or row > imgs.length - 1
                @el.insertAfter imgs.last()
            else
                @el.insertAfter imgs.eq(row)
            # show it!
            @el.show()
            el.addClass('selected')
            @_olduser = el



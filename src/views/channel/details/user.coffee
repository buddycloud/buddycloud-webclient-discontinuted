{ BaseView } = require '../../base'
{ EventHandler } = require '../../../util'

arrowpos = ['first', 'second', 'third', 'fourth']

class exports.UserInfoView extends BaseView
    template: require '../../../templates/channel/details/user'

    events:
        'click .channelInfo h4': 'navigate'

    initialize: () ->
        @mode = 'show'
        super
        @render()

    navigate: EventHandler ->
        if @currentjid?
            app.router.navigate @currentjid, true

    set_mode: (mode) ->
        @mode = mode
        switch mode
            when 'show'
                @el.find('.actionRow').hide()
            when 'moderator'
                @el.find('.actionRow').show()
                # TODO more


    set_user: (user, el) ->
        @ready =>
            # prepare
            @el.detach()
            @_olduser?.removeClass('selected')
            # close when visible
            if @_olduser?.data('userid') is user.get('id')
                return delete @_olduser
            # update
            @set_mode 'show'
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



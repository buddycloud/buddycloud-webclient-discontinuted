{ BaseView } = require '../../base'
{ EventHandler } = require '../../../util'

arrowpos = ['first', 'second', 'third', 'fourth']

class exports.UserInfoView extends BaseView
    template: require '../../../templates/channel/details/user'

    initialize: () ->
        super
        @render()

    set_user: (user, el) ->
        @ready =>
            @_olduser?.removeClass('selected')
            @el.detach()
            @trigger 'user:update', user
            imgs = $("img", el.parent())
            # update arrow
            for cls in arrowpos
                @el.removeClass(cls)
            idx = imgs.index(el)
            @el.addClass(arrowpos[idx%4]) if idx isnt -1
            # add it to the dom
            @el.insertAfter imgs.eq(idx - idx%4 + 3)
            # show it!
            @el.show()
            el.addClass('selected')
            @_olduser = el



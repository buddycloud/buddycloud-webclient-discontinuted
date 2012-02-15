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
            @el.insertAfter el
            # update arrow
            for cls in arrowpos
                @el.removeClass(cls)
            idx = $("img", el.parent()).index(el)
            @el.addClass(arrowpos[idx%4]) if idx isnt -1
            # show it!
            @el.show()
            el.addClass('selected')
            @_olduser = el



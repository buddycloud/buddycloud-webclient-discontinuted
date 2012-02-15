{ BaseView } = require '../../base'
{ EventHandler } = require '../../../util'

class exports.UserInfoView extends BaseView
    template: require '../../../templates/channel/details/user'

    initialize: () ->
        super
        @render()

    set_user: (user, el) ->
        @ready =>
            @el.detach()
            @trigger 'user:update', user
            @el.insertAfter el
            @el.show()



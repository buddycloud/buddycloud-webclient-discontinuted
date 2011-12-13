{ BaseView } = require '../../..//base'

class exports.UserAdmin extends BaseView
    template: require '../../../../templates/channel/details/admin/user.eco'

    initialize: ({@number}) ->
        super
        @model.bind 'change', @render
        @model.bind 'change:node:metadata', @render

    render: =>
        @update_attributes()
        super

    update_attributes: ->
        @user = @model.toJSON()
        nodeid = "/user/#{@parent.model.get 'id'}/posts"
        @usertype = "unknown" # TODO

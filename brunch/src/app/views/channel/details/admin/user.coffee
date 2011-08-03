
class exports.UserAdmin extends Backbone.View
    template: require 'templates/channel/details/admin/user'

    initialize: ({@parent, @number}) ->
        @el = $(@template this).attr id:@cid
        @model.bind 'change', @render
        @model.bind 'change:node:metadata', @render
        super

    render: =>
        @update_attributes()
        old = @el; old.replaceWith @el = $(@template this).attr id:@cid

    update_attributes: ->
        @user = @model.toJSON()
        nodeid = "/user/#{@parent.model.get 'id'}/posts"
        @usertype = @model.affiliations.get nodeid

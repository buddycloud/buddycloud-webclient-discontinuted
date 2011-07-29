
class exports.PostView extends Backbone.View
    template: require 'templates/channel/post'

    initialize: ({@parent}) ->
        @el = $("<div>").attr id:@cid

    render: =>
        @post = @model.toJSON()
        @author = @model.author
        old = @el; old.replaceWith @el = $(@template this).attr id:@cid

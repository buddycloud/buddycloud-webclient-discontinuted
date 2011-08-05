
class exports.Post extends Backbone.Model

    initialize: ->
        result = super
        @author = app.users.get @get('author').name, yes
        result

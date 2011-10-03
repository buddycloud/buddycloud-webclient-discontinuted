
class exports.Model extends Backbone.Model

    sync: (method, model, options) ->
        options.success(model) # do nothing

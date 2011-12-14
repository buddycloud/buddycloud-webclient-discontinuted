
class exports.Collection extends Backbone.Collection
    constructor: (options) ->
        @parent ?= options?.parent
        super()

    sync: (method, model, options) ->
        options.success(model) # do nothing

    has: (model, options) ->
        @get(model, options)?

    get_or_create: (attrs, options = {}) ->
        if (model = @get(attrs.id))
            model.save(attrs, options)
        else
            model = @create(attrs, options)
        model.sync = @sync
        return model


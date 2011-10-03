
class exports.Collection extends Backbone.Collection
    constructor: (options) ->
        @parent ?= options?.parent
        super()

    sync: (method, model, options) ->
        options.success(model) # do nothing

    has: (model, options) ->
        @get(model, options)?

    # using update:yes in create or add will result in
    # updateing allready existing models with new data or just creates them
    _prepareModel: (raw_model, options = {}) ->
        opts = _.clone options
        opts.create = no
        opts.update = no
        if (known = @get(raw_model.id, opts))
            known.save(raw_model, opts)
            model = known

        model ?= super
        model.sync = @sync
        console.warn "Collection._prepareModel", @, raw_model, model
        return model

    get: (id, options = {}) ->
        console.warn "Collection.get", id, options
        if typeof id isnt 'string'
            console.trace()
            throw 'get w/o str'
        super

    get_or_create: (attrs, options = {}) ->
        # TODO: opts.update?
        console.warn "Collection.get_or_create", attrs, options

        if (model = @get(attrs.id))
            model.save(attrs, options)
            model
        else
            @create(attrs, options)


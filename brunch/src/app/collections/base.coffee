
class exports.Collection extends Backbone.Collection

    sync: (method, model, options) ->
        options.success(model) # do nothing

    has: (model, options) ->
        @get(model, options)?

    # using update:yes in create or add will result in
    # updateing allready existing models with new data or just creates them
    _prepareModel: (model, options = {}) ->
        if options.update
            opts = _.clone options
            opts.create = no
            opts.update = no
            if (known = @get(model, opts))
                known.save(model, opts)
                return known
        super

    get:(id, options = {}) ->
        model = super
        if not model and options.create
            return @create(id, options)
        else
            return model


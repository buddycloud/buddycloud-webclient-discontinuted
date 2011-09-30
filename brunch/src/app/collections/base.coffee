{ direct } = require 'util'


class exports.Collection extends Backbone.Collection

    constructor: ->
        direct.handle this
        super

    sync: -> this # don't save anything anywhere

    has: (model, options) ->
        @get(model, options)?

    # using update:yes in create or add will result in
    # updateing allready existing models with new data or just creates them
    _prepareModel: (model, options = {}) ->
        if options.update and (known = @get(model, options))
            known.set(model, options)
            return known
        super

    get:(id, options = {}) ->
        model = super
        if not model and options.create
            return @create(id, options)
        else
            return model

    add: direct.forbidden  -> super
    create: direct.allowed -> super
    reset : direct.allowed -> super
    fetch : direct.allowed -> super




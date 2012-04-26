
exports.load_indicate = (tag) ->
    indicator = null

    timeout = setTimeout ->
        indicator = tag.$p class:'loader', ->
            @$span class:'blub'
    , 1000

    return self =
        clear: ->
            clearTimeout(timeout)
            self?.remove?()
        remove: ->
            indicator?.remove()

exports.ready = (tag, view) ->
    tag.ready ->
        view.trigger 'dom:ready'

exports.insert = (list, i, el) ->
    v = @builder.template._view
#     console.error "#{v.cid} insert #{v.ns} #{i}", el
    list.insert(i, el)
    @add(el)

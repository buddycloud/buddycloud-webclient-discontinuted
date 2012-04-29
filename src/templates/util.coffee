
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
    list.insert(i, el)
    @add(el)

exports.addClass = (tag, classes...) ->
    return unless tag?.attr
    tagclass = tag.attr 'class'
    for cls in classes
        unless new RegExp(cls).test tagclass
            tagclass = "#{cls} #{tagclass}"
    tag.attr class:tagclass.replace(/\s\s/g, " ")

exports.removeClass = (tag, classes...) ->
    return unless tag?.attr
    tagclass = tag.attr 'class'
    for cls in classes
        if new RegExp(cls).test tagclass
            tagclass = tagclass.replace(cls, "")
    tag.attr class:tagclass

# thanks to http://www.alistapart.com/articles/expanding-text-areas-made-elegant/
exports.autoResize = (container) ->
    res = {container}
    res.pre = container.$pre ->
        res.span = @$span()
        @$br()
    res.textarea = container.$textarea().ready ->
        @_jquery.input =>
            res.span.text @_jquery.val()
        exports.addClass(container, 'active')
    container.end()
    return res


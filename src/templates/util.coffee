
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

adiff = require 'adiff'
{ isArray } = Array

# use an even simpler equals comparator for adiff
adiff = adiff({
    equal: (a, b) ->
        return no if a and not b
        return no if isArray(a) and a.length isnt b.length
        return a is b
}, adiff)


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

# sync backbone collection with dt-list on reset event
exports.sync = (items, collection, options, models = null) ->
    # now its gonna get dirty!
    bycid = {}
    removed = []
    old_models = []
    # rebuild old collection state
    for item in items
        bycid[item.opts.view.model.cid] = item
        old_models.push item.opts.view.model
    unless (l1 = old_models.length) is (l2 = (models ? collection.models).length)
        console.error "sync might fail because #{l1} != #{l2} (old,new)"
    # apply diff patches on items list
    for patch in adiff.diff(old_models, models ? collection.models)
        # remove all items from dom before splicing them in
        for i in [(patch[0]) ... (patch[0]+patch[1])]
            removed.push items[i].remove(soft:yes)
        # replace models with items
        for i in [2 ... patch.length]
            patch[i] = bycid[patch[i].cid]
        # apply patch!
        items.splice.apply(items, patch)
    # read all removed items - this only works in the assumption,
    #   that the collection doesn't change its size
    for item in removed
        @add(item)
    undefined

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


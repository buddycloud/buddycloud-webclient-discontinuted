unless process.title is 'browser'
    return module.exports =
        src: "streams.html"
        select: () ->
            @select ".sidebar",
                ".channel:not(.personal), .personal.channel > *, div.search > *"


{ Template } = require 'dynamictemplate'
{ List } = require 'dt-list'
design = require '../../_design/sidebar/index'
{ load_indicate, insert, sync } = require '../util'

module.exports = design (view) ->
    return new Template {schema:5, view}, ->
        @$div class:'sidebar', ->
            @$a id:'logout', ->
                @remove() if app.users.isAnonymous(app.users.current)
            if view.personal?
                # FIXME dt-linker listens only for new tags, not for added ones.
                @$div class:'personal channel', ->
                    @replace(view.personal.el)
            else
                @$div class:'personal channel', ->
                    return @remove() if app.users.isAnonymous(app.users.current)
                    view.bind('subview:personalchannel', @replace)
            # nav.actionBar
            @$div class:'search', ->
                @once('replace', load_indicate(this).clear)
                view.search.bind('template:create', @replace)
            scrollarea = @$div id:'channels', ->
                @ready ->
                    oldFilterResults = ""
                    view.search.on 'filter', (filterResults)=>
                        @_jquery.scrollTop(0) if oldFilterResults.length is 0
                        oldFilterResults = filterResults
                @$div -> # antiscroll
                    # channel ...
                    entries = new List

                    on_sort = (collection, options) =>
                        models = collection.filter (m) ->
                            not app.users.isPersonal(m)
                        sync.call(this, entries, collection, options, models)
                    # after sort
                    view.model.on('reset', on_sort)

                    # instead of view.model.on 'add' …
                    view.bind 'subview:entry', (i, el) =>
                        entries.insert(i, el)
                        idx = entries.keys[i]
                        el.on 'remove', (tag, opts) ->
                            unless opts.soft
                                entries.remove(idx.i)
#                                 setTimeout -> # damn sync jquery plugins
#                                     scrollarea._jquery?.antiscroll()
#                                 , 500
                        @add(el)
#                         setTimeout -> # damn sync jquery plugins
#                             scrollarea._jquery?.antiscroll()
#                         , 500

                    view.search.bind 'filter', (search) ->
                        if search is ""
                            for el in entries
                                el._jquery?.css(opacity:1.00)
                            return
                        channels = view.model.filter(search)
                        for el in entries
                            if (entry = view.views[el.opts.view.model.cid])?
                                if entry.model in channels
                                    el._jquery?.css(opacity:1.00)
                                else
                                    el._jquery?.css(opacity:0.42)

                    unless app.users.isAnonymous(app.users.current)
                        createTutorial this, {view, entries}

#                 setTimeout => # damn sync jquery plugins
#                     @_jquery.antiscroll()
#                     $(window).resize =>
#                         @_jquery.antiscroll()
#                 , 500

            @$button id: 'create_topic_channel', ->
                if app.users.isAnonymous(app.users.current) or
                  not config.topic_domain?
                    @remove()


tutorial_text =  ["start typing into the"
    "searchbar to filter your sidebar or"
    "enter a full user address (like"
    "name@domain) to navigate to its"
    "channel ..."].join " "

createTutorial = (tag, {view, entries}) ->
    tutorial = null
    timeout = null
    update_tutorial = ->
        timeout = null
        if view.model.length > 3
            if tutorial?
                entries.pop().remove()
                tutorial = null
            return
        return if tutorial?
        tutorial = tag.$div class:'channel tutorial', ->
            @$div class:'holder', ->
                @$span class:'arrow', "➽"
                @$span class:'info', tutorial_text
        entries.push tutorial

    throttled_update_tutorial = ->
        timeout ?= setTimeout(update_tutorial, 200)

    view.on('subview:entry',throttled_update_tutorial)
    view.model.on('remove', throttled_update_tutorial)

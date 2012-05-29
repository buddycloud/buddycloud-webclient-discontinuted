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
    return new Template schema:5, ->
        @$div class:'sidebar', ->
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
                @$div -> # antiscroll
                    # channel ...
                    last_search = ""
                    entries = new List

                    # instead of view.model.on 'add' …
                    view.bind 'subview:entry', (i, el) =>
                        entries.insert(i, el)
                        idx = entries.keys[i]
                        el.once 'remove', ->
                            entries.remove(idx.i)
                            setTimeout -> # damn sync jquery plugins
                                scrollarea._jquery?.antiscroll()
                            , 500
                        @add(el)
                        setTimeout -> # damn sync jquery plugins
                            scrollarea._jquery?.antiscroll()
                        , 500

                    # after sort
                    view.model.bind 'reset', (collection, options) =>
                        models = collection.filter (m) ->
                            not app.users.isPersonal(m)
                        sync.call(this, entries, collection, options, models)

                    view.search.bind 'filter', (search) ->
                        return if search is last_search
                        last_search = search
                        if search is ""
                            for el in entries
                                el._jquery?.css(opacity:1.00)
                            return
                        channels = view.model.filter(search)
                        for el in entries
                            if (entry = view.views[el.builder.template.cid])? # HACK
                                if entry.model in channels
                                    el._jquery?.css(opacity:1.00)
                                else
                                    el._jquery?.css(opacity:0.42)

                setTimeout => # damn sync jquery plugins
                    @_jquery.antiscroll()
                    $(window).resize =>
                        @_jquery.antiscroll()
                , 500

            @$button id: 'create_topic_channel', ->
                if app.users.isAnonymous(app.users.current) or
                  not config.topic_domain?
                    @remove()

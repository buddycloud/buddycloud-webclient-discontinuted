unless process.title is 'browser'
    return module.exports =
        src: "streams.html"
        select: () ->
            @select ".sidebar",
                ".channel:not(.personal), .personal.channel > *, div.search > *"


{ Template } = require 'dynamictemplate'
{ List } = require 'dt-list'
design = require '../../_design/sidebar/index'
{ load_indicate, insert } = require '../util'

module.exports = design (view) ->
    return new Template schema:5, ->
        @$div class:'sidebar', ->
            @$div class:'personal channel', ->
                @remove() if app.users.isAnonymous(app.users.current)
                #@text "loading personal channel …"
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

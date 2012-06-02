unless process.title is 'browser'
    return module.exports =
        src: "streams.html"
        select: () ->
            el = @select "article.topic:first section.opener" , "p *"
            el.find('time').attr(datetime:"", title:"")
            el.find('p, span, a, time').text("")
            return el


{ Template } = require 'dynamictemplate'
design = require '../../_design/channel/post'
{ load_indicate, addClass, removeClass } = require '../util'


module.exports = design (view) ->
    return new Template schema:5, ->
        @$section ->
            @attr class:"#{view.type}"
             view.on('read', removeClass.bind(this, "unread"))
            view.on('unread',  addClass.bind(this, "unread"))
            addClass(this, "unread") if view.model.get 'unread'
            avatar = @img class:'avatar'
            @$div class:'postmeta', ->
                time = @$time()
                update_time = ->
                    date = view.model.get('updated') or
                           view.model.get('published')
                    if date?
                        time.attr "data-date":date, datetime:date
                        time.ready -> @_jquery.formatdate(update:off)
                    if new Date(date ? 0).getTime() is 0
                        time.hide()
                    else
                        time.show()
                view.model.bind('change:updated',   update_time)
                view.model.bind('change:published', update_time)
                update_time()
                @$button class:'delete button', ->
                    return @remove() if app.users.isAnonymous(app.users.current)
            name = @span class:'name'

            update_author = ->
                author = app.users.get_or_create id:(view.model.get('author')?.jid)
                avatar.attr src:"#{author?.avatar or " "}"
                name.text(author?.get('name') or
                            author?.get('jid') or
                            "???")
            view.model.bind 'change:author', update_author
            do update_author
            # this saves us some jquery roundtrips when updating
            # the tags for the first time
            avatar.end()
            name.end()

            @$span class:'location', ->
                @remove() # FIXME not implemented yet :(
            @$p ->
                view.once('update:content', load_indicate(this).clear)
                view.bind('update:content', update_text.bind(this, view))


update_text = do ->
    # Don't load them twice:
    previews_rendered = {}
    return (view, parts) ->
        # Empty the <p/>
        @text("")

        text = ""
        flush_text = =>
            if text and text.length > 0
                @$span text
                text = ""
        for part in parts
            switch part.type
                when 'text'
                    text += part.value
                when 'link'
                    flush_text()

                    link = part.value
                    # Protocol part may be missing (short URLs like
                    # ur1.ca/8jz57). Make sure there's one or the browser will
                    # think it's a link to http://example.com/ur1.ca/8jz57.
                    full_link = link
                    unless link.match(/^[a-z0-9-]+:/)
                        full_link = 'http://' + link
                    @$a { href: full_link, target: "_blank"}, link
                    unless previews_rendered[full_link]
                        previews_rendered[full_link] = yes
                        render_preview.call(@up(end: no), view, full_link)
                when 'user'
                    flush_text()

                    userid = part.value
                    @$a
                        class: 'internal userlink'
                        href: "/#{userid}"
                        'data-userid': userid
                    , ->
                        @text userid
        flush_text()


render_preview = (view, url) ->
    view.load_url_preview url, (data) =>
        console.log "oembed", url, data
        if data.html? and (data.type is 'rich' or data.type is 'video')
            @$div ->
                @raw data.html
        else if data.type is 'photo' and data.url?
            @$img
                src: data.url
                style: "max-width: 100%"
        else if data.thumbnail_url
            @$img
                src: data.thumbnail_url
                style: "max-width: 100%"

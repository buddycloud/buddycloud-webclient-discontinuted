unless process.title is 'browser'
    return module.exports =
        src: "streams.html"
        select: () ->
            el = @select "article.topic:first section.opener" , "p *"
            el.find('p, span').text("")
            return el


{ Template } = require 'dynamictemplate'
jqueryify = require 'dt-jquery'
design = require '../../_design/channel/post'
{ load_indicate } = require '../util'





module.exports = design (view) ->
    return jqueryify new Template schema:5, ->
        @$section ->
            @attr class:"#{view.type}"
            avatar = @img class:'avatar'
            @$div class:'postmeta', ->
                time = @$span class:'time'
                update_time = ->
                    date = view.model.get('updated') or
                        view.model.get('published')
                    if date?
                        time.attr "data-date":date
                        time._jquery?.formatdate(update:off)
                view.model.bind 'change:updated', update_time
                view.model.bind 'change:published', update_time
                update_time()
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
                indicator = load_indicate this
                update_text = =>
                    # Empty the <p/>
                    # FIXME: @dodo is this clean?
                    @text("")

                    content = view.model.get('content')?.value
                    # Scan for links (RegExps don't work across multiple lines)
                    links = []
                    while content and content.length > 0
                        index = (s) ->
                            i = content.indexOf s
                            if i >= 0 then i else content.length
                        next_link = Math.min(
                            index("http://"),
                            index("https://")
                        )
                        @$span content.slice(0, next_link)

                        content = content.slice(next_link)
                        if (m = content.match(/^(\S+)/))
                            link = m[1]
                            links.push link
                            @$a href: link, ->
                                @text link
                            content = content.slice(link.length)

                    # FIXME: this <div> should be outside the <p>, but
                    # it'll be rendered asynchronously. we would need
                    # to notify...
                    # TODO: remove them on update
                    for link in links
                        render_preview.call(@up(end: no), view, link)
                    if indicator?
                        indicator?.clear()
                        delete indicator
                view.model.bind 'change:content', update_text
                update_text()


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

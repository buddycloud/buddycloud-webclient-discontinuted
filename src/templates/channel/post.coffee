unless process.title is 'browser'
    return module.exports =
        src: "streams.html"
        select: () ->
            el = @select "article.topic:first section.opener" , "p *"
            el.find('p, span').text("")
            return el


{ Template } = require 'dynamictemplate'
jqueryify = require 'dt-jquery'
formatdate = require 'formatdate'
design = require '../../_design/channel/post'


module.exports = design (view) ->
    return jqueryify new Template schema:5, ->
        @$section ->
            @attr class:"#{view.type}"
            avatar = @img class:'avatar'
            @$div class:'postmeta', ->
                @$span class:'time', ->
                    update_time = =>
                        # FIXME: single tick bug
                        setTimeout =>
                            @text view.model.get('updated') or view.model.get('published')
                            formatdate.hook(@_jquery, update: off) if @_jquery?
                        , 1
                    view.model.bind 'change:updated', update_time
                    view.model.bind 'change:published', update_time
                    update_time()
            name = @span class:'name'

            update_author = ->
                author = app.users.get_or_create id:(view.model.get('author')?.jid)
                console.log "update_author", author, view.model
                avatar.attr src:"#{author?.avatar or " "}"
                unless author?.get('name') or author?.get('jid')
                    console.warn "Questionable author", view.model.get('author'), view.model.attributes?.author, author, view.model
                # FIXME: single tick bug
                setTimeout ->
                    name.text(author?.get('name') or
                              author?.get('jid') or
                              "???")
                , 1
            view.model.bind 'change:author', update_author
            do update_author
            # this saves us some jquery roundtrips when updating
            # the tags for the first time
            avatar.end()
            name.end()

            @$span class:'location', ->
                @remove() # FIXME not implemented yet :(
            @$p ->
                update_text = =>
                    @text(view.model.get('content')?.value or "")
                    render_previews.apply(this)
                view.model.bind 'change:content', update_text
                update_text()


render_previews = ->
    urls = @text?().match /(http:\/\/[^\s]+)/g
    return unless urls?
    (urls ? []).forEach (url) =>
        div = @div()

        # TODO: make url configurable
        # TODO: filter HTML for XSS
        embedly_url = "http://api.embed.ly/1/oembed" +
            "?url=#{encodeURIComponent url}" +
            "&format=json" +
            "&maxwidth=400"
        # Set one for debugging embedly on localhost:
        if config.embedly_key
            embedly_url += "&key=#{config.embedly_key}"

        jQuery.ajax
            url: embedly_url
            dataType: 'json'

            error: (jqXHR, textStatus, errorThrown) =>
                app.error "embed error", textStatus, errorThrown
                div.end()

            success: (data) =>
                if data.html?
                    div.raw data.html

                else if data.type is 'photo' and data.url?
                    div.$img style:"max-width: 100%;", src:data.url

                div.end()
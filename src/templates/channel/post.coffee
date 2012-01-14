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
                    time.attr "data-date":date
                    time._jquery?.formatdate update:off
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
                update_text = =>
                    @text(view.model.get('content')?.value or "")
                    render_previews.call(this, view)
                view.model.bind 'change:content', update_text
                update_text()


render_previews =  (view) ->
    urls = @text?().match /(https?:\/\/[^\s]+)/g
    return unless urls?
    (urls ? []).forEach (url) =>
        div = @div()

    for url in urls
        do (url) =>
            view.load_url_preview url, (data) =>
                if data.html?
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

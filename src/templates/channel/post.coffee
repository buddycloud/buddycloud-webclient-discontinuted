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
        view.model.bind 'all', (a...) ->
            console.log "view model", view.model.get('id'), "a:", a...
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
                settext = =>
                    @text(view.model.get('content')?.value or "")
                view.model.bind 'change:content', settext
                do settext

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
                @$span class:'time', ->
                    # FIXME set formatdate stuff in streams.html
            name = @span class:'name'

            update_author = ->
                author = app.users.get_or_create id:(view.model.get('author')?.jid)
                avatar.attr src:"#{author?.avatar or " "}"
                name.text(author?.get('name') or
                          author?.get('jid') or
                          "???")
            view.model.bind 'change:author', update_author
            do update_author
            # this saves us some jquery roundtripes when updating
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

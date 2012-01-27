{ BaseView } = require '../base'
{ EventHandler } = require '../../util'

class exports.PostView extends BaseView
    template: require '../../templates/channel/post'

    initialize: ({@type}) ->
        super

        @model.bind 'change:content', @change_content
        @ready @change_content

    change_content: =>
        content = @model.get('content')?.value or ""
        parts = []
        for line in content.split(/\n/)
            i = 0
            while line.length > 0 and i < 30
                i++
                if (m = line.match(/^(.*?)(?:(https?\:\/\/\S+)|(\S+@[a-zA-Z0-9_\-\.]+))(.*)$/))
                    if m[1]
                        parts.push
                            type: 'text'
                            value: m[1]
                    if m[2]
                        parts.push
                            type: 'link'
                            value: m[2]
                    if m[3]
                        parts.push
                            type: 'user'
                            value: m[3]
                    line = m[4] or ""
                else
                    parts.push
                        type: 'text'
                        value: line
                    line = ""
            # Restore line break
            parts.push
                type: 'text'
                value: "\n"
        @trigger 'update:content', parts

    events:
        'click .name': 'clickAuthor'
        'click .avatar': 'clickAuthor'
        'click .userlink': 'clickUserlink'

    clickAuthor: EventHandler ->
        app.router.navigate @model.get('author')?.jid, true

    clickUserlink: EventHandler (ev) ->
        el = ev.srcElement
        userid = el and $(el).data('userid')
        if userid
            app.router.navigate userid, true

    # TODO: make url configurable
    # TODO: filter HTML for XSS
    load_url_preview: (url, callback) ->
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
                console.error "embed error", textStatus, errorThrown
            success: callback


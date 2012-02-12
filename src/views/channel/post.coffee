{ BaseView } = require '../base'
{ EventHandler } = require '../../util'

class exports.PostView extends BaseView
    template: require '../../templates/channel/post'

    initialize: ({@type}) ->
        super

        @model.bind 'change:content', @change_content
        @ready @change_content

    ##
    # TODO
    #
    # Actually, posts should have embedded static links in XHTML in
    # the ATOM entries. Scanning for them when displaying is just the
    # short preliminary way for now.
    change_content: =>
        content = @model.get('content')?.value or ""
        parts = []
        for line in content.split(/\n/)
            while line.length > 0
                re = ///^
                     (.*?)                       # Beginning of text
                     (?:
                       # Crazy regexp for matching URLs. Based on http://daringfireball.net/2010/07/improved_regex_for_matching_urls + changed some '(' to '(?:'.
                       \b((?:[a-z][\w-]+:(?:/{1,3}|[a-z0-9%])|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}/)(?:[^\s()<>]+|\((?:[^\s()<>]+|(?:\([^\s()<>]+\)))*\))+(?:\((?:[^\s()<>]+|(?:\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'".,<>?«»“”‘’]))
                       #' <-- fix syntax highlighting...
                       |
                       \b(\S+@[a-zA-Z0-9_\-\.]+)\b # JID (or e-mail address not starting with mailto:)
                     )
                     (.*)                        # End of text
                     $///
                if (m = line.match(re, "i"))
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

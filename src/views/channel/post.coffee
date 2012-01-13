formatdate = require 'formatdate'
{ BaseView } = require '../base'
{ EventHandler } = require '../../util'

class exports.PostView extends BaseView
    template: require '../../templates/channel/post'

    initialize: ({@type}) ->
        super

    events:
        'click .name': 'clickAuthor'
        'click .avatar': 'clickAuthor'

    clickAuthor: EventHandler ->
        app.router.navigate @model.get('author')?.jid, true

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


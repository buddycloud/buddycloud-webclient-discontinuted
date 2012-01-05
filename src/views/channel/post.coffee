formatdate = require 'formatdate'
{ BaseView } = require '../base'
{ EventHandler, throttle_callback } = require '../../util'

class exports.PostView extends BaseView
    template: require '../../templates/channel/post.eco'

    initialize: ({@parent, @type}) =>
        super
        @model.bind 'change', throttle_callback(50, @render)
        @previews = {}

    render: =>
        @post = @model.toJSON() # data
        @author = @model.author # model
        super
        @$('.name').attr href: @author?.get('jid') or "?"
        formatdate.hook @el, update: off
        @render_previews()

    events:
        'click .name': 'clickAuthor'
        'click .avatar': 'clickAuthor'

    clickAuthor: EventHandler ->
        app.router.navigate @author.get('jid'), true

    render_previews: ->
        urls = @model.get('content')?.value?.match /(http:\/\/[^\s]+)/g
        return unless urls?

        for url in urls
            # is new?
            unless urls.hasOwnProperty url
                div = $('<div></div>')
                urls[url] = div
                @load_url_preview url, div
            else
                console.log "reuse", div
            # render
            @el.append urls[url]

    # TODO: make url configurable
    load_url_preview: (url, container) ->
        embedly_url = "http://api.embed.ly/1/oembed" +
            "?url=#{encodeURIComponent url}" +
            "&format=json" +
            "&maxwidth=400"
        # Set one for debugging embedly on localhost:
        embedly_key = ""
        if embedly_key
            embedly_url += "&key=#{embedly_key}"
        jQuery.ajax
            url: embedly_url
            dataType: 'json'
            error: (jqXHR, textStatus, errorThrown) =>
                console.error "embed error", textStatus, errorThrown
            success: (data) =>
                console.warn "embed", url, data
                if data.html?
                    # TODO: filter HTML for security!
                    container.html data.html
                else if data.type is 'photo' and data.url?
                    img = $('<img style="max-width: 100%;">')
                    img.attr 'src', data.url
                    container.append img


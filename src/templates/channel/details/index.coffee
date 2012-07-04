unless process.title is 'browser'
    return module.exports =
        src: "streams.html"
        select: () ->
            el = @select ".channelDetails:first", ".location, .channelList"
            el.find('time').attr(datetime:"", title:"")
            el.find('.data, time').text("")
            el


{ Template } = require 'dynamictemplate'
formatdate = require 'formatdate'
{ throttle_callback } = require '../../../util'
design = require '../../../_design/channel/details/index'


module.exports = design (view) ->
    return new Template {schema:5}, ->
        postsnode = view.model.nodes.get_or_create(id: 'posts')
        metadata = postsnode.metadata

        @$div class: 'channelDetails', ->
            @$div class: 'holder', ->
                @$section class: 'meta', ->
                    make_field = (pClass, tagname = 'span') =>
                        p = @p class: pClass
                        span = p["$#{tagname}"] class: 'data'
                        p.end()
                        span

                    description = make_field 'description'
                    accessModel = make_field 'open'
                    creationDate = make_field 'broadcast', 'time'
                    formatdate.update creationDate

                    update_metadata = =>
                        description.text metadata.get('description')?.value
                        if metadata.get('access_model')?.value is 'open'
                            accessModel.text "open"
                        else
                            accessModel.text "private"
                        date = metadata.get('creation_date')?.value
                        if date?
                            creationDate.attr "data-date":date, datetime:date
                        if new Date(date ? 0).getTime() is 0
                            creationDate.hide()
                        else
                            creationDate.show()
                    # Filtering for owners takes potentially long, and
                    # we bind to every affiliation update.
                    update_metadata_callback = throttle_callback 400, update_metadata
                    view.metadata.bind 'change', update_metadata_callback
                    postsnode.bind 'affiliation:update', update_metadata_callback
                    update_metadata()

                for role in ['owners', 'moderators', 'publishers', 'followers']
                    view[role].bind('template:create', @add)

                view.following.bind 'template:create', (el) =>
                    @add el

                    update_visibility = ->
                        # FIXME: uses the jQuery `el'. the `@add()'
                        # result didn't work.
                        if metadata.get('channel_type')?.value is 'topic'
                            # Topic channels don't follow anyone
                            el.hide()
                        else
                            el.show()
                    metadata.bind 'change', update_visibility
                    update_visibility()
                view.banned.bind 'template:create', (el) =>
                    @add el

                    update_visibility = ->
                        # FIXME: uses the jQuery `el'. the `@add()'
                        # result didn't work.
                        if app.users.current.canModerate view.model
                            # Only owners and moderators can see banned users
                            el.show()
                        else
                            el.hide()
                    postsnode.affiliations.bind 'change', update_visibility
                    update_visibility()
                view.similar.bind('template:create', @add)

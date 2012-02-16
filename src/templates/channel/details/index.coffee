unless process.title is 'browser'
    return module.exports =
        src: "streams.html"
        select: () ->
            el = @select ".channelDetails:first", ".location, .channelList"
            el.find('.data, .time').text("")
            el


{ Template } = require 'dynamictemplate'
jqueryify = require 'dt-jquery'
design = require '../../../_design/channel/details/index'


module.exports = design (view) ->
    return jqueryify new Template schema:5, ->
        @$div class: 'channelDetails', ->
            @$div class: 'holder', ->
                @$section class: 'meta', ->
                    make_field = (pClass) =>
                        p = @p class: pClass
                        span = p.$span class: 'data'
                        p.end()
                        span

                    owner = make_field 'owner'
                    description = make_field 'description'
                    accessModel = make_field 'open'
                    creationDate = make_field 'broadcast'

                    update_metadata = =>
                        console.warn "update_metadata", view.metadata
                        owner.text view.model.get('id')
                        metadata = view.metadata.toJSON()
                        description.text metadata.description?.value
                        if metadata.access_model?.value is 'open'
                            accessModel.text "open"
                        else
                            accessModel.text "private"
                        date = metadata.creation_date?.value
                        if date?
                            creationDate.attr "data-date":date
                            creationDate._jquery?.formatdate(update:off)
                    view.metadata.bind 'change', update_metadata
                    update_metadata()

                view.bind 'subview:followers', @add
                view.bind 'subview:following', (el) =>
                    @add el

                    metadata = view.model.nodes.get_or_create(id: 'posts').metadata
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

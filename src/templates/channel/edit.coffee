unless process.title is 'browser'
    return module.exports =
        src: "streams.html"
        select: () ->
            # FIXME: hide .dangerZone, delete channel will be implemented later
            @select "#editbar", ".dangerZone"


{ Template } = require 'dynamictemplate'
design = require '../../_design/channel/edit'

module.exports = design (view) ->
    return new Template schema:5, ->
        @$div id: 'editbar', ->
            @$div class: 'edits', ->
                @$div class: 'contenteditable', ->
                    @$input id: 'allowPost', ->
                        metadata = view.model.
                            nodes.get_or_create(id: 'posts').metadata
                        set_value = =>
                            default_affiliation = metadata.get('default_affiliation')?.value
                            if default_affiliation is 'publisher'
                                @attr 'checked', 'checked'
                            else
                                @removeAttr 'checked'
                        metadata.bind 'change', set_value
                        set_value()
                @$nav class: 'clearfix', ->
                    @$span class: 'spinner', ->
                        view.bind('loading:stop',  @hide)
                        view.bind('loading:start', @show)

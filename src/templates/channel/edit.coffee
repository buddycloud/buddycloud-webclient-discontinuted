unless process.title is 'browser'
    return module.exports =
        src: "streams.html"
        select: () ->
            # FIXME: hide .dangerZone, delete channel will be implemented later
            @select "#editbar", ".dangerZone"


{ Template } = require 'dynamictemplate'
jqueryify = require 'dt-jquery'
design = require '../../_design/channel/edit'

module.exports = design (view) ->
    return jqueryify new Template schema:5, ->
        @$div id: 'editbar', ->
            @$div class: 'edits', ->
                @$nav class: 'clearfix', ->
                    @$span class: 'spinner', ->
                        view.bind('loading:stop',  @hide)
                        view.bind('loading:start', @show)

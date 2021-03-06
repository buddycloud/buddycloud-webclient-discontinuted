unless process.title is 'browser'
    return module.exports =
        src: "discover.html"
        select: () ->
            @select ".content", ".discoverChannels > *"


{ Template } = require 'dynamictemplate'
design = require '../../_design/discover/index'
{ addClass } = require '../util'

module.exports = design (view) ->
    return new Template schema:5, ->
        @$div class:'content', ->
            addClass(@,"disco")
            @$div class:'discoverChannels', ->
                view.on("subview:group", @add)

        view.on('show', @show)
        view.on('hide', @hide)

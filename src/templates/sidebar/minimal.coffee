unless process.title is 'browser'
    return module.exports =
        src: "streams.html"
        select: () ->
            el = @select ".sidebar"
            el.children().not('nav.actionBar').remove()
            return el


{ Template } = require 'dynamictemplate'
design = require '../../_design/sidebar/minimal'
{ load_indicate, addClass } = require '../util'

module.exports = design (view) ->
    return new Template schema:5, ->
        @$div class:'sidebar', ->
            addClass(@,"minimal")
            # nav.actionBar
            @$div class:'search', ->
                @once('replace', load_indicate(this).clear)
                view.search.bind('template:create', @replace)

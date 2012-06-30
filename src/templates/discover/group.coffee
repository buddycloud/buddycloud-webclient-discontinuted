unless process.title is 'browser'
    return module.exports =
        src: "discover.html"
        select: () ->
            el = @select ".local", ".span-1"
            el.removeClass "local"
            el.find('h1').text("")
            return el


{ Template } = require 'dynamictemplate'
design = require '../../_design/discover/group'
{ addClass } = require '../util'

module.exports = design (view) ->
    return new Template {schema:5, view}, ->
        @$div ->
            addClass(@,"#{view.id}")
            @$h1 ->
                @text view.name
            view.bind("subview:list", @add)


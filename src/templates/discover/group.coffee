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

module.exports = design (view) ->
    return new Template {view:view,schema:5}, ->
        @$div ->
            @attr 'class', "#{view.id} "+@attr('class')
            @$h1 ->
                @text view.name
            view.bind("subview:list", @add)


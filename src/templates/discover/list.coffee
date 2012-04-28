unless process.title is 'browser'
    return module.exports =
        src: "discover.html"
        select: () ->
            el = @select ".local .mostActive", ".channel"
            el.removeClass "mostActive"
            el.find('h2').text("")
            return el


{ Template } = require 'dynamictemplate'
{ List } = require 'dt-list'
design = require '../../_design/discover/list'
{ insert } = require '../util'

module.exports = design (view) ->
    return new Template schema:5, ->
        @$div ->
            @attr 'class', "#{view.id} "+@attr('class')
            @$h2 ->
                @text view.name
            @$div class:'list', ->
                view.bind("subview:entry", insert.bind(this, new List))


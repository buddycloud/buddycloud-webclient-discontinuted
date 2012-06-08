unless process.title is 'browser'
    return module.exports =
        src: "streams.html"
        select: () ->
            @select ".sidebar div.search"


{ Template } = require 'dynamictemplate'
design = require '../../_design/sidebar/search'

module.exports = design (view) ->
    return new Template {userdata:view,schema:5}, ->
        @$div class:'search', ->
            @$input(type:'search').ready ->
                # a little bit ugly i guess
                @_jquery.input(view.on_input.bind(view, this))



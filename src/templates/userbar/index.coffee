unless process.title is 'browser'
    return module.exports =
        src: "streams.html"
        select: () ->
            @select ".userbar"

{ Template } = require 'dynamictemplate'
design = require '../../_design/userbar/index'

rm = -> @remove() if config.registration is off

module.exports = design (view) ->
    return new Template schema:5, ->
        @$div class:'userbar', ->
            @$nav ->
                @$div -> # .getin
                    @$span()   # Login
                    @$span(rm) # or
                    @$span(rm) # Register



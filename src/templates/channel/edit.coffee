unless process.title is 'browser'
    return module.exports =
        src: "streams.html"
        select: () ->
            @select "#editbar"


{ Template } = require 'dynamictemplate'
jqueryify = require 'dt-jquery'
design = require '../../_design/channel/edit'

module.exports = design (view) ->
    return jqueryify new Template schema:5, ->
        @$div id:'editbar', ->

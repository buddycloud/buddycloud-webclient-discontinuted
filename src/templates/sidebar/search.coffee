unless process.title is 'browser'
    return module.exports =
        src: "streams.html"
        select: () ->
            @select "#sidebar div.search"


{ Template } = require 'dynamictemplate'
jqueryify = require 'dt-jquery'
design = require '../../_design/sidebar/search'

module.exports = design (view) ->
    return jqueryify new Template schema:5, ->
        @$div class:'search', ->
            @$input type:'search'



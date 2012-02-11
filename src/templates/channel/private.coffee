unless process.title is 'browser'
    return module.exports =
        src: "private.html"
        select: () ->
            @select "article.ghost.topic"


{ Template } = require 'dynamictemplate'
jqueryify = require 'dt-jquery'
design = require '../../_design/channel/private'

module.exports = design (view) ->
    return jqueryify new Template schema:5, ->
        @$article class:'ghost topic'

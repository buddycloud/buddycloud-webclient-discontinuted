unless process.title is 'browser'
    return module.exports =
        src: "private.html"
        select: () ->
            @select "article.ghost.topic, .private.notification"


{ Template } = require 'dynamictemplate'
design = require '../../_design/channel/private'

module.exports = design (view) ->
    return new Template {view:view,schema:5}, ->
        @$article class:'ghost topic'

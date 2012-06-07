unless process.title is 'browser'
    return module.exports =
        src: "streams.html"
        select: () ->
            @select "article.topic:eq(0)", "section > *"


{ Template } = require 'dynamictemplate'
design = require '../../_design/channel/topicpost'


module.exports = design (view) ->
    return new Template {schema:5, view}, ->
        @$article class:'topic', ->
            @$section class:'opener', ->
                view.opener.bind('template:create', @replace)
            @$section class:'comments', ->
                view.comments.bind('template:create', @replace)

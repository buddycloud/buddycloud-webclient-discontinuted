unless process.title is 'browser'
    return module.exports =
        src: "streams.html"
        select: () ->
            @select "article.topic:eq(0)", "section > *"


{ Template } = require 'dynamictemplate'
design = require '../../_design/channel/topicpost'
{ ready } = require '../util'


module.exports = design (view) ->
    return new Template schema:5, ->
        @$article class:'topic', ->
            @$section class:'opener', ->
                view.bind('subview:opener', @replace)
            @$section class:'comments', ->
                view.bind('subview:comments', @replace)

            ready this, view
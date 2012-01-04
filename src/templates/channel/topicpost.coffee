unless process.title is 'browser'
    return module.exports =
        src: "streams.html"
        select: () ->
            @select "article.topic:eq(0)", "section > *"


{ Template } = require 'dynamictemplate'
jqueryify = require 'dt-jquery'
design = require '../../_design/channel/topicpost'


module.exports = design (view) ->
    return jqueryify new Template schema:5, ->
        @$article class:'topic', ->
            @$section class:'opener', ->
                view.bind 'subview:opener', (tag) =>
                    @_jquery?.replaceWith(tag._jquery ? tag)
            @$section class:'comments', ->
                view.bind 'subview:comments', (tag) =>
                    @_jquery?.replaceWith(tag._jquery ? tag)

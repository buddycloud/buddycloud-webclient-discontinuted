unless process.title is 'browser'
    return module.exports =
        src: "streams.html"
        select: () ->
            @select "section.topics", "article.topic"


{ Template } = require 'dynamictemplate'
design = require '../../_design/channel/posts'

module.exports = design (view) ->
    return new Template schema:5, ->
        @$section class:'topics'#, ->
#             view.bind 'view:topic', (tag) =>
#                 @_jquery?.append(tag._jquery ? tag)
unless process.title is 'browser'
    return module.exports =
        src: "streams.html"
        select: () ->
            @select "section.topics", "article.topic"


{ Template } = require 'dynamictemplate'
jqueryify = require 'dt-jquery'
design = require '../../_design/channel/posts'
{ List } = require '../util'

module.exports = design (view) ->
    return jqueryify new Template schema:5, ->
        list = new List @$section class:'topics'
        list.bind(view, 'view:topic')

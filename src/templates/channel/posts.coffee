unless process.title is 'browser'
    return module.exports =
        src: "streams.html"
        select: () ->
            @select "section.topics", "article.topic"


{ Template } = require 'dynamictemplate'
{ List } = require 'dt-list'
design = require '../../_design/channel/posts'
{ insert } = require '../util'

module.exports = design (view) ->
    return new Template {view:view,schema:5}, ->
        @$section class:'topics', ->
            list = new List
            view.bind('view:topic', insert.bind(this, list))
            view.bind 'view:topic:remove', (i) ->
                list.remove(i).remove(soft:true)


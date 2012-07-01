unless process.title is 'browser'
    return module.exports =
        src: "streams.html"
        select: () ->
            @select "section.topics", "article.topic"


{ Template } = require 'dynamictemplate'
{ List } = require 'dt-list'
design = require '../../_design/channel/posts'
{ insert, sync } = require '../util'

module.exports = design (view) ->
    return new Template {schema:5}, ->
        @$section class:'topics', ->
            items = new List
            view.on('view:topic', insert.bind(this, items))
            view.model.on('reset',  sync.bind(this, items))
            view.model.on 'remove', (entry, collection, options) ->
                items.remove(options.index)?.remove()


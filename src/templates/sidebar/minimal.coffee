{ Template } = require 'dynamictemplate'
{ load_indicate } = require '../util'

module.exports = (view) ->
    return new Template schema:5, ->
        @$div class:'minimal sidebar', ->
            @$div class:'search', ->
                @once('replace', load_indicate(this).clear)
                view.search.bind('template:create', @replace)

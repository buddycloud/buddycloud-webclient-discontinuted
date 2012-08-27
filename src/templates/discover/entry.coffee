unless process.title is 'browser'
    return module.exports =
        src: "discover.html"
        select: () ->
            el = @select ".discoverChannels .list .channel:first"
            el.find('span').text("")
            el.find('.avatar').removeAttr('style')
            return el


{ Template } = require 'dynamictemplate'
design = require '../../_design/discover/entry'

module.exports = design (view) ->
    return new Template schema:5, ->
        @$div ->
            @$div class:'avatar', ->
                @attr 'style':"background-image:url(#{view.model.avatar}),url(/public/avatars/anon.png)"
            @$div class:'info', ->
                @$span class:'owner', ->
                    @text view.model.get('id') # FIXME
                status = @$span class:'status'
                update_status = ->
                    status.text view.status ? ""
                view.bind 'status', update_status
                update_status()


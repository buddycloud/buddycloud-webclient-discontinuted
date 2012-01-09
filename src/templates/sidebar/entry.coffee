unless process.title is 'browser'
    return module.exports =
        src: "streams.html"
        select: () ->
            el = @select '.channel:not(.personal):first'
            el.find('.avatar').removeAttr('style')
            el.find('span').text("")
            return el


{ Template } = require 'dynamictemplate'
jqueryify = require 'dt-jquery'
design = require '../../_design/sidebar/entry'

module.exports = design (view) ->
    return jqueryify new Template schema:5, ->
        channel = view.model
        @$div class:'channel', ->
            view.bind 'update:highlight', =>
                $ = @_jquery

                if view.isPersonal()
                    $.addClass('personal')
                else
                    $.removeClass('personal')

                if view.isSelected()
                    $.addClass('selected')
                else
                    $.removeClass('selected')

            avatar = @div class:'avatar', ->
                @$span class:'counter', (do channel.count_unread) # channelpost class should autofill
            @$div class:'info', ->
                owner = @span class:'owner'
                domain = owner.span class:'domain'
                @$span class:'status', (channel.nodes.get('status')?.last() or "")

                update = ->
                    avatar.attr style:"background-image:url(#{channel.avatar})"

                    jid = channel.get('id')?.split('@') or []
                    owner.text   "#{jid[0]}"
                    domain.text "@#{jid[1]}"

                channel.bind('change', update)
                do update

                avatar.end()
                domain.end()
                owner.end()


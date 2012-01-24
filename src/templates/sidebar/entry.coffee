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
                unread_counter = @$span class:'counter'
                update_unread = ->
                    unread = channel.count_unread()
                    unread_counter.text "#{unread}"
                    if unread > 0
                        unread_counter.show()
                    else
                        unread_counter.hide()

                view.bind 'update:unread_counter', update_unread
                do update_unread

            @$div class:'info', ->
                owner = @span class:'owner'
                username = owner.span()
                domain = owner.span class:'domain'

                update = ->
                    avatar.attr style:"background-image:url(#{channel.avatar})"

                    jid = channel.get('id')?.split('@') or []
                    username.text   "#{jid[0]}"
                    domain.text "@#{jid[1]}"

                channel.bind('change', update)
                do update

                avatar.end()
                username.end()
                domain.end()
                owner.end()

                status = @$span class:'status'
                update_status = (text) ->
                    status.text if text then "#{text}" else ""
                view.bind 'update:status', update_status
                update_status()


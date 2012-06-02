unless process.title is 'browser'
    return module.exports =
        src: "streams.html"
        select: () ->
            el = @select '.channel:not(.personal):first'
            el.find('.avatar').removeAttr('style')
            el.find('span').text("")
            el.removeClass 'selected'
            return el


{ Template } = require 'dynamictemplate'
design = require '../../_design/sidebar/entry'
{ addClass, removeClass } = require '../util'

module.exports = design (view) ->
    return new Template schema:5, ->
        view.bind('remove', @remove)
        channel = view.model
        @$div class:'channel', ->
            view.bind 'update:highlight', =>
                if app.users.isPersonal(channel)
                    addClass(@,"personal")
                else
                    removeClass(@,"personal")

                if view.isSelected()
                    addClass(@,"selected")
                else
                    removeClass(@,"selected")

            avatar = @div class:'avatar', ->
                unread_counter = @$span class:'channelpost counter'
                update_unread = ->
                    unread = channel.unread_count
                    unread_counter.text "#{unread}"
                    if unread > 0
                        unread_counter.show()
                    else
                        unread_counter.hide()

                view.bind 'update:unread_counter', update_unread
                update_unread()

                notification_counter = @$span class:'admin counter'
                update_notification = ->
                    count = channel.count_notifications()
                    notification_counter.text "#{count}"
                    if count > 0
                        notification_counter.show()
                    else
                        notification_counter.hide()
                view.bind 'update:notification_counter', update_notification
                update_notification()

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
                    status.text text ? ""
                    status.attr title:(text ? "")
                view.bind 'update:status', update_status
                update_status()


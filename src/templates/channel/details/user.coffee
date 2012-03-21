unless process.title is 'browser'
    return module.exports =
        src: "streams.html"
        select: () ->
            el = @select "section.channelList .adminAction"
            el.find('.channelInfo, .currentRole').text ""
            el.removeClass('moderator')
            # FIXME everywhere: "chosen"?
            el.removeClass('choosen')
            el.removeClass('role')
            el


{ Template } = require 'dynamictemplate'
design = require '../../../_design/channel/details/user'
{ EventHandler, throttle_callback } = require '../../../util'

userspeak =
    'owner':    "Producer"
    'moderator':"Moderator"
    'publisher':"Follower+Post"
    'member':   "Follower"
    'outcast':  "Banned"
    'none':     "Does not follow back"

affiliations_infos =
    moderator: [
        "approve new followers"
        "delete posts"
        "read your channel"
        "write comments & messages"
        "post new topics"
    ]
    publisher: [
        "read your channel"
        "write comments & messages"
        "post new topics"
    ]
    member: [
        "read your channel"
    ]

module.exports = design (view) ->
    return new Template schema:5, ->
        channel = view.parent.parent.model
        set_info_lines = ->
        @$div class:'adminAction', ->
            add_class = (c) =>
                classes = @attr('class').
                    split(/\s+/).
                    filter((cl) -> cl isnt c)
                classes.push c
                @attr 'class', classes.join(" ")
            rm_class = (c) =>
                @attr 'class', @attr('class').
                    split(/\s+/).
                    filter((cl) -> cl isnt c).
                    join(" ")

            isOwner = no
            update_visibility = =>
                if app.users.current.canEdit(channel) and
                   not isOwner
                    console.warn "update_visibility :-)"
                    add_class 'moderator'
                else
                    console.warn "update_visibility :-("
                    rm_class 'moderator'
            view.parent.parent.parent.bind 'update:permissions', update_visibility
            view.bind 'user:update', (user) =>
                userid = user?.get('id')
                isOwner = userid and app.users.get(userid).getAffiliationFor(channel) is 'owner'
                console.warn "isOwner", userid, isOwner
                update_visibility()
            update_visibility()

            view.bind 'click:changeRole', ->
                add_class 'choosen'
                add_class 'role'
            view.bind 'click:banUser', ->
                add_class 'choosen'
                add_class 'ban'
            view.bind 'user:update', ->
                rm_class 'choosen'
                rm_class 'role'
                rm_class 'ban'

            # .arrow
            @$div class:'holder', ->
                @$div class:'box', ->
                    @$section class:'channelInfo', ->
                        name = @$h4()
                        role = @$div class:'currentRole'
                        view.bind 'user:update', (user) ->
                            name.text "#{user.get 'id'}"
                            affiliation = user.getAffiliationFor channel.get 'id'
                            role?.text "#{userspeak[affiliation] or affiliation}"
                        update_role = =>
                            if app.users.current.canEdit channel
                                role.show()
                            else
                                role.hide()
                        view.parent.parent.parent.bind 'update:permissions', update_role
                        update_role()

                    @$section class:'action changeRole', ->
                        @$select ->
                            @$option value: 'moderator', ->
                                @remove()
                            @$option value: 'followerPlus', ->
                                @remove()
                            @$option value: 'follower', ->
                                @remove()

                            options = {}
                            for own value, info of affiliations_infos
                                postsnode = view.parent.parent.model.nodes.get_or_create(id: 'posts')
                                unless value is 'none'
                                    @$option {value}, ->
                                        @text userspeak[value]
                                        options[value] = this
                            current_user = null
                            set_current_option = =>
                                affiliation = postsnode.affiliations.get(current_user)?.get('affiliation')
                                console.warn "set_current_option", current_user, affiliation
                                # FIXME: Preselecting the current <option/> doesn't work like this :-(
                                @attr 'value', affiliation
                                set_info_lines(affiliations_infos[affiliation] or [])
                            set_current_option_callback = throttle_callback 100, set_current_option
                            view.bind 'user:update', (user) ->
                                current_user = user
                                set_current_option_callback()
                            view.parent.parent.parent.bind 'update:affiliations', set_current_option_callback
                            set_current_option()

                            view.bind 'update:select:affiliation', =>
                                # FIXME: couldn't we use dt like
                                # above, just in a way that actually
                                # works?
                                set_info_lines(affiliations_infos[@attr('value')] or [])

                        @$section class: 'info', ->
                            @$div class: 'moderator', ->
                                @remove()

                            @$div class: 'moderator', ->
                                @$ul ->
                                    old_lines = []
                                    set_info_lines = (lines) =>
                                        for old_line in old_lines
                                            old_line.remove()
                                        old_lines = []
                                        for line in lines
                                            old_lines.push @$li ->
                                                @text line

                    @$section class: 'action banUser', ->

                    @$section class: 'actionRow choose', ->
                        @$div ->
                            @attr class: 'changeRoleButton'
                        @$div ->
                            @attr class: 'banUserButton'

                    @$section class: 'actionRow confirm', ->
                        @$div ->
                            @attr class: 'cancelButton'
                        @$div ->
                            @attr class: 'okButton'


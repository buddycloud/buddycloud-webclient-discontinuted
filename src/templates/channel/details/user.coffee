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
jqueryify = require 'dt-jquery'
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
    owner: [
        "read your channel"
        "write comments & messages"
        "post new topics"
        "add & ban users"
        "set user's roles"
    ]
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
        "write comments & messages if publish_model matches"
    ]
    outcast: [
        "forbidden to read your channel"
    ]
    none: [
        "read your open channel"
    ]

module.exports = design (view) ->
    return jqueryify new Template schema:5, ->
        channel = view.parent.parent.model
        set_info_lines = ->
        @$div class:'adminAction', ->
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
                            for own value, text of userspeak
                                postsnode = view.parent.parent.model.nodes.get_or_create(id: 'posts')
                                unless value is 'none'
                                    @$option {value}, ->
                                        @text text
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
                        @remove()
                    @$section class: 'actionRow choose', ->
                        @remove()

                    @$section class: 'actionRow confirm', ->
                        @$div ->
                            @attr class: 'cancelButton'
                        @$div ->
                            @attr class: 'okButton'

            update_role = =>
                classes = @attr('class').split(/\s+/)
                console.warn "update_role", view, app.users.current.canEdit channel
                if app.users.current.canEdit channel
                    modClass = (class_) ->
                        if classes.indexOf(class_) < 0
                            classes.push class_
                else
                    modClass = (class_) ->
                        classes = classes.filter (class__) ->
                            class_ isnt class__
                modClass 'moderator'
                modClass 'choosen'
                modClass 'role'
                @attr 'class', classes.join(" ")
            view.parent.parent.parent.bind 'update:permissions', update_role
            update_role()

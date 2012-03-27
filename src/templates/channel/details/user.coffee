unless process.title is 'browser'
    return module.exports =
        src: "streams.html"
        select: () ->
            el = @select "section.channelList .adminAction"
            el.find('.channelInfo, .currentRole').text ""
            el.find('[selected]').removeAttr 'selected'
            el.removeClass(c) for c in [
                'moderator'
                'choosen'
                'first'
                'second'
                'third'
                'fourth'
            ]
            return el


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

class_map =
    'owner':    "moderator"
    'moderator':"moderator"
    'publisher':"followerPlus"
    'member':   "follower"
    'outcast':  "none"
    'none':     "none"

affiliations_map =
    'moderator': 'moderator'
    'publisher': 'followerPlus'
    'member':    'follower'
reversed_affiliations_map = {}
reversed_affiliations_map[v] = k for k,v of affiliations_map

module.exports = design (view) ->
    return new Template schema:5, ->
        channel = view.parent.parent.model
        @$div class:'adminAction', ->
            add_class = (c) =>
                classes = @attr('class')
                    .split(/\s+/)
                    .filter((cl) -> cl isnt c)
                classes.push c
                @attr 'class', classes.join(" ")
            rm_class = (c) =>
                @attr 'class', @attr('class')
                    .split(/\s+/)
                    .filter((cl) -> cl isnt c)
                    .join(" ")

            lastclass = ''
            update_visibility = ->
                affiliation = app.users.current.getAffiliationFor(channel)
                rm_class lastclass
                lastclass = class_map[affiliation]
                add_class lastclass
            view.bind('user:update', update_visibility)
            view.parent.parent.parent.bind('update:permissions', update_visibility)

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

                    @$section class:'action changeRole', ->
                        infos = {}
                        options = {}
                        selected = 'moderator'
                        @$select ->
                            for role, value of affiliations_map
                                options[role] = @$option {value}
                            view.bind 'update:select:affiliation', =>
                                role = reversed_affiliations_map[@attr 'value']
                                infos[selected]?.hide()
                                infos[role]?.show()
                                selected = role

                        @$section class:'info', ->
                            for role, cls of affiliations_map
                                infos[role] = @$div class:cls

                        postsnode = channel.nodes.get_or_create(id:'posts')
                        # change selected
                        set_current_option = (user) ->
                            role = postsnode.affiliations
                                .get(user)?.get('affiliation')
                            options[selected]?.removeAttr('selected')
                            options[role]?.attr(selected: 'selected')
                            infos[selected]?.hide()
                            infos[role]?.show()
                            selected = role
                            # FIXME set info
                        view.bind('user:update', set_current_option)
                        view.parent.parent.parent
                            .bind('update:affiliations', set_current_option)



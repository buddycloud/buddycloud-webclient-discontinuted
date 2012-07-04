arrowpos = ['first', 'second', 'third', 'fourth']

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
            ].concat arrowpos
            return el


{ Template } = require 'dynamictemplate'
{ List } = require 'dt-list'
design = require '../../../_design/channel/details/user'
{ addClass, removeClass, insert } = require '../../util'
{ userspeak, class_map, affiliations_map, reversed_affiliations_map } =
    require '../../../controllers/affiliation'

module.exports = design (view) ->
    return new Template {schema:5}, ->
        channel = view.parent.parent.model
        @$div class:'adminAction', ->
            lastclass = ''
            update_visibility = =>
                affiliation = app.users.current.getAffiliationFor(channel)
                removeClass(@,lastclass)
                lastclass = class_map[affiliation]
                addClass(@,lastclass)
            view.bind('update:select:user', update_visibility)
            view.bind('update:permissions', update_visibility)
            update_visibility()

            view.bind 'click:changeRole', =>
                addClass(@,'choosen', 'role')
            view.bind 'click:banUser', =>
                addClass(@,'choosen', 'ban')
            view.bind 'update:select:user', =>
                removeClass(@,'choosen', 'role', 'ban')

            removeClass(@,arrowpos...)
            addClass(@,arrowpos[view.arrow]) if view.arrow
            view.bind 'update:select:arrow', =>
                removeClass(@,arrowpos...)
                addClass(@,arrowpos[view.arrow])

            # .arrow
            @$div class:'holder', ->
                @$div class:'box', ->
                    @$section class:'channelInfo', ->
                        name = @$h4()
                        role = @$div class:'currentRole'
                        update_user = (user) ->
                            name.text "#{user.get 'id'}"
                            affiliation = user.getAffiliationFor channel.get 'id'
                            role?.text "#{userspeak[affiliation] or affiliation}"
                        view.bind('update:select:user', update_user)
                        update_user(app.users.get_or_create id:view.currentjid)

                    @$section class:'action changeRole', ->
                        infos = {}
                        options = {}
                        selected = 'moderator'
                        @$select ->
                            for role, value of affiliations_map
                                options[role] = @$option {value}
                            update_affiliation = (val) =>
                                role = reversed_affiliations_map[val]
                                return if role is selected
                                infos[selected]?.hide()
                                infos[role]?.show()
                                selected = role
                            view.bind('update:select:affiliation', update_affiliation)
                            update_affiliation(selected)

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
                        view.bind('update:affiliations', set_current_option)
                        view.bind('update:select:user',  set_current_option)
                        set_current_option(app.users.get_or_create id:view.currentjid)


unless process.title is 'browser'
    return module.exports =
        src: "streams.html"
        select: () ->
            el = @select ".channelDetails .channelList:nth(2)", "img, .adminAction"
            el.find('h3').text ""
            el


{ Template } = require 'dynamictemplate'
{ List } = require 'dt-list'
design = require '../../../_design/channel/details/list'
{ gravatar } = require '../../../util'
{ addClass, removeClass } = require '../../util'

module.exports = design (view) ->
    return new Template schema:5, ->
        section = @$section class: 'channelList', ->
            view.bind('show', @show)
            view.bind('hide', @hide)
            # hidden by default, until 1st user is added:
            @hide()

            update_count = null
            @$h3 ->
                @text "#{view.title} "
                @$span class: 'count', ->
                    @hide()

                    update_count = =>
                        @text "#{view.showing_count}"
                    view.bind 'show:all', =>
                        @show()
                        update_count()
                    update_count()
            @$div class:'list', ->
                users = new List
                idxs = {}

                view.bind 'add', (user) =>
                    uid = user.get 'id'
                    users.push @$img
                        class:'avatar'
                        src:"#{gravatar uid}"
                        title:uid
                        'data-userid': uid # FIXME UGLY
                    idxs[uid] = users.keys[users.length - 1]
                    update_count?()
                    section.show() if users.length is 1

                view.bind 'remove', (user) ->
                    uid = user.get 'id'
                    i = idxs[uid]?.i
                    i -= 1 if i? and view.info.idx?.i? and i > view.info.idx?.i
                    users.remove(i)?.remove()
                    delete idxs[uid]
                    update_count?()
                    section.hide() if users.length is 0

                olduser = null
                view.info.bind 'update:select:user', (user, el) =>
                    return unless (idx = idxs[user.get 'id'])?
                    return unless (cur = users[idx.i])?

                    removeClass(olduser,"selected")

                    if view.info.idx
                        users.remove(view.info.idx.i).remove(soft:yes)
                        if cur is olduser
                            view.info.idx = null
                            return # close user info

                    addClass(cur, "selected")
                    olduser = cur

                    row = idx.i - idx.i%4 + 4
                    if users.length < 4 or row > users.length
                        row = users.length
                    view.info.tpl (t) =>
                        view.info.arrow = idx.i%4
                        users.insert(row, t)
                        @add(t)
                        view.info.trigger 'update:select:arrow'
                        view.info.idx = users.keys[row]


                view.info.bind 'update:select:none', ->
                    view.info.tpl (t) -> t.remove(soft:yes)
                    view.info.idx = null
                    removeClass(olduser,"selected")
                    olduser = null

            @$div class: 'showAll', ->
                view.bind('show:all', @remove)

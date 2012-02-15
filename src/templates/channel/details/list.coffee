unless process.title is 'browser'
    return module.exports =
        src: "streams.html"
        select: () ->
            el = @select ".channelDetails .channelList:nth(2)", "img, .adminAction"
            el.find('h3').text ""
            el


{ Template } = require 'dynamictemplate'
jqueryify = require 'dt-jquery'
design = require '../../../_design/channel/details/list'
{ EventHandler } = require '../../../util'


module.exports = design (view) ->
    return jqueryify new Template schema:5, ->
        @$section class: 'channelList', ->
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
            list = @$div class: 'list', ->

                new_user = (user) =>
                    img = @$img
                        class:'avatar'
                        src:"#{user.avatar}"
                        title: user.get('id')
                        'data-userid': user.get('id') # FIXME UGLY
                    return remove:->
                        img.remove()

                users = {}
                view.bind 'add', (user) ->
                    users[user.get('id')] ?= new_user(user)
                    update_count?()
                view.bind 'remove', (user) ->
                    users[user.get('id')]?.remove()
                    delete users[user.get('id')]
                    update_count?()

            @$div class: 'showAll', ->
                view.bind 'show:all', =>
                    @remove()


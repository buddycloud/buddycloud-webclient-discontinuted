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
                    update_count = =>
                        @text view.model.length
                    update_count()
            list = @$div class: 'list'
            add_follower = (user) ->
                userid = user.get 'id'
                imgBefore = null
                list._jquery.find(".avatar").each ->
                    existingImg = $(this)
                    existingId = existingImg.data('userid')
                    if existingId < userid and
                       (not imgBefore or existingId > imgBefore.data('userid'))
                        imgBefore = existingImg
                img = $('<img>')
                img.attr
                    class:'avatar'
                    src: "#{user?.avatar}",
                    title: user.get('id')
                    'data-userid': user.get('id')
                if imgBefore
                    img.insertAfter imgBefore
                else
                    list._jquery.prepend img
                img.click EventHandler ->
                    app.router.navigate user.get('id'), true
            rm_follower = (userid) ->
                list._jquery.find('img').each ->
                    img = $(this)
                    if img.data('userid') is userid
                        img.remove()
            # Iterates through node.subscriptions in "followers" case,
            # and over user.channels in "following" case:
            view.model.forEach (user) ->
                add_follower user
            view.model.bind 'add', (user) ->
                add_follower user
                update_count()
            view.model.bind 'remove', (user) ->
                rm_follower user.get('id')
                update_count()

            @$div class: 'showAll', ->
                view.bind 'show:all', =>
                    @remove()

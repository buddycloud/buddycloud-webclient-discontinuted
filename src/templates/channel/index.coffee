unless process.title is 'browser'
    return module.exports =
        src: "streams.html"
        select: () ->
            el = @select ".content", "article.topic, div.channelDetails, .notification"
            el.find('h2, span:not(.loader, .button), #poweredby').text("")
            el.find('img.avatar').removeAttr('src')
            return el


{ Template } = require 'dynamictemplate'
design = require '../../_design/channel/index'
{ autoResize } = require '../util'
{ parse_post } = require '../../util'

module.exports = design (view) ->
    return new Template schema:5, -> @$div class:'content', ->
        @$div class:'channelView', ->
            @$header ->
                @$table -> @$tbody -> @$tr ->
                    @$td ->
                        @$img class:'avatar', ->
                            @attr src:"#{view.model.avatar}"
                    @$td ->
                        @$div ->
                            title = @$h2 class:'title'
                            update_metadata = ->
                                title.text "#{view.metadata.get('title')?.value or view.model.get('id')}"
                            view.metadata.bind 'change', update_metadata
                            update_metadata()

                            status = @$span class:'status'
                            update_status = (text) ->
                                update_text.call status, parse_post(text)
                            view.bind 'status', update_status
                            update_status()
                    @$td ->
                        @$nav ->
                            @$span class:'messages button', ->
                                @remove() # FIXME
                            save = @$span class:'save button'
                            edit = @$span class:'edit button', ->
                                update_edit_button = =>
                                    if app.users.current.canEdit(view.model)
                                        @show()
                                    else
                                        @hide()
                                view.bind 'update:affiliations', update_edit_button
                                update_edit_button()
                            app.on 'editmode', (state) ->
                                return if view.hidden
                                if state is on
                                    save.show()
                                    edit.text "Cancel"
                                else if state is off
                                    save.hide()
                                    edit.text "Edit"
                            unless app.users.isAnonymous(app.users.current)
                                follow = @$span class:'follow button', ->
                                    @text "Follow"
                                unfollow = @$span class:'unfollow button', ->
                                    @text "Unfollow"

                                update_follow_unfollow = ->
                                    if app.users.current.get('id') is view.model.get('id')
                                        follow.hide()
                                        unfollow.hide()
                                    else if app.users.current.isFollowing view.model
                                        follow.hide()
                                        unfollow.show()
                                    else
                                        follow.show()
                                        unfollow.hide()
                                app.users.current.channels.bind 'add', update_follow_unfollow
                                app.users.current.channels.bind 'remove', update_follow_unfollow
                                update_follow_unfollow()
                @$a -># powered by buddycloud
                    @attr title:"#{app.version}"

            @$section class:'stream', ->
                @$section class:'newTopic', ->
                    update_newTopic = =>
                        if app.users.current.canPost(view.model)
                            @show()
                        else
                            @hide()
                    view.bind 'update:permissions', update_newTopic
                    update_newTopic()
                    @attr 'id', "#{view.model.get 'id'}-topicpost"
                    @$img class:'avatar', ->
                        @attr src:"#{app.users.current.avatar}"
                    # Following code will implement autoresize on the textarea which
                    # is used to post a new topic to a channel.
                    # Autoresize means the form is "growing" automatically bigger when
                    # more and more text is added.
                    autoResize(@div class:'expanding area').textarea.ready ->
                        @_jquery.textSaver()
                    # @$div class:'controls', ->
                        # div button checkbox
                        #    checkbox shouldShareLocation
                        #    label for shouldShareLocation
                        # @$div id:'createNewTopic'
                @$div class: 'notifications', ->
                    view.bind('subview:notification', @add)

                @$section class:'topics', ->
                    view.postsview.bind('template:create', @replace)

                tutorial = null
                timeout = null
                update_tutorial = =>
                    timeout = null
                    if view.model.nodes.get('posts').posts.length
                        tutorial?.remove()
                        tutorial = null
                        return
                    if view.model.isLoading
                        # This is added to not to display any helpers or
                        # notifies while channel is still loading.
                        return
                    type = "empty"
                    type = "tutorial" if app.users.current.canPost(view.model)
                    return if type is tutorial?.type
                    tutorial?.remove()
                    tutorial = @$p({class:"#{type}"}, tutorial_text[type])
                    tutorial.type = type
                throttled_update_tutorial = ->
                    timeout ?= setTimeout(update_tutorial, 200)
                view.model.on('add',    throttled_update_tutorial)
                view.model.on('remove', throttled_update_tutorial)
                view.model.on('loading:stop', throttled_update_tutorial)

                @$p class:'loader', ->
                    spinner = @$span class:'spinner'
                    spinner.hide()
                    view.model.bind('loading:start', spinner.show)
                    view.model.bind('loading:stop',  spinner.hide)

        @$div class:'channelDetails', ->
            view.details.bind('template:create', @replace)

        view.bind('show', @show)
        view.bind('hide', @hide)


tutorial_text =
    tutorial: ["This channel is still empty."
               "first post"].join " "
    empty:"This channel has no posts. Yet."

update_text = (parts) ->
    # Empty the <p/>
    @text("")

    text = ""
    flush_text = =>
        if text and text.length > 0
            @$span text
            text = ""
    for part in parts
        switch part.type
            when 'text'
                text += part.value
            when 'link'
                flush_text()

                link = part.value
                # Protocol part may be missing (short URLs like
                # ur1.ca/8jz57). Make sure there's one or the browser will
                # think it's a link to http://example.com/ur1.ca/8jz57.
                full_link = link
                unless link.match(/^[a-z0-9-]+:/)
                    full_link = 'http://' + link
                link_target = "_blank"
                link_target = "_self" if document.domain is full_link.split('/')[2]
                @$a { href: full_link, target: link_target}, link
            when 'user'
                flush_text()

                userid = part.value
                @$a
                    class: 'internal userlink'
                    href: "/#{userid}"
                    'data-userid': userid
                , ->
                    @text userid
    flush_text()
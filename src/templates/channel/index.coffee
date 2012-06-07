unless process.title is 'browser'
    return module.exports =
        src: "streams.html"
        select: () ->
            el = @select ".content", "article.topic, div.channelDetails, .notification"
            el.find('h2, span:not(.loader, .button), #poweredby').text("")
            return el


{ Template } = require 'dynamictemplate'
design = require '../../_design/channel/index'
{ autoResize } = require '../util'

module.exports = design (view) ->
    return new Template {view:view,schema:5}, -> @$div class:'content', ->
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
                                status.text text ? ""
                            view.bind 'status', update_status
                            update_status()
                    @$td ->
                        @$nav ->
                            @$span class:'messages button', ->
                                @remove() # FIXME
                            @$span class:'edit button', ->
                                update_edit_button = =>
                                    if app.users.current.canEdit(view.model)
                                        @show()
                                    else
                                        @hide()
                                view.bind 'update:affiliations', update_edit_button
                                update_edit_button()
                            if app.users.isAnonymous(app.users.current)
                                @$span class:'login button', ->
                                    @text "Login"#  FIXME +"or Register to Follow"
                            else
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
                @$p class:'loader', ->
                    spinner = @$span class:'spinner'
                    spinner.hide()
                    view.model.bind('loading:start', spinner.show)
                    view.model.bind('loading:stop',  spinner.hide)

        @$div class:'channelDetails', ->
            view.details.bind('template:create', @replace)

        view.bind('show', @show)
        view.bind('hide', @hide)



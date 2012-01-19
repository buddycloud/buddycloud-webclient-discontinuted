unless process.title is 'browser'
    return module.exports =
        src: "streams.html"
        select: () ->
            el = @select "div.channelView", "article.topic, div.channelDetails"
            el.find('h2, span:not(.loader)').text("")
            return el


{ Template } = require 'dynamictemplate'
jqueryify = require 'dt-jquery'
design = require '../../_design/channel/index'

module.exports = design (view) ->
    return jqueryify new Template schema:5, ->
        @$div class:'channelView', ->
            @$header ->
                # powered by buddycloud
                @$img class:'avatar', ->
                    @attr src:"#{view.model.avatar}"
                @$div class:'titleBar', ->
                    title = @$h2 class:'title'
                    # FIXME: use .../status node post?
                    status = @$span class:'status'
                    update_metadata = ->
                        title.text "#{view.metadata.get('title')?.value or view.model.get('id')}"
                        status.text view.metadata.get('description')?.value or ""
                    view.metadata.bind 'change', update_metadata
                    update_metadata()
                @$nav ->
                    @$div class:'messages button', ->
                        @remove() # FIXME
                    @$div class:'edit button', ->
                        @remove() if app.users.isAnonymous(app.users.current)
                    ###<% unless @user?.isCurrent: %>
                    <div class="button unfollow">Unfollow</div>
                        <% end %>
                    <% else if not @user?.isAnonymous: %>
                    <div class="button follow">Follow</div>
                    <% end %>###
#                     @$div class:'messages button', ->
#                         @$span class:'counter', ->
#                             @text "?"
                    follow = @$div class:'follow button', ->
                        if app.users.isAnonymous(app.users.current)
                            @text "Login"#  FIXME +"or Register to Follow"
                        else
                            @text "Follow"
                    unfollow = @$div class:'unfollow button', ->
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


            @$section class:'stream', ->
                @$section class:'newTopic', ->
                    return @remove() if app.users.isAnonymous(app.users.current)
                    @attr 'id', "#{view.model.get 'id'}-topicpost"
                    @$img class:'avatar', ->
                        @attr src:"#{app.users.current.avatar}"
                    # textarea
                    @$div class:'controls', ->
                        # div button checkbox
                        #    checkbox shouldShareLocation
                        #    label for shouldShareLocation
                        # @$div id:'createNewTopic'
                @$section class:'topics', ->
                    view.bind('subview:topics', @replace)
                @$p class:'loader', ->
                    spinner = @$span class:'spinner'
                    spinner.hide()
                    view.model.bind 'loading:start', ->
                        spinner.show()
                    view.model.bind 'loading:stop', ->
                        spinner.hide()
            @$div class:'channelDetails', ->
                view.bind('subview:details', @replace)



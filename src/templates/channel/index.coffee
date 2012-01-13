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
                    @$h2 class:'title', ->
                        view.bind 'view:title', (text) =>
                            @text "#{text}"
                    @$span class:'status', ->
                        @text "status of a public personal channel" # FIXME
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
                    @$div class:'follow button prominent', ->
                        if app.users.isAnonymous(app.users.current)
                            @text "Login"#  FIXME +"or Register to Follow"
                        else
                            @text "Follow"
                    @$div class:'unfollow button prominent', ->
                        @text "Unfollow"
            @$section class:'stream', ->
                @$section class:'newTopic', ->
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
                    view.bind 'subview:topics', (tag) =>
                        @_jquery?.replaceWith(tag._jquery ? tag)
                @$p class:'loader'
            @$div class:'channelDetails', ->
                view.bind 'subview:details', (tag) =>
                    @_jquery?.replaceWith(tag._jquery ? tag)



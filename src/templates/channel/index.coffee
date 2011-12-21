unless process.title is 'browser'
    return module.exports =
        src: "streams.html"
        select: () ->
            @select "div.channelView", "article.topic, div.channelDetails"


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
                        @text "", force:yes
                        view.bind 'view:title', (text) =>
                            @text "#{text}"
                    @$span class:'status', ->
                        @text "-"
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
                    @$div class:'follow button prominent', "Follow" # FIXME required dummy
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
                    view.bind 'view:topic', (tag) =>
                        @attach tag
                @$p class:'loader'




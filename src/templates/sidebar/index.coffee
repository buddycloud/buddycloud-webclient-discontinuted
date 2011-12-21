unless process.title is 'browser'
    return module.exports =
        src: "streams.html"
        select: () ->
            @select "#sidebar",
                ".channel:not(.personal), .personal.channel > *, div.search > *"
            # TODO .append(@select('.channel')?.get(0).clone())


{ Template } = require 'dynamictemplate'
jqueryify = require 'dt-jquery'
design = require '../../_design/sidebar/index'

module.exports = design (view) ->
    return jqueryify new Template schema:5, ->
        @$div id:'sidebar', ->
            @$div ->
                @$div class:'personal channel', ->
                    #@text "loading personal channel …"
                    view.bind 'subview:personalchannel', (tag) =>
                        #@text "", force:yes
                        @emit 'jquery:replace', tag
                @$div class:'search', ->
                    @text "loading searchbar …"
                    view.bind 'subview:searchbar', (tag) =>
                        @text "", force:yes
                        @_jquery?.replaceWith(tag._jquery ? tag)
#                         @emit 'jquery:replace', tag
                @$div id:'channels', ->
                    @$div ->
                        view.bind 'view:channel', (channel) =>
                            @$div class:'channel', ->
                                @$div class:'avatar', style:"background-image:url(#{channel.avatar})", ->
                                    @$span class:'counter', (channel.counter) # channelpost class should autofill
                                @$div class:'info', ->
                                    @$span class:'owner', ->
                                        jid = channel.get('jid')?.split('@') or []
                                        @text "#{jid[0]}"
                                        @$span class:'domain', "#{jid[1]}"
                                    @$span class:'status', (channel.nodes.get('status')?.last() or "")
#             @once 'end', =>
#                 # FIXME is this really wise to write this here?
#                 view.parent.trigger 'subview:add', this
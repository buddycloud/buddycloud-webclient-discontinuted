unless process.title is 'browser'
    return module.exports =
        src: "streams.html"
        select: () ->
            @select "#channels", ".channel"
            # TODO .append(@select('.channel')?.get(0).clone())


{ Template } = require 'dynamictemplate'
design = require '../_design/sidebar'

module.exports = design (ee) ->
    return new Template schema:5, ->
        @$div id:'channels', ->
            @$div ->
                ee?.on 'new:channel', (channel) =>
                    @$div class:'channel', ->
                        @$div class:'avatar', style:"background-image:url(#{channel.avatar})", ->
                            @$span class:'counter', (channel.counter) # channelpost class should autofill
                        @$div class:'info', ->
                            @$span class:'owner', ->
                                jid = channel.get('jid')?.split('@') or []
                                @text "#{jid[0]}"
                                @$span class:'domain', "#{jid[1]}"
                            @$span class:'status', (channel.nodes.get('status')?.last() or "")
unless process.title is 'browser'
    return module.exports =
        src: "streams.html"
        select: () ->
            el = @select "section.channelList .adminAction"
            el.find('.channelInfo, .currentRole').text ""
            el.removeClass('moderator')
            el.removeClass('choosen')
            el.removeClass('role')
            el


{ Template } = require 'dynamictemplate'
jqueryify = require 'dt-jquery'
design = require '../../../_design/channel/details/user'
{ EventHandler } = require '../../../util'


module.exports = design (view) ->
    return jqueryify new Template schema:5, ->
        @$div class:'adminAction', ->
            # .arrow
            @$div class:'holder', ->
                @$div class:'box', ->
                    @$section class:'channelInfo', ->
                        name = @$h4()
                        role = @$div class:'currentRole'
                        view.bind 'user:update', (user) ->
                            name.text "#{user.get('id')}"
                            role.text "affililation" # FIXME
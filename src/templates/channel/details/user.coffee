unless process.title is 'browser'
    return module.exports =
        src: "streams.html"
        select: () ->
            el = @select "section.channelList .adminAction"
            el.find('.channelInfo, .currentRole').text ""
            el.removeClass('moderator')
            # FIXME everywhere: "chosen"?
            el.removeClass('choosen')
            el.removeClass('role')
            el


{ Template } = require 'dynamictemplate'
jqueryify = require 'dt-jquery'
design = require '../../../_design/channel/details/user'
{ EventHandler } = require '../../../util'

userspeak =
    'owner':    "Producer"
    'moderator':"Moderator"
    'publisher':"Follower+Post"
    'member':   "Follower"
    'outcast':  "Banned Follower"
    'none':     "Does not follow back"

module.exports = design (view) ->
    return jqueryify new Template schema:5, ->
        channel = view.parent.parent.model
        @$div class:'adminAction', ->
            # .arrow
            @$div class:'holder', ->
                @$div class:'box', ->
                    @$section class:'channelInfo', ->
                        name = @$h4()
                        role = @$div class:'currentRole'
                        view.bind 'user:update', (user) ->
                            name.text "#{user.get 'id'}"
                            affiliation = user.getAffiliationFor channel.get 'id'
                            role?.text "#{userspeak[affiliation] or affiliation}"
                        if app.users.isAnonymous(app.users.current)
                            role.remove()
                            delete role


            update_role = =>
                classes = @attr('class').split(/\s+/)
                console.warn "update_role", view, app.users.current.canEdit channel
                if app.users.current.canEdit channel
                    modClass = (class_) ->
                        if classes.indexOf(class_) < 0
                            classes.push class_
                else
                    modClass = (class_) ->
                        classes = classes.filter (class__) ->
                            class_ isnt class__
                modClass 'moderator'
                modClass 'choosen'
                modClass 'role'
                @attr 'class', classes.join(" ")
            view.parent.parent.parent.bind 'update:permissions', update_role
            update_role()

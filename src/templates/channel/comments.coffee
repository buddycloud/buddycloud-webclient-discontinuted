unless process.title is 'browser'
    return module.exports =
        src: "streams.html"
        select: () ->
            @select "section.comments:eq(0)", "section.comment"


{ Template } = require 'dynamictemplate'
jqueryify = require 'dt-jquery'
design = require '../../_design/channel/comments'


module.exports = design (view) ->
    return jqueryify new Template schema:5, ->
        @$section class:'comments', ->
            #  <% if @user?.hasRightToPost: %> FIXME
            @$section class:'answer', ->
                if app.users.current.canPost(view.parent.parent.parent.model)
                    @show()
                else
                    @hide()
                @$img class:'avatar', ->
                    @attr src:"#{app.users.current.avatar}"
                # textarea
                # div.controls
                #   div.button.small.checkbox
                #   input#shouldShareLocation125
                #   label[for="shouldShareLocation125"]
                # div.button.small.prominent
                #   Post



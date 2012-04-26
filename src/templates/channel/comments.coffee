unless process.title is 'browser'
    return module.exports =
        src: "streams.html"
        select: () ->
            @select "section.comments:eq(0)", "section.comment"


{ Template } = require 'dynamictemplate'
{ List } = require 'dt-list'
design = require '../../_design/channel/comments'
{ insert } = require '../util'


module.exports = design (view) ->
    return new Template schema:5, ->
        @$section class:'comments', ->
            view.bind('view:comment', insert.bind(this, new List))
            #  <% if @user?.hasRightToPost: %> FIXME
            @$section class:'answer', ->
                update_answer = =>
                    if app.users.current.canPost(view.parent.parent.parent.model)
                        @show()
                    else
                        @hide()
                view.parent.parent.parent.bind 'update:permissions', update_answer
                update_answer()

                @$img class:'avatar', ->
                    @attr src:"#{app.users.current.avatar}"
                # textarea
                # div.controls
                #   div.button.small.checkbox
                #   input#shouldShareLocation125
                #   label[for="shouldShareLocation125"]
                # div.button.small.prominent
                #   Post



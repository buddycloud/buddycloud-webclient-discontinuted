unless process.title is 'browser'
    return module.exports =
        src: "streams.html"
        select: () ->
            @select "section.comments:eq(0)", "section.comment"


{ Template } = require 'dynamictemplate'
design = require '../../_design/channel/comments'
{ List } = require '../util'


module.exports = design (view) ->
    return new Template schema:5, ->
        @$section class:'comments', ->
            list = new List this
            list.bind(view, 'view:comment')
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



unless process.title is 'browser'
    return module.exports =
        src: "anon.html"
        select: () ->
            @select ".overlay"


{ Template } = require 'dynamictemplate'
design = require '../../_design/authentication/overlay'

module.exports = design (view) ->
    return new Template schema:5, ->
        @$div class:'overlay', ->
            @$div ->
                # .close
                @$div class: 'left', ->
                    @$p ->
                        @$a ->
                            return @remove() if config.registration is off
                            @attr href: "/register"

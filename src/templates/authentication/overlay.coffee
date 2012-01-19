unless process.title is 'browser'
    return module.exports =
        src: "anon.html"
        select: () ->
            @select ".overlay"


{ Template } = require 'dynamictemplate'
jqueryify = require 'dt-jquery'
design = require '../../_design/authentication/overlay'

module.exports = design (view) ->
    return jqueryify new Template schema:5, ->
        @$div class:'overlay', ->
            @$div ->
                @$div class: 'left', ->
                    @$p ->
                        @$a ->
                            @attr href: "/register"

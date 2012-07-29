unless process.title is 'browser'
    return module.exports =
        src: "startpage.html"
        select: () ->
            el = @select "header, .holder:has(.stats)", ".stats > *"

            # set urls from header links
            el.find('.logo > a').attr(href:"/lounge@topics.buddycloud.org")
            el.find("nav > a:contains('about')")
                .attr(href:"http://buddycloud.com")
            el.find("nav > a:contains('buddywear')")
                .attr(href:"http://buddycloud.spreadshirt.net/")
            el.find("nav > a:contains('developers')")
                .attr(href:"http://buddycloud.org")

            el.find(".contact").remove() # FIXME the contact values are just wrong
            return el


{ Template } = require 'dynamictemplate'
design = require '../../_design/discover/startpage'

module.exports = design (view) ->
    return new Template schema:5, ->
        @$div class:'holder', ->
            @$section class:'stats', ->
                view.on("subview:discover", @add)

        view.on('show', @show)
        view.on('hide', @hide)

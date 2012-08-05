unless process.title is 'browser'
    return module.exports =
        src: "startpage.html"
        select: () ->
            el = @select "header, .holder:has(.stats)", ".stats > *, .about > *"

            # set urls from header links
            el.find('.logo > a').attr(href:"/lounge@topics.buddycloud.org")
            el.find("nav > a:contains('about')")
                .attr(href:"http://buddycloud.com")
            el.find("nav > a:contains('buddywear')")
                .attr(href:"http://buddycloud.spreadshirt.net/")
            el.find("nav > a:contains('developers')")
                .attr(href:"http://buddycloud.org")

            el.find("input[type='search']").remove() # FIXME until search is implemented
            el.find("form").remove() # FIXME until mrflix finds a better spot for that
            return el


$$ = require 'dt-selector'
{ Template } = require 'dynamictemplate'
design = require '../../_design/discover/startpage'
{ removeClass } = require '../util'

module.exports = design (view) ->
    return new Template schema:5, ->
        @$div class:'holder', ->
            @$section class:'stats', ->
                view.on "subview:discover", (el) =>
                    @add(el)
                    $$(el).on 'div', (e) ->
                        removeClass(e,"span-2")
                        removeClass(e,"span-1")

            @$section(class:'about').raw(config['homepage-text'])

        view.on('show', @show)
        view.on('hide', @hide)

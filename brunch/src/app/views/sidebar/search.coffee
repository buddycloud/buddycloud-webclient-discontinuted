{ BaseView } = require 'views/base'
{ EventHandler } = require 'util'

class exports.Searchbar extends BaseView
    template: require 'templates/sidebar/search'

    initialize: ({@channels}) ->
        super

    events:
        'keyup input[type="search"]': 'on_key'
        'search input[type="search"]': 'on_search'

    on_key: (ev) ->
        code = ev.keyCode or ev.which # bloody browsers
        input = @$('input[type="search"]')
        search = input.val()
        if ev.type is 'keydown'
            if 31 < code < 127 or code > 159
                search += String.fromCharCode(code)
        @filter = search
        @trigger 'filter', search

    on_search: EventHandler ->
        input = @$('input[type="search"]')
        search = input.val()?.toLowerCase() or ""

        is_jid = /[^\/]+@[^\/]/.test(search)
        channels = @channels.filter(@filter)

        if is_jid or channels.length is 1
            unless is_jid
                search = channels[0].get 'id'
            app.router.navigate search, yes

        input.val ""
        @filter = ""
        @trigger 'filter', ""




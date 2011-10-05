{ BaseView } = require 'views/base'

class exports.Searchbar extends BaseView
    template: require 'templates/sidebar/search'

    initialize: ({@channels}) ->
        super

    events:
        'keyup .search input': 'on_key'

    on_key: (ev) ->
        code = ev.keyCode or ev.which # bloody browsers
        input = @$('.search input')
        search = input.val()
        if 31 > code > 127 or code > 159
            search += String.fromCharCode(code)
        @filter = search

        if code is 13
            ev.preventDefault()

            is_jid = /[^\/]+@[^\/]/.test(search)
            channels = @channels.filter(@filter)

            if is_jid or channels.length is 1
                unless is_jid
                    search = channels[0].get 'id'
                app.router.navigate search, yes

                input.val ""
                @filter = ""
                @trigger 'filter', ""

            no
        else
            @trigger 'filter', search

            yes




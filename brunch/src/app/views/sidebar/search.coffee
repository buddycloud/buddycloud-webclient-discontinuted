{ BaseView } = require 'views/base'

class exports.Searchbar extends BaseView
    template: require 'templates/sidebar/search'

    events:
        'keyup .search input': 'on_key'

    on_key: (ev) ->
        code = ev.keyCode or ev.which # bloody browsers
        input = @$('.search input')
        search = input.val()
        if 31 > code > 127 or code > 159
            search += String.fromCharCode(code)

        if code is 13
            ev.preventDefault()

            if /[^\/]+@[^\/]/.test(search)
                app.router.navigate search, yes
                input.val ""

            no
        else
            @filter = search
            @trigger 'filter', search

            yes




{ BaseView } = require 'views/base'

class exports.Searchbar extends BaseView
    template: require 'templates/sidebar/search'

    events:
        'keypress .search input': 'on_keypress'

    on_keypress: (ev) ->
        if ev.keyCode is 13
            ev.preventDefault()

            input = @$('.search input')
            search = input.val()
            if /[^\/]+@[^\/]/.test(search)
                app.router.navigate search, yes
                input.val ""

            no
        else
            yes




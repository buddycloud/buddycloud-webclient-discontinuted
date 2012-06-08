{ BaseView } = require '../base'
{ EventHandler } = require '../../util'

class exports.Searchbar extends BaseView
    template: require '../../templates/sidebar/search'

    events:
        'search input[type="search"]': 'on_search'

    constructor: ->
        @filter = ""
        unless Modernizr.hasEvent 'search' # firefox
            # let delegateEvents handle the rest
            @events['keydown input[type="search"]'] = 'on_keydown'
        super

    on_keydown: (ev) =>
        code = ev.keyCode or ev.which
        return unless code is 13
        @on_search(ev)

    on_input: (tag, ev) => # used in the template, since we use an input event shim
        search = tag._jquery?.val()?.toLowerCase() or ""
        return if search is @filter
        @filter = search
        process.nextTick =>
            @trigger 'filter', search

    on_search: EventHandler ->
        return if @filter is ""
        input = @$('input[type="search"]')
        search = input.val()?.toLowerCase() or ""

        is_jid = /[^\/]+@[^\/]/.test(search)
        channels = @model.filter(@filter)

        if is_jid or channels.length is 1
            unless is_jid
                search = channels[0].get 'id'
            app.router.navigate search, yes

        input.val ""
        @filter = ""
        process.nextTick =>
            @trigger 'filter', ""




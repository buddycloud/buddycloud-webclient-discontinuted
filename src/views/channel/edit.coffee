{ BaseView } = require '../base'
{ EventHandler } = require '../../util'

editableElements = [
    'header .title'
    'header .status'
    '.meta .description'
    '.meta .accessModel'
    '.location .previous'
    '.location .current'
    '.location .next'
]


class exports.ChannelEditView extends BaseView
    template: require '../../templates/channel/edit'

    events:
        'click .save': 'clickSave'
        'click .cancel': 'clickCancel'

    clickSave: EventHandler ->
        @end()

    clickCancel: EventHandler ->
        @end()

    render: (cb) ->
        super ->
            unless $('html').hasClass('editmode')
                $('html').addClass('editmode')
                for el in editableElements
                    if $(el).data('editmode') isnt 'boolean'
                        # store the current state
                        #localStorage[el] = $(el).text();

                        # add designMode & contenteditable
                        $(el).
                            prop('contenteditable', yes).
                            input( ->
                                text = $(this).text();
                                if text is ""
                                    $(this).html("&nbsp;")
                            ).keydown((ev) ->
                                code = ev.keyCode or ev.which
                                if $(this).data('editmode') is 'singleLine' && code == 13
                                    ev.preventDefault()
                                    return false
                                else
                                    return true
                            )
                $(editableElements[0]).focus()
            cb?()

    end: =>
        if $('html').hasClass('editmode')
            $('html').removeClass('editmode')
            for el in editableElements
                if $(el).data('editmode') isnt 'boolean'
                    $(el).
                        prop('contenteditable', no)
                    # TODO: rm input & keydown handlers
        @trigger 'end'

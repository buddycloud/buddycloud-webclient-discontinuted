{ BaseView } = require '../base'
#{ EventHandler, throttle_callback } = require '../../util'


class exports.ChannelEditView extends BaseView
    template: require '../../templates/channel/edit'

    render: (cb) ->
        super ->
            editableElements = [
                'header .title'
                'header .status'
                '.meta .description'
                '.meta .accessModel'
                '.location .previous'
                '.location .current'
                '.location .next'
            ]
            unless $('html').hasClass('editmode')
                $('html').addClass('editmode')
                for el in editableElements
                    if $(el).data('editmode') isnt 'boolean'
                        # store the current state
                        #localStorage[el] = $(el).text();

                        # add designMode & contenteditable
                        $(el).
                            prop('contenteditable', true).
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

{ BaseView } = require '../base'
{ EventHandler } = require '../../util'

editableElements = [
    'header .title'
    #'header .status'
    '.meta .description .data'
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
        # set_node_metadata() takes 1 round-trip, hide buttons in the
        # meanwhile:
        @$('.save, .cancel').fadeOut(200)

        # Retrieve values
        title = $('header .title').text()
        description = $('.meta .description .data').text()

        # Send to server
        node = @model.nodes.get_or_create id: 'posts'
        console.warn "save", node.get('nodeid'), title, description
        app.handler.data.set_node_metadata node, { title, description }
        , (err) =>
            if err
                # Undo values:
                @clickCancel()
            else
                # Committed fine:
                @end()

    clickCancel: EventHandler ->
        node = @model.nodes.get_or_create id: 'posts'
        # Cause metadata re-render:
        node.metadata.trigger 'change'

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

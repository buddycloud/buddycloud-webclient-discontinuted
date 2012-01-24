{ BaseView } = require '../base'
{ EventHandler } = require '../../util'


class exports.ChannelEditView extends BaseView
    template: require '../../templates/channel/edit'

    events:
        'click .save': 'clickSave'
        'click .cancel': 'clickCancel'

    clickSave: EventHandler ->
        # set_node_metadata() takes 1 round-trip, hide buttons in the
        # meanwhile:
        @$('.save, .cancel').fadeOut(200)
        @trigger 'loading:start'

        # Retrieve values
        title = @parent.$('header .title').text()
        description = @parent.$('.meta .description .data').text()

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
                @parent.$('*').each @makeEditable

            @trigger 'loading:stop'
            cb?()

    makeEditable: ->
        el = $(this)
        switch el.data('editmode')
            when 'singleLine'
                el.
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
            when 'multiLine'
                el.
                    prop('contenteditable', yes).
                    input( ->
                        text = $(this).text();
                        if text is ""
                            $(this).html("&nbsp;")
                    )
            when 'boolean'
                text = el.text()
                # Last class becomes id
                elClasses = el.prop('class').split(' ')
                id = elClasses[elClasses.length - 1]
                el.
                    addClass('contenteditable').
                    html('<input type="checkbox"><label></label>')
                el.find('input').attr('id', id)
                el.find('label').
                    attr('for', id).
                    text(text)

                if id is 'accessModel'
                    if text is 'open'
                        el.find('input').prop 'checked', "checked"
                    else
                        el.find('input').removeProp 'checked'
                    update = ->
                        if el.find('input').prop('checked')
                            el.find('label').text("open")
                        else
                            el.find('label').text("private")
                    el.find('input').change update
                    update()

    undoEditable: ->
        el = $(this)
        # TODO: rm input & keydown handlers
        switch el.data('editmode')
            when 'singleLine'
                el.prop('contenteditable', no)
            when 'multiLine'
                el.prop('contenteditable', no)
            when 'boolean'
                el.removeClass('contenteditable')

    end: =>
        if $('html').hasClass('editmode')
            $('html').removeClass('editmode')
            @parent.$('*').each @undoEditable

        @trigger 'end'

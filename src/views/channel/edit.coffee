{ BaseView } = require '../base'
{ EventHandler } = require '../../util'


class exports.ChannelEditView extends BaseView
    template: require '../../templates/channel/edit'

    events:
        'click .save': 'clickSave'
        'click .cancel': 'clickCancel'

    initialize: ->
        super
        @active = no

        @bind 'show', @show
        @bind 'hide', @hide

        do @render

    show: =>
        @ready =>
            @trigger 'update:el', @el

    hide: =>
        @el.detach()
        @trigger 'update:el', $('<div id="editbar">')

    turn: (state) =>
        @active = state
        if state is on
            @begin()
        else if state is off
            @end()
        else throw new Error "wtf is that?"

    toggle: =>
        @turn not @active

    render: (callback) ->
        super ->
            @trigger 'loading:stop'
            callback?.call(this)

    begin: =>
        unless $('html').hasClass('editmode')
            $('html').addClass('editmode')
            @parent.$('*').each @makeEditable
            @show()

    end: =>
        if $('html').hasClass('editmode')
            $('html').removeClass('editmode')
            @parent.$('*').each @undoEditable
            @hide()

        @trigger 'end'

    clickSave: EventHandler ->
        # set_node_metadata() takes 1 round-trip, hide buttons in the
        # meanwhile:
        @$('.save, .cancel').fadeOut(200)
        @trigger 'loading:start'

        # Retrieve values
        # FIXME: title text sometimes contains the title of the next channel too!
        title = @parent.$('header .title').text()
        status = @parent.$('header .status').text()
        description = @parent.$('.meta .description .data').text()
        open = @parent.$('#accessModel').prop 'checked'
        access_model = if open then 'open' else 'authorize'

        # Send to server
        # FIXME: access_model for all user nodes?
        postsnode = @model.nodes.get_or_create id: 'posts'
        app.handler.data.set_node_metadata postsnode
        , { title, description, access_model }
        , (err) =>
            if err
                # Undo values:
                @clickCancel()
            else
                # Committed fine:
                @end()
        # Update status
        statusnode = @model.nodes.get_or_create id: 'status'
        app.handler.data.publish statusnode
        , { content: status, author: { name: app.users.current.get 'jid' } }
        , (error) =>
            # TODO: undo on error

    clickCancel: EventHandler ->
        node = @model.nodes.get_or_create id: 'posts'
        # Cause metadata re-render:
        node.metadata.trigger 'change'

        @end()

    makeEditable: ->
        el = $(this)

        preventEmptyness = ->
            text = $(this).text()
            if text is ""
                $(this).html("&nbsp;")

        switch el.data('editmode')
            when 'singleLine'
                el
                    .prop('contenteditable', yes)
                    .input(preventEmptyness)
                    .keydown((ev) ->
                        code = ev.keyCode or ev.which
                        if $(this).data('editmode') is 'singleLine' and code is 13
                            ev.preventDefault()
                            return false
                        else
                            return true
                    )
            when 'multiLine'
                el
                    .prop('contenteditable', yes)
                    .input(preventEmptyness)
            when 'boolean'
                text = el.text()
                # Last class becomes id
                elClasses = el.prop('class').split(' ')
                id = elClasses[elClasses.length - 1]
                el
                    .addClass('contenteditable')
                    .html('<input type="checkbox"><label></label>')
                el.find('input').attr('id', id)
                el.find('label').
                    attr('for', id).
                    text(text)

                if id is 'accessModel'
                    if text is 'open'
                        el.find('input').prop('checked', yes)
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


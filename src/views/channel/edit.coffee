{ BaseView } = require '../base'
{ EventHandler } = require '../../util'
async = require 'async'
{ Tag } = require 'dynamictemplate'

helptextOpenmode = ["open: anyone can view"
                    "or follow. (click to change)"].join " "
helptextPrivatemode = ["private:"
                       "only followers you approve will be"
                       "able to view posts."
                       "(click to change)"].join " "

class exports.ChannelEditView extends BaseView
    template: require '../../templates/channel/edit'

    initialize: ->
        super
        @active = no

        @bind 'show', @show
        @bind 'hide', @hide

    setTimeout: (time, callback) ->
        clearTimeout(@timeout) if @timeout?
        @timeout = setTimeout =>
            delete @timeout
            callback?.call(this)
        ,time

    show: (callback) =>
        @ready =>
            return unless @active
#             @trigger 'update:el', @tpl
#             @setTimeout 60, => # workaround for requestAnimationFrame
#                 @delegateEvents() # workaround to reconnect all dom events
#                 @el.show()
#                 callback?.call(this)
            @el.show()
            callback?.call(this)

    hide: =>
#         return if @active
#         @trigger 'update:el', new Tag "div", class:'editbar'

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
#         @bind('template:create', (@tpl) => )
        super ->
            @$el.css left:"234px"
            @trigger 'loading:stop'
            callback?.call(this)

    begin: =>
        app.emit 'editmode', on
        @show =>
            @$el.css left:"0px"
            $('html').addClass('editmode')
            @parent.$('*').each @makeEditable

    end: =>
        app.emit 'editmode', off
        $('html').removeClass('editmode')
        @parent.$('.dangerZone').removeClass('.dangerZone') # FIXME
        @parent.$('*').each @undoEditable
        @$el.css left:"234px"
        @setTimeout(410, @hide)

        @trigger 'end'

    clickSave: EventHandler ->
        # set_node_metadata() takes 1 round-trip, hide buttons in the
        # meanwhile:
        @$('.save, .cancel').fadeOut(200)
        @trigger 'loading:start'

        # Retrieve values
        console.warn "parent el", @parent.el
        # FIXME: title text sometimes contains the title of the next channel too!
        title = @parent.$('header .title').text()
        console.warn "title", @parent.$('header .title'), title
        status = @parent.$('header .status').text()
        description = @parent.$('.meta .description .data').text()
        console.warn "description", @parent.$('.meta .description .data'), description
        # FIXME: #accessModel and #allowPost selectors will break
        # whenever multiple ChannelViews are rendered yet hidden.
        open = @parent.$('#accessModel').prop 'checked'
        access_model = if open then 'open' else 'authorize'
        publish_model = 'publishers'
        default_affiliation = if @$('#allowPost').prop('checked') then 'publisher' else 'member'
        console.warn "default_affiliation", default_affiliation

        # Send to server
        async.parallel [ (cb) =>
            # Full metadata for posts node
            postsnode = @model.nodes.get_or_create id: 'posts'
            app.handler.data.set_node_metadata postsnode
            , { title, description, access_model, publish_model, default_affiliation }
            , cb
        , (cb) =>
            # Access model metadata for status node
            statusnode = @model.nodes.get_or_create id: 'status'
            app.handler.data.set_node_metadata statusnode
            , { access_model, publish_model: 'publishers', default_affiliation: 'member' }
            , cb
        , (cb) =>
            # Update status
            statusnode = @model.nodes.get_or_create id: 'status'
            # TODO: id=current to have only one post in status node
            app.handler.data.publish statusnode
            , { content: status, author: { name: app.users.current.get 'jid' } }
            , cb
        , (cb) =>
            # Subscriptions node
            subsnode = @model.nodes.get_or_create id: 'subscriptions'
            app.handler.data.set_node_metadata subsnode
            , { access_model, publish_model: 'publishers', default_affiliation: 'member' }
            , cb
        ], (err) =>
            @$('.save, .cancel').show()
            @trigger 'loading:stop'
            if err
                # Undo values:
                @clickCancel()
                # Even if some operations were successful we're
                # going to get updates pushed afterwards
            else
                # Committed fine:
                @turn off

    clickCancel: EventHandler ->
        node = @model.nodes.get_or_create id: 'posts'
        # Cause metadata re-render:
        node.metadata.trigger 'change'
        @parent.update_status()

        @turn off

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
                preventEmptyness.call(el)
            when 'multiLine'
                el
                    .prop('contenteditable', yes)
                    .input(preventEmptyness)
                preventEmptyness.call(el)
            when 'boolean'
                text = el.text()
                # Last class becomes id -- dummy comment added for Simon
                elClasses = el.prop('class').split(' ')
                id = elClasses[elClasses.length - 1]
                el
                    .addClass('contenteditable')
                    .html('<input type="checkbox" style="display:none;"><label></label>')
                el.find('input').attr('id', id)
                el.find('label')
                    .attr('for', id)
                    .text(text)

                if id is 'accessModel'
                    if text is 'open' or text is helptextOpenmode
                        el.find('input').prop('checked', yes)
                    update = ->
                        if el.find('input').prop('checked')
                            el.find('label').text(helptextOpenmode)
                        else
                            el.find('label').text(helptextPrivatemode)
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

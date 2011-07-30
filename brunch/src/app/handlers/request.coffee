# TODO depends on client type and connection
#   (is it mobile, or small data capacity?)
MAX_REQUESTS = 64

# TODO add priorities to send requests in the right order to produce a better ux feeling

# throttles requests
class exports.RequestHandler extends Backbone.EventHandler
    constructor: ->
        @bind 'next', @next
        @bind 'task:start', @start
        @limit = MAX_REQUESTS
        @running = 0
        @queue = []
        @request.handler = this
        return @request # turns the result of "new RequestHandler" into a funcion

    request: (task) =>
        @queue.push task
        @trigger 'next'

    start: (task) =>
        app.debug "start task", {task}
        task @_on_task_done

    next: =>
        while @running < @limit
            return if @queue.length is 0
            task = @queue.shift()
            @trigger 'task:start', task
            @running++

    _on_task_done: =>
        @trigger 'next'
        @running--

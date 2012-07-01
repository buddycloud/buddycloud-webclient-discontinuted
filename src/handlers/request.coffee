S4 = Store.S4
# TODO depends on client type and connection
#   (is it mobile, or small data capacity?)
MAX_REQUESTS = 128

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

    start: (task, id) =>
        triggered = no
        console.log "[#{id}] start task"
        task =>
            @running-- unless triggered
            console.log "[#{id}] task done. (#{@running} left)"
            triggered = yes
            @trigger 'next'

    next: =>
        while @queue.length > 0 and @running < @limit
            task = @queue.shift()
            @trigger 'task:start', task, S4()
            @running++


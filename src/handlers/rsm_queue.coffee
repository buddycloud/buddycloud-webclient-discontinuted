class exports.RSMQueue
    constructor: (@name, @req_cb) ->
        @queued = {}

    add: (node, cb) ->
        id = node.get('nodeid') or node.get('id')
        if @queued.hasOwnProperty(id)
            @queued[id].push cb

        else
            rsm_info = node["#{@name}_rsm"]
            if rsm_info and rsm_info.end_reached
                cb(null, [])

            else
                @queued[id] = [cb]
                console.warn "rsm", @name, id, rsm_info?.last
                @req_cb id, rsm_info?.last, (err, results) =>
                    console.warn "rsm", @name, id, results?.length

                    if not results?.rsm?.last? or rsm_info?.last is results?.rsm?.last
                        node["#{@name}_rsm"] = { end_reached: yes }
                        end_reached = yes
                    else
                        node["#{@name}_rsm"] = { last: results?.rsm?.last }
                        end_reached = no

                    queued = @queued[id]
                    delete @queued[id]

                    for cb1 in queued
                        cb1?(err, results, end_reached)

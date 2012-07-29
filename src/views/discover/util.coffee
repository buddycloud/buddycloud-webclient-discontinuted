
exports.channels_to_collection = (model, method, args...) ->
    {connector} = app.handler
    connector[method].call connector, args..., (err, jids) ->
        if jids
            for jid in jids
                # Some queries return nodes not jids:
                if (m = jid.match(/\/user\/([^\/]+)/))
                    jid = m[1]
                unless model.get(jid)?
                    model.add app.channels.get_or_create(id: jid)

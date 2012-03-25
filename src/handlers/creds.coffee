exports.getCredentials = ->
    try
        JSON.parse localStorage.getItem 'credentials'
    catch e
        console.error e
        undefined

exports.setCredentials = (creds) ->
    if creds?
        localStorage.setItem 'credentials', JSON.stringify(creds)
    else
        localStorage.removeItem 'credentials'

invalidJidCharacters =
    '\x20':  'space'        # keyCode 32 
    '\x22':  'double-quote' # keyCode 34
    '\x26':  '&'            # keyCode 38
    '\x27':  "single-quote" # keyCode 39
    '\x2F':  '/'            # keyCode 47
    '\x3A':  ':'            # keyCode 58
    '\x3C':  '<'            # keyCode 60
    '\x3E':  '>'            # keyCode 62
    '\x40':  '@'            # keyCode 64
    '\x7F':  'delete'       # keyCode 127

getJidErrors = (jid) ->
    # return false if jid is valid
    # otherwise a string of errors
    badCharacters = []
    for ascii, name of invalidJidCharacters
        if jid.match ascii 
            if ascii isnt '\x40' or (jid.split(/@/g).length isnt 2)
                badCharacters.push name
    if badCharacters.length is 0
        return false
    console.log "Bad characters in JID", badCharacters
    return badCharacters

module.exports = { 
    getJidErrors
    invalidJidCharacters
}
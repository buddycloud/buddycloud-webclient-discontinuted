
# [1,2,1,3] becomes [1,2,3]
set = (array = [], o = {}) ->
    o[k] = 0 for k in array
    Object.keys(o)

exports.invalidJIDCharacters = invalid_chars =
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

invalid = new RegExp("(#{Object.keys(invalid_chars).join '|'})", 'g')

exports.validateJID = (jid) ->
    # return false if jid is valid
    # otherwise a string of errors
    jid = "#{jid}".replace('@',"") # replace one @ for the domain
    badCharacters = set(jid.match(invalid)).map((c) -> invalid_chars[c])
    return null if badCharacters.length is 0
    console.log "Bad characters in JID", badCharacters
    return badCharacters


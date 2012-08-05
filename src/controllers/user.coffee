invalidJidCharacters =
    'x20':  'space'  # keyCode 32 
    'x22':  '"'      # keyCode 34
    'x26':  '&'      # keyCode 38
    'x27':  "'"      # keyCode 39
    'x2F':  '/'      # keyCode 47
    'x3A':  ':'      # keyCode 58
    'x3C':  '<'      # keyCode 60
    'x3E':  '>'      # keyCode 62
    'x40':  '@'      # keyCode 64
    'x7F':  'delete' # keyCode 127

getJidErrors: (jid) ->
    # rturn f alse if jid is valid
    # otherwise a string of errors
    return " you used bad characters"

module.exports = { 
    invalidJidCharacters,
    getJidErrors
}
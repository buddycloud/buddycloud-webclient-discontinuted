

exports.transEndEventNames = transEndEventNames =
    'WebkitTransition' : 'webkitTransitionEnd'
    'MozTransition'    : 'transitionend'
    'OTransition'      : 'oTransitionEnd'
    'msTransition'     : 'MSTransitionEnd'
    'transition'       : 'transitionend'
exports.transitionendEvent = transEndEventNames[Modernizr.prefixed('transition')]


exports.gravatar = (mail) ->
    opts = s:50, d:'retro'
    hash = MD5.hexdigest mail?.toLowerCase?() or ""
    "https://secure.gravatar.com/avatar/#{hash}?" + $.param(opts)

exports.EventHandler = (handler) ->
    return (ev) ->
        ev?.preventDefault?()
        handler.apply(this, arguments)
        no


# /user/u@catz.net/posts → ["/user/u@catz.net/", "u@catz.net"]
NODEID_TO_USER_REGEX = /\/user\/([^\/]+@[^\/]+)\//
exports.nodeid_to_user = (nodeid) ->
    nodeid?.match?(NODEID_TO_USER_REGEX)?[1] # jid


# "/user/:jid/posts/stuff" → ["/user/:jid/posts", ":jid", "channel"]
NODEID_TO_TYPE_REGEX = /\/user\/([^\/]+)\/([^\/]+)/
exports.nodeid_to_type = (nodeid) ->
    nodeid?.match?(NODEID_TO_TYPE_REGEX)?[2] # type

exports.compare_by_id = (model1, model2) ->
    id1 = model1.get 'id'
    id2 = model2.get 'id'
    if id1 < id2
        -1
    else if id1 > id2
        1
    else
        0


URLS_REGEX = ///^
    (.*?) # Beginning of text
    (?:
        # Crazy regexp for matching URLs.
        # Based on http://daringfireball.net/2010/07/improved_regex_for_matching_urls
        #   plus changed some '(' to '(?:'.
        \b((?:[a-z][\w-]+:(?:/{1,3}|[a-z0-9%])|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}/)(?:[^\s()<>]+|\((?:[^\s()<>]+|(?:\([^\s()<>]+\)))*\))+(?:\((?:[^\s()<>]+|(?:\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'".,<>?«»“”‘’]))
        #' <-- fix syntax highlighting...
        |
        # JID (or e-mail address not starting with mailto:)
        \b(\S+@[a-zA-Z0-9_\-\.]+)\b
    )
    (.*) # End of text
    $///
exports.parse_post = (content = "") ->
    # Trim leading & trailing whitespace:
    if content.trim?
        content = content.trim()

    parts = []
    for line in content.split(/\n/)
        while line.length > 0
            if (m = line.match(URLS_REGEX, "i"))
                if m[1]
                    parts.push
                        type: 'text'
                        value: m[1]
                if m[2]
                    parts.push
                        type: 'link'
                        value: m[2]
                if m[3]
                    parts.push
                        type: 'user'
                        value: m[3]
                line = m[4] or ""
            else
                parts.push
                    type: 'text'
                    value: line
                line = ""
        # Restore line break
        parts.push
            type: 'text'
            value: "\n"
    return parts


##
# Delay a callback by `interval' ms, while avoiding calling it
# multiple times successively.
exports.throttle_callback = (interval, callback) ->
    timeout = null
    # We return a proxy callback:
    return () ->
        that = this
        args = arguments
        # None yet scheduled?
        unless timeout
            timeout = setTimeout ->
                timeout = null
                callback?.apply that, args
            , interval



exports.getBrowserPrefix  = getBrowserPrefix = () ->
    regex = /^(Moz|Webkit|Khtml|O|ms|Icab)(?=[A-Z])/
    tester = document.getElementsByTagName('script')[0]
    prefix = ""
    for prop in tester.style
        if regex.test prop
            prefix = prop.match(regex)[0]
            break
    prefix = 'Webkit' if 'WebkitOpacity' in tester.style
    prefix ? "-#{prefix.charAt(0).toLowerCase() + prefix.slice(1)}-"

exports.transEndEventNames = transEndEventNames =
    '-webkit-transition' : 'webkitTransitionEnd'
    '-moz-transition' : 'transitionend'
    '-o-transition' : 'oTransitionEnd'
    'transition' : 'transitionEnd'

exports.transitionendEvent = transEndEventNames[getBrowserPrefix()+'transition']

exports.gravatar = (mail, opts) ->
    hash = MD5.hexdigest mail?.toLowerCase() or ""
    "https://secure.gravatar.com/avatar/#{hash}?" + $.param(opts)

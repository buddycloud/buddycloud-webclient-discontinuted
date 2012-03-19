
{ Template } = require 'dynamictemplate'

module.exports = ({jid}) ->
    return new Template schema:5, ->
        @$div class:'loading',  "loading #{jid} ..."

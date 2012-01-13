
{ Template } = require 'dynamictemplate'
jqueryify = require 'dt-jquery'

module.exports = ({jid}) ->
    return jqueryify new Template schema:5, ->
        @$div class:'loading',  "loading #{jid} ..."

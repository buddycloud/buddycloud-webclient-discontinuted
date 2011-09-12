
/**
* File: strophe.register.js
* A Strophe plugin for XMPP In-Band Registration.
*/
Strophe.addConnectionPlugin('presence', {
    _connection: null,

    //The plugin must have the init function.
    init: function(conn) {
        this._connection = conn;
    },

    set: function (opts) {
        opts = opts || {};
        this._connection.send($pres()
            .c('status')  .t(opts.status || "N/A").up()
            .c('show')    .t(opts.show   || "na" ).up()
            .c('priority').t("" + (opts.priority || -1))
        );
    },

});

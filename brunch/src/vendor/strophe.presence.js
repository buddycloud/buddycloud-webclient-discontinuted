
/**
* File: strophe.register.js
* A Strophe plugin for XMPP In-Band Registration.
*/
Strophe.addConnectionPlugin('presence', {
    _connection: null,

    //The plugin must have the init function.
    init: function(conn) {
        this._connection = conn;

	var subscribeHandlers = this.subscribeHandlers = [];
	conn.addHandler(function(stanza) {
	    var handlerResult, from = stanza.getAttribute('from');
	    if (subscribeHandlers.some(function(handler) {
		handlerResult = handler(stanza);
		if (handlerResult === true) {
		    return true;
		} else if (handlerResult === false) {
		    return true;
		} else
		    return false;
	    })) {
		conn.send(
		    $pres({ to: from, type: (handlerResult ? 'subscribed' : 'unsubscribed') })
		);
	    }
	}, null, 'presence', 'subscribe');
    },

    addSubscribeHandler: function(handler) {
	this.subscribeHandlers.push(handler);
    },

    authorize: function(jid) {
	this._connection.send(
	    $pres({ to: jid, type: 'subscribed' })
	);
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

var stub = function() {};
if (!window.console)
    window.console = { log: stub, info: stub, warn: stub, error: stub };

/*Strophe.log = function(level, msg) {
    console.log('Strophe ' + level + ': ' + msg);
};*/

window.Channels = {};

window.Channels.Client = function(jid, password) {
    var that = this;

    this.lastId = Math.ceil(Math.random() * 999999);
    this.roster = {};
    this.discovery = new window.Channels.Discovery(this);

    this.conn = new Strophe.Connection('/http-bind/');

    this.requests = {};
    this.conn.addHandler(function(stanza) {
	/*console.log('<<< ' + Strophe.serialize(stanza));*/
	that.receive(stanza);
	return true;
    });

    /* TODO: memorize for later reconnect */
    this.conn.connect(jid, password, function(status) {
	console.log({connStatus:status});
	switch(status) {
	    case Strophe.Status.CONNECTED:
		that.getRoster(function() {
		    that.discovery.start();
		});
		that.conn.send($pres().c('status').t('buddycloud channels!'));
		that.onConnect();
		break;
	    case Strophe.Status.DISCONNECTED:
		that.onDisconnect();
		break;
	}
    });
};
window.Channels.Client.prototype = {
    constructor: window.Channels.Client,

    onConnect: stub,
    onDisconnect: stub,
    onUpdate: stub,

    receive: function(stanza) {
	var id = stanza.getAttribute('id');
	if (stanza.nodeName === 'iq' &&
	    this.requests.hasOwnProperty(id)) {

	    if (stanza.getAttribute('type') === 'result') {
		this.requests[id](null, stanza);
		delete this.requests[id];
	    } else if (stanza.getAttribute('type') === 'error') {
		this.requests[id](stanza);
		delete this.requests[id];
	    }
	}
    },

    request: function(stanza, cb) {
	var that = this;

	stanza = stanza.tree();
	var id = this.lastId.toString();
	this.lastId++;
	stanza.setAttribute('id', id);
	this.conn.send(stanza);
	this.requests[id] = cb;
	window.setTimeout(function() {
	    if (that.requests[id]) {
		delete that.requests[id];
		cb(new Error('timeout'));
	    }
	}, 10000);
    },

    getRoster: function(cb) {
	var that = this;
	this.request($iq({ type: 'get' }).c('query', { xmlns: Strophe.NS.ROSTER }),
	    function(err, reply) {
		var queryEl = reply && reply.getElementsByTagName('query')[0];
		if (queryEl) {
		    that.roster = {};
		    var itemEls = queryEl.getElementsByTagName('item');
		    for(var i = 0; i < itemEls.length; i++) {
			var itemEl = itemEls[i];
			that.roster[itemEl.getAttribute('jid')] = itemEl;
		    }
		}
		if (cb)
		    cb();
	    });
    }
};

var NS_DISCO_ITEMS = 'http://jabber.org/protocol/disco#items',
    NS_DISCO_INFO = 'http://jabber.org/protocol/disco#info';

window.Channels.Discovery = function(client) {
    this.domainsBrowsed = {};
    this.domainsDiscovered = {};
    this.domainServices = {};
    this.client = client;
};
window.Channels.Discovery.prototype = {
    start: function() {
	for(var jid in this.client.roster) {
	    var domain = Strophe.getDomainFromJid(jid);
	    this.browseDomain(domain);
	}
    },

    /** browse for #items */
    browseDomain: function(jid) {
	var that = this;
	if (!this.domainsBrowsed.hasOwnProperty(jid)) {
	    console.log('browseDomain '+jid);
	    this.client.request($iq({ to: jid,
				      type: 'get' }).
				c('query', { xmlns: NS_DISCO_ITEMS }),
				function(err, reply) {
	        var queryEl = reply && reply.getElementsByTagName('query')[0];
		if (queryEl) {
		    var itemEls = queryEl.getElementsByTagName('item');
		    for(var i = 0; i < itemEls.length; i++) {
			var itemEl = itemEls[i];
			that.discoverDomain(itemEl.getAttribute('jid'));
		    }
		}
	    });
	    this.domainsBrowsed[jid] = true;
	}
    },

    /** disco with #info for <identity/> */
    discoverDomain: function(jid) {
	var that = this;
	if (!this.domainsDiscovered.hasOwnProperty(jid)) {
	    console.log('discoverDomain '+jid);
	    this.client.request($iq({ to: jid,
				      type: 'get' }).
				c('query', { xmlns: NS_DISCO_INFO }),
				function(err, reply) {
	        var queryEl = reply && reply.getElementsByTagName('query')[0];
		if (queryEl) {
		    var identityEls = queryEl.getElementsByTagName('identity');
		    for(var i = 0; i < identityEls.length; i++) {
			var identityEl = identityEls[i];
			var category = identityEl.getAttribute('category');
			var type = identityEl.getAttribute('type');
			console.log(jid + ': ' +
				    category + '/' + type);
			if (category === 'pubsub' && type === 'channels') {
			    /* TODO */
			}
		    }
		}
	    });
	    this.domainsDiscovered[jid] = true;
	}
    }
};


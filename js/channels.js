var IQ_TIMEOUT = 10000;
Strophe.addNamespace('PUBSUB', "http://jabber.org/protocol/pubsub");

var stub = function() {};
if (!window.console)
    window.console = { log: stub, info: stub, warn: stub, error: stub };

/*Strophe.log = function(level, msg) {
    console.log('Strophe ' + level + ': ' + msg);
};*/

var Channels = {};

/**
 * XmppClient implements the basic protocols.
 */
Channels.XmppClient = function(jid, password) {
    EventEmitter.call(this);
    var that = this;

    this.conn = new Strophe.Connection('/http-bind/');

    this.conn.addHandler(function(stanza) {
	/*console.log('<<< ' + Strophe.serialize(stanza));*/
	/*that.receive(stanza);*/
	return true;
    });

    /* TODO: memorize for later reconnect */
    this.conn.connect(jid, password, function(status) {
	console.log({connStatus:status});
	switch(status) {
	    case Strophe.Status.CONNECTED:
		that.emit('online');
		that.onConnect();
		break;
	    case Strophe.Status.DISCONNECTED:
		that.onDisconnect();
		break;
	}
    });
};
Channels.XmppClient.prototype = Object.create(EventEmitter.prototype);
Channels.XmppClient.prototype.constructor = Channels.Client;

Channels.XmppClient.prototype.request = function(stanza, callback, errback) {
    this.conn.sendIQ(stanza, function(reply) {
	if (callback)
	    callback(reply);
    }, function(error) {
	if (errback)
	    errback(error);
    }, IQ_TIMEOUT);
};

/**
 * cb(error, [{ jid: String, name: String }])
 */
Channels.XmppClient.prototype.getRoster = function(cb) {
    this.request($iq({ type: 'get' }).c('query', { xmlns: Strophe.NS.ROSTER }),
    function(reply) {
	var results = [];
	var queryEl = reply && reply.getElementsByTagName('query')[0];
	if (queryEl) {
	    var itemEls = queryEl.getElementsByTagName('item');
	    for(var i = 0; i < itemEls.length; i++) {
		var itemEl = itemEls[i];
		results.push({ jid: itemEl.getAttribute('jid'),
			       name: itemEl.getAttribute('name')
		});
	    }
	}
	cb(null, results);
    }, function(reply) {
	cb(new Error('Failed to get roster'));
    });
};

/** browse for #items
 * 
 * cb(error, [{ jid: String, node: String }])
 */
Channels.XmppClient.prototype.discoInfo = function(jid, node, cb) {
    this.request($iq({ to: jid,
		       type: 'get' }).
		 c('query', { xmlns: Strophe.NS.DISCO_ITEMS,
			      node: node }),
    function(reply) {
	var results = [];
	var queryEl = reply && reply.getElementsByTagName('query')[0];
	if (queryEl) {
	    var itemEls = queryEl.getElementsByTagName('item');
	    for(var i = 0; i < itemEls.length; i++) {
		var itemEl = itemEls[i];
		results.push({ jid: itemEl.getAttribute('jid'),
			       node: itemEl.getAttribute('node')
		});
	    }
	}
    });
};

/** disco with #info for <identity/>
 * 
 * cb(error, { identities: [{ category: String, type: String }], 
 *             features: [String] })
 */
Channels.XmppClient.prototype.discoItems = function(jid, node, cb) {
    this.request($iq({ to: jid,
		       type: 'get' }).
		 c('query', { xmlns: Strophe.NS.DISCO_INFO,
			      node: node }),
    function(reply) {
	var result = { identities: [], features: [] };
	var queryEl = reply && reply.getElementsByTagName('query')[0];
	if (queryEl) {
	    var identityEls = queryEl.getElementsByTagName('identity');
	    for(var i = 0; i < identityEls.length; i++) {
		var identityEl = identityEls[i];
		result.identities.push({ category: identityEl.getAttribute('category'),
					 type: identityEl.getAttribute('type')
				       });
	    }
	}
    });
};

/**
 * High-level channels logic
 */
Channels.ChannelsClient = function(jid, password) {
    Channels.XmppClient.apply(this, arguments);
    var that = this;

    this.on('online', function() {
	that.conn.send($pres().c('status').t('buddycloud channels'));
	that.findHomeServices();
    });
};
Channels.ChannelsClient.prototype = Object.create(Channels.XmppClient.prototype);
Channels.ChannelsClient.prototype.constructor = Channels.ChannelsClient;

/** cb([String]) */
Channels.ChannelsClient.prototype.findChannelServices = function(domain, cb) {
    var that = this;
    this.discoItems(domain, null, function(err, items) {
	if (err) {
	    cb([]);
	    return;
	}

	var pending = 1, results = [], done = function() {
	    pending--;
	    if (pending < 1)
		cb(results);
	};
	for(var i = 0; i < items.length; i++) {
	    var item = items[i];
	    if (!item.node) {
		that.discoInfo(item.jid, item.node, (function(jid) {
		    return function(err, result) {
			if (result && result.identities)
			    for(var j = 0; j < result.identities.length; j++) {
				var identity = result.identities[j];
				if (identity.category === 'pubsub' &&
				    identity.type === 'channels')
				    results.push(jid);
			    }
			done();
		    };
		})(item.jid));
		pending++;
	    }
	}
	next();
    });
};

Channels.ChannelsClient.prototype.findHomeServices = function() {
    var that = this;
    var myServer = Strophe.getDomainFromJid(this.conn.jid);
    this.findChannelServices(myServer, function(jids) {
	if (jids.length > 0) {
	    that.initHomeServices(jids);
	} else
	    that.findChannelServices('buddycloud.com', function(jids) {
		if (jids.length > 0) {
		    that.initHomeServices(jids);
		} else
		    that.emit('error', 'Cannot find channel services on the network');
	    });
    });
};

Channels.ChannelsClient.prototype.initHomeServices = function(jids) {
    this.homeServices = jids;
};

/**
 * Represents a channel-server instance
 */
Channels.Service = function(client, jid) {
    this.client = client;
    this.jid = jid;
    this.nodes = {};
};
Channels.Service.prototype = {
    
};

Channels.Node = function(service, name) {
    this.name = name;
    this.affiliation = 'none';
    this.subscription = 'none';
};
Channels.Node.prototype = {
    
};

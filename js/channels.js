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
	return true;
    });

    /* TODO: memorize for later reconnect */
    this.conn.connect(jid, password, function(status) {
	console.log({connStatus:status});
	switch(status) {
	    case Strophe.Status.CONNECTED:
		that.emit('online');
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
Channels.XmppClient.prototype.discoItems = function(jid, node, cb) {
    var queryAttrs = { xmlns: Strophe.NS.DISCO_ITEMS };
    if (node)
	queryAttrs.node = node;
    this.request($iq({ to: jid,
		       type: 'get' }).
		 c('query', queryAttrs),
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
	cb(null, results);
    }, function(reply) {
	cb(new Error());
    });
};

/** disco with #info for <identity/>
 * 
 * cb(error, { identities: [{ category: String, type: String }], 
 *             features: [String] })
 */
Channels.XmppClient.prototype.discoInfo = function(jid, node, cb) {
    var queryAttrs = { xmlns: Strophe.NS.DISCO_INFO };
    if (node)
	queryAttrs.node = node;
    this.request($iq({ to: jid,
		       type: 'get' }).
		 c('query', queryAttrs),
    function(reply) {
	var i, result = { identities: [], features: [] };
	var queryEl = reply && reply.getElementsByTagName('query')[0];
	if (queryEl) {
	    var identityEls = queryEl.getElementsByTagName('identity');
	    for(i = 0; i < identityEls.length; i++) {
		var identityEl = identityEls[i];
		result.identities.push({ category: identityEl.getAttribute('category'),
					 type: identityEl.getAttribute('type')
				       });
	    }
	    var featureEls = queryEl.getElementsByTagName('feature');
	    for(i = 0; i < featureEls.length; i++)
		result.features.push(featureEls[i].getAttribute('var'));
	}
	cb(null, result);
    }, function(reply) {
	cb(new Error());
    });
};

/**
 * PubSub queries
 */

Channels.XmppClient.prototype.getSubscriptions = function(jid, cb) {
    this.request($iq({ to: jid,
		       type: 'get' }).
		 c('pubsub', { xmlns: Strophe.NS.PUBSUB }).
		 c('subscriptions'),
    function(reply) {
	var subscriptions = [];
	var pubsubEl = reply && reply.getElementsByTagName('pubsub')[0];
	var subscriptionsEl = pubsubEl && pubsubEl.getElementsByTagName('subscriptions')[0];
	if (subscriptionsEl) {
	    var subscriptionEls = subscriptionsEl.getElementsByTagName('subscription');
	    for(var i = 0; i < subscriptionEls.length; i++) {
		var subscriptionEl = subscriptionEls[i];
		subscriptions.push({ node: subscriptionEl.getAttribute('node'),
				     subscription: subscriptionEl.getAttribute('subscription')
				   });
	    }
	}
	cb(null, subscriptions);
    }, function(reply) {
	cb(new Error());
    });
};

Channels.XmppClient.prototype.getAffiliations = function(jid, cb) {
    this.request($iq({ to: jid,
		       type: 'get' }).
		 c('pubsub', { xmlns: Strophe.NS.PUBSUB }).
		 c('affiliations'),
    function(reply) {
	var affiliations = [];
	var pubsubEl = reply && reply.getElementsByTagName('pubsub')[0];
	var affiliationsEl = pubsubEl && pubsubEl.getElementsByTagName('affiliations')[0];
	if (affiliationsEl) {
	    var affiliationEls = affiliationsEl.getElementsByTagName('affiliation');
	    for(var i = 0; i < affiliationEls.length; i++) {
		var affiliationEl = affiliationEls[i];
		affiliations.push({ node: affiliationEl.getAttribute('node'),
				    affiliation: affiliationEl.getAttribute('affiliation')
				   });
	    }
	}
	cb(null, affiliations);
    }, function(reply) {
	cb(new Error());
    });
};

/**
 * High-level channels logic
 */
Channels.ChannelsClient = function(jid, password) {
    Channels.XmppClient.apply(this, arguments);
    var that = this;

    this.services = {};

    this.on('online', function() {
	that.conn.send($pres().c('status').t('buddycloud channels'));
	that.findHomeServices();
    });
};
Channels.ChannelsClient.prototype = Object.create(Channels.XmppClient.prototype);
Channels.ChannelsClient.prototype.constructor = Channels.ChannelsClient;

Channels.ChannelsClient.prototype.getService = function(jid) {
    if (!this.services.hasOwnProperty(jid)) {
	console.log('newService ' + jid);
	this.services[jid] = new Channels.Service(this, jid);
	this.emit('newService', this.services[jid]);
    }
    return this.services[jid];
};

/** cb([String]) */
Channels.ChannelsClient.prototype.findChannelServices = function(domain, cb) {
    console.log('findChannelServices '+domain);
    var that = this;
    this.discoItems(domain, null, function(err, items) {
	if (err || !items) {
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
			if (result && result.identities) {
			    for(var j = 0; j < result.identities.length; j++) {
				var identity = result.identities[j];
				if (identity.category === 'pubsub' &&
				    identity.type === 'channels')
				    results.push(jid);
			    }
			}
			done();
		    };
		})(item.jid));
		pending++;
	    }
	}
	/* pending was initialized with 1 to catch empty results */
	done();
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
    console.log('Home Services: ' + jids.join(', '));
    this.homeServices = jids;
    for(var i = 0; i < jids.length; i++)
	this.getService(jids[i]);
};

/**
 * Represents a channel-server instance
 */
Channels.Service = function(client, jid) {
    var that = this;
    EventEmitter.call(this);

    this.client = client;
    this.jid = jid;
    this.nodes = {};

    setTimeout(function() {
	that.updateSubscriptions();
	that.updateAffiliations();
    }, 10);
};
Channels.Service.prototype = Object.create(EventEmitter.prototype);
Channels.Service.prototype.constructor = Channels.Service;

Channels.Service.prototype.getNode = function(name) {
    if (!this.nodes.hasOwnProperty(name)) {
	console.log('newNode ' + this.jid + ' ' + name);
	this.nodes[name] = new Channels.Node(this, name);
	this.emit('newNode', this.nodes[name]);
    }
    return this.nodes[name];
};

Channels.Service.prototype.updateSubscriptions = function() {
    var that = this;
    this.client.getSubscriptions(this.jid, function(err, subscriptions) {
	if (!subscriptions)
	    return;
	/* TODO: handle err, mark unseen as none */
	for(var i = 0; i < subscriptions.length; i++) {
	    var node = that.getNode(subscriptions[i].node);
	    node.subscription = subscriptions[i].subscription;
	    node.emit('update');
	}
    });
};

Channels.Service.prototype.updateAffiliations = function() {
    var that = this;
    this.client.getAffiliations(this.jid, function(err, affiliations) {
	if (!affiliations)
	    return;
	/* TODO: handle err, mark unseen as none */
	for(var i = 0; i < affiliations.length; i++) {
	    var node = that.getNode(affiliations[i].node);
	    node.affiliation = affiliations[i].affiliation;
	    node.emit('update');
	}
    });
};

Channels.Node = function(service, name) {
    EventEmitter.call(this);

    this.name = name;
    this.affiliation = 'none';
    this.subscription = 'none';
};
Channels.Node.prototype = Object.create(EventEmitter.prototype);
Channels.Node.prototype.constructor = Channels.Node;


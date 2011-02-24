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

/** cb(error, [{ id: String, elements: [...] }]) */
Channels.XmppClient.prototype.getItems = function(jid, node, cb) {
    this.request($iq({ to: jid,
		       type: 'get' }).
		 c('pubsub', { xmlns: Strophe.NS.PUBSUB }).
		 c('items', { node: node }),
    function(reply) {
	var items = [];
	var pubsubEl = reply && reply.getElementsByTagName('pubsub')[0];
	var itemsEl = pubsubEl && pubsubEl.getElementsByTagName('items')[0];
	var itemEls = itemsEl && itemsEl.getElementsByTagName('item');
	if (itemEls) {
	    for(var i = 0; i < itemEls.length; i++) {
		var itemEl = itemEls[i];
		items.push({ id: itemEl.getAttribute('id'),
			     elements: itemEl.childNodes
			   });
	    }
	}
	cb(null, items);
    }, function(reply) {
	cb(new Error());
    });
};

/**
 * !!!
 */
var cl = new Channels.XmppClient('astro@hq.c3d2.de', '***');


Channels.Store = function() {
};
_.extend(Channels.Store, {
    save: function() {
	throw 'Not implemented';
    },

    create: function(model) {
	throw 'Not implemented';
	return model;
    },

    update: function(model) {
	throw 'Not implemented';
    },

    find: function(model) {
	throw 'Not implemented';
    },

    findAll: function() {
	throw 'Not implemented';
    },

    destroy: function(model) {
	throw 'Not implemented';
    }

});

Backbone.sync = function() {
};

window.channelEvents = new EventEmitter();

window.Item = Backbone.Model.extend({
});
window.Items = Backbone.Collection.extend({
    model: window.Item,
    localStorage: new Channels.Store()
});

window.Node = Backbone.Model.extend({
    localStorage: new Channels.Store(),

    initialize: function() {
	var that = this;
	this.set({ items: new window.Items() });
	cl.getItems(this.get('service').get('id'), this.get('id'), function(err, items) {
	    _.forEach(items, function(item) {
		that.get('items').create({ id: item.id, elements: item.elements });
	    });
	});

	window.channelEvents.emit('newNode', this);
    }
});

window.Service = Backbone.Model.extend({
    initialize: function() {
	var jid = this.get('id');
	this.nodes = {};

	var that = this;
	cl.getSubscriptions(jid, function(err, subscriptions) {
	    _.forEach(subscriptions, function(subscription) {
		that.getNode(subscription.node).set({ subscription: subscription.subscription });
	    });
	});
	cl.getAffiliations(jid, function(err, affiliations) {
	    _.forEach(affiliations, function(affiliation) {
		that.getNode(affiliation.node).set({ affiliation: affiliation.affiliation });
	    });
	});
    },

    getNode: function(node) {
	if (this.nodes.hasOwnProperty(node))
	    return this.nodes[node];
	else
	    return (this.nodes[node] = new window.Node({ id: node, service: this }));
    }
});
cl.on('online', function() {
    new window.Service({ id: 'sandbox.buddycloud.com' });
});

window.Channel = Backbone.Collection.extend({
    initialize: function() {
	window.channelEvents.emit('newChannel', this);
    }
});

window.channels = new (Backbone.Collection.extend({
    model: window.Channel,

    initialize: function() {
	var that = this;
	window.channelEvents.on('newNode', function(node) {
	    var id = node.get('id'), m;
	    if ((m = id.match(/^\/user\/([^\/]+)/))) {
		that.create({ id: m[1] });
	    }
	});
    }
}))();


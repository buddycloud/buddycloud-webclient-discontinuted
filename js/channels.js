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
    var that = this;

    this.jid = Strophe.getBareJidFromJid(jid);
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
		that.trigger('online');
		break;
	    case Strophe.Status.DISCONNECTED:
		that.onDisconnect();
		break;
	}
    });
};
_.extend(Channels.XmppClient.prototype, Backbone.Events);

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
 * High-level channels logic
 */
Channels.ChannelsClient = function(jid, password) {
    Channels.XmppClient.apply(this, arguments);
    var that = this;

    /* { domain: { jids: [String], waiting: [Function] } } */
    this.domainServices = {};

    this.bind('online', function() {
	console.log('ChannelsClient online');
	that.conn.send($pres().c('status').t('buddycloud channels'));
    });
};
Channels.ChannelsClient.prototype = Object.create(Channels.XmppClient.prototype);
Channels.ChannelsClient.prototype.constructor = Channels.ChannelsClient;

/** 
 * Discover items of a domain and callback with the ones that have a
 * pubsub/channels identity.
 * 
 * cb([String])
 */
Channels.ChannelsClient.prototype.findChannelServices1 = function(domain, cb) {
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
				console.log(jid + ': ' + identity.category + '/' + identity.type);
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

/**
 * Cached interface to avoid duplicate queries
 */
Channels.ChannelsClient.prototype.findChannelServices = function(domain, cb) {
    var domainService;
    if (this.domainServices.hasOwnProperty(domain)) {
	domainService = this.domainServices[domain];
	if (domainService.hasOwnProperty('jids')) {
	    /* discovered before */
	    cb(domainService.jids);
	} else {
	    /* enqueue callback */
	    domainService.waiting.push(cb);
	}
    } else {
	this.domainServices[domain] = domainService =
	    { waiting: [cb] };
	this.findChannelServices1(domain, function(jids) {
	    /* cache it */
	    domainService.jids = jids;
	    /* trigger all waiting callbacks */
	    var cbs = domainService.waiting;
	    delete domainService.waiting;
	    _.forEach(cbs, function(cb) {
		cb(jids);
	    });
	});
    }
};

Channels.ChannelsClient.prototype.findUserService = function(jid, cb) {
    var that = this;
    var myServer = Strophe.getDomainFromJid(jid);
    this.findChannelServices(myServer, function(jids) {
	if (jids.length > 0) {
	    cb(jids);
	} else {
	    that.findChannelServices('buddycloud.com', cb);
	}
    });
};


/**
 * !!!
 */
var cl = new Channels.ChannelsClient('astro@hq.c3d2.de', '***');


/*Channels.Store = function() {
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

});*/

Backbone.sync = function() {
    console.log('Backbone.sync ' + _.toArray(arguments).join(', '));
};

window.Item = Backbone.Model.extend({
});
window.Items = Backbone.Collection.extend({
    model: window.Item
});

window.Node = Backbone.Model.extend({
    initialize: function() {
	var that = this;
	this.set({ items: new window.Items() });
	cl.getItems(this.get('service').get('id'), this.get('id'), function(err, items) {
	    _.forEach(items, function(item) {
		that.get('items').
		    create({ id: item.id, elements: item.elements });
	    });
	});
    }
});

window.Service = Backbone.Model.extend({
    initialize: function() {
	var jid = this.get('id');
	this.nodes = {};

	var that = this;
	cl.getSubscriptions(jid, function(err, subscriptions) {
	    _.forEach(subscriptions, function(subscription) {
		that.getNode(subscription.node).
		    set({ subscription: subscription.subscription });
	    });
	});
	cl.getAffiliations(jid, function(err, affiliations) {
	    _.forEach(affiliations, function(affiliation) {
		that.getNode(affiliation.node).
		    set({ affiliation: affiliation.affiliation });
	    });
	});
    },

    /** Adds on demand */
    getNode: function(name) {
	if (!this.nodes.hasOwnProperty(name)) {
	    var node = new window.Node({ id: name, service: this });
	    this.nodes[name] = node;
	    /* Notify potential channels */
	    this.trigger('newNode', node);
	    return node;
	} else
	    return this.nodes[name];
    }
});

window.Channel = Backbone.Model.extend({
    initialize: function() {
	console.log({newChannel:this.attributes})
    },

    addNode: function(nodeTail, node) {
	var attrs = {};
	attrs['node:' + nodeTail] = node;
	this.set(attrs);
    }
});

/**
 * Contains all the channels and performs discovery on a per-user
 * base. This forward approach ensures we always seek the responsible
 * server first before adding nodes to a channel. See hookUser().
 */
window.Channels = Backbone.Collection.extend({
    model: window.Channel,

    initialize: function() {
	this.services = {};

	var that = this;
	cl.bind('online', function() {
	    console.log('online');
	    that.hookUser(cl.jid);
	});
	/* TODO: hook roster */
    },

    /**
     * @param jid (Domain of) the service
     */
    getService: function(jid) {
	if (!this.services.hasOwnProperty(jid))
	    this.services[jid] = new window.Service({ id: jid });
	return this.services[jid];
    },

    /**
     * @param jid User
     */
    getChannel: function(jid) {
	var channel = this.get(jid);
	if (!channel) {
	    channel = new window.Channel({ id: jid });
	    this.add(channel);
	}
	return channel;
    },

    hookUser: function(user) {
	var that = this;
	var nodeHead = '/user/' + user + '/';
	cl.findUserService(user, function(serviceJids) {
	    _.forEach(serviceJids, function(serviceJid) {
		var service = that.getService(serviceJid);
		service.bind('newNode', function(node) {
		    var name = node.get('id');
		    if (name.indexOf(nodeHead) === 0) {
			var channel = that.getChannel(user);
			var nodeTail = name.substr(nodeHead.length);
			channel.addNode(nodeTail, node);
		    }
		});
	    });
	});
    }
});


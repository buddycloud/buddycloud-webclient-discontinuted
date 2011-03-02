var IQ_TIMEOUT = 10000;
Strophe.addNamespace('PUBSUB', "http://jabber.org/protocol/pubsub");
Strophe.addNamespace('PUBSUB_EVENT', "http://jabber.org/protocol/pubsub#event");
Strophe.addNamespace('DATA', "jabber:x:data");
var PUBSUB_META_DATA = "http://jabber.org/protocol/pubsub#meta-data";

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
    this.conn = new Strophe.Connection('/http-bind/');

    var that = this;
    this.conn.addHandler(function(stanza) {
	/*console.log('<<< ' + Strophe.serialize(stanza));*/

	if (stanza.tagName === 'message')
	    that.handleMessage(stanza);

	return true;
    });
};
_.extend(Channels.XmppClient.prototype, Backbone.Events);

/**
 * triggers:
 * * 'item', jid, node, id, elements
 */
Channels.XmppClient.prototype.handleMessage = function(stanza) {
    var that = this;
    var jid = stanza.getAttribute('from');
    _.forEach(stanza.getElementsByTagNameNS(Strophe.NS.PUBSUB_EVENT, 'event'),
	      function(eventEl) {
        _.forEach(eventEl.getElementsByTagNameNS(Strophe.NS.PUBSUB_EVENT, 'items'),
		  function(itemsEl) {
	    var node = itemsEl.getAttribute('node');
	    _.forEach(itemsEl.getElementsByTagNameNS(Strophe.NS.PUBSUB_EVENT, 'item'),
		      function(itemEl) {
	        var id = itemEl.getAttribute('id');
		var elements = itemEl.childNodes;
		try {
		    that.trigger('item', jid, node, id, elements);
		} catch (x) {
		    console.log(x);
		    console.error(x);
		}
	    });
	});
    });
};

Channels.XmppClient.prototype.connect = function(jid, password) {
    var that = this;

    this.jid = Strophe.getBareJidFromJid(jid);
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
 *             features: [String],
 *             forms: [ { type: 'result', fields: { ... } } ]
 *           })
 */
Channels.XmppClient.prototype.discoInfo = function(jid, node, cb) {
    var queryAttrs = { xmlns: Strophe.NS.DISCO_INFO };
    if (node)
	queryAttrs.node = node;
    this.request($iq({ to: jid,
		       type: 'get' }).
		 c('query', queryAttrs),
    function(reply) {
	var i, result = { identities: [], features: [], forms: [] };
	var queryEl = reply && reply.getElementsByTagName('query')[0];
	if (queryEl) {
	    /* Extract identities */
	    _.forEach(queryEl.getElementsByTagName('identity'),
		      function(identityEl) {
		result.identities.push({ category: identityEl.getAttribute('category'),
					 type: identityEl.getAttribute('type')
				       });
	    });
	    /* Extract features */
	    _.forEach(queryEl.getElementsByTagName('feature'),
		      function(featureEl) {
		result.features.push(featureEl.getAttribute('var'));
	    });
	    /* Extract forms */
	    _.forEach(queryEl.getElementsByTagNameNS(Strophe.NS.DATA, 'x'),
		      function(xEl) {
		var form = { type: xEl.getAttribute('type'),
			     fields: {} };
		_.forEach(xEl.getElementsByTagName('field'),
			  function(fieldEl) {
		    var key = fieldEl.getAttribute('var');
		    var values = [];
		    var type = fieldEl.getAttribute('type') || 'text-single';
		    _.forEach(fieldEl.getElementsByTagName('value'),
			      function(valueEl) {
		        values.push(valueEl.textContent);
		    });
		    if (/-multi$/.test(type))
			form.fields[key] = values;
		    else
			form.fields[key] = values[0];
		});
		result.forms.push(form);
	    });
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

Channels.XmppClient.prototype.publishItem = function(jid, node, itemId, elements, cb) {
    var iq = $iq({ to: jid,
		   type: 'set' }).
	c('pubsub', { xmlns: Strophe.NS.PUBSUB }).
	c('publish', { node: node }).
	c('item').tree();

    /* itemId is optional */
    if (itemId)
	$(iq).find('item').attr('id', itemId);

    $(iq).find('item').append(elements);

    this.request(iq, function(reply) {
	cb();
    }, function(reply) {
	cb(new Error('Publishing failed'));
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
 * cb(error, formFields)
 */
Channels.ChannelsClient.prototype.getNodeMeta = function(jid, node, cb) {
    this.discoInfo(jid, node, function(err, result) {
	if (!result) {
	    return cb(err);
	}

	var fields = {};
	_.forEach(result.forms, function(form) {
	    if (form.type === 'result' &&
		form.fields.FORM_TYPE === PUBSUB_META_DATA) {

		fields = form.fields;
	    }
	});
	cb(err, fields);
    });
};


/**
 * !!! TODO: rename to client
 */
Channels.cl = new Channels.ChannelsClient();


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

Channels.Item = Backbone.Model.extend({
    getTextContent: function() {
	var typeTexts = {};
	_.forEach(this.get('elements'), function(entryEl) {
	    _.forEach(entryEl.getElementsByTagName('content'), function(contentEl) {
		var type = contentEl.getAttribute('type') || "text";
		typeTexts[type] = $(contentEl).text();
	    });
	});
	return typeTexts.text || typeTexts.xhtml;
    },

    /**
     * @return {Date}
     */
    getPublished: function() {
	var result = undefined;
	var elements = this.get('elements');
	if (elements)
	    _.forEach(elements, function(entryEl) {
		if (!result)
		    _.forEach(entryEl.getElementsByTagName('published'),
			      function(publishedEl) {
		        var d = new Date(publishedEl.textContent);
			if (!isNaN(d))
			    result = d;
		    });
	    });
	return result;
    }
});

Channels.Items = Backbone.Collection.extend({
    model: Channels.Item,

    /**
     * Order by published time, ascending
     */
    comparator: function(item) {
	var published = item.getPublished();
	return published ? published.getTime() : 0;
    }
});

Channels.Node = Backbone.Model.extend({
    initialize: function() {
	var that = this;
	var items = new Channels.Items();
	items.bind('all', function() {
	    /* Propagate any change to the node */
	    that.trigger('change:items', that);
	});
	this.set({ items: items });

	/* Fetch items */
	Channels.cl.getItems(this.get('serviceJid'), this.get('id'), function(err, items) {
	    _.forEach(items, function(item) {
		that.setItem(item.id, item.elements);
	    });
	});
	/* Fetch meta data */
	Channels.cl.getNodeMeta(this.get('serviceJid'), this.get('id'), function(err, fields) {
	    that.set({ meta: fields });
	});
    },

    getLastItem: function() {
	var items = this.get('items');
	return items.at(items.size() - 1);
    },

    setItem: function(id, elements) {
	var items = this.get('items');
	var item;
	if ((item = items.get(id))) {
	    /* Avoid backbone views comparing DOM elements as this may
	     * be expensive and exhausts max stack level.
	     */
	    item.unset('elements');
	    item.set({ elements: elements });
	} else {
	    items.add(new Channels.Item({ id: id,
					  elements: elements }));
	}
    },

    post: function(text, cb) {
	var entry = $("<entry xmlns='http://www.w3.org/2005/Atom'><content type='text'></content><published></published></entry>");
	entry.find('content').text(text);
	entry.find('published').text(isoDateString(new Date()));

	var jid = this.get('serviceJid');
	var nodeName = this.get('id');
	Channels.cl.publishItem(jid, nodeName, null, [entry[0]], cb);
    }
});

Channels.Service = Backbone.Model.extend({
    initialize: function() {
	var jid = this.get('id');

	var that = this;
	Channels.cl.getSubscriptions(jid, function(err, subscriptions) {
	    _.forEach(subscriptions, function(subscription) {
		that.getNode(subscription.node).
		    set({ subscription: subscription.subscription });
	    });
	});
	Channels.cl.getAffiliations(jid, function(err, affiliations) {
	    _.forEach(affiliations, function(affiliation) {
		that.getNode(affiliation.node).
		    set({ affiliation: affiliation.affiliation });
	    });
	});
    },

    /** Adds on demand */
    getNode: function(name) {
	var node = this.get('node:' + name);
	if (!node) {
	    node = new Channels.Node({ id: name, serviceJid: this.get('id') });
	    var attrs = {};
	    attrs['node:' + name] = node;
	    this.set(attrs);
	}
	return node;
    },

    /**
     * @return [{ nodeTail: String, node: Channels.Node }]
     */
    getUserNodes: function(user) {
	var nameHead = 'node:/user/' + user + '/';
	var results = [];
	_.each(this.toJSON(), function(node, name) {
	    if (name.indexOf(nameHead) === 0) {
		var nodeTail = name.substr(nameHead.length);
		results.push({ nodeTail: nodeTail,
			       node: node });
	    }
	});
	return results;
    }
});

Channels.Channel = Backbone.Model.extend({
    initialize: function() {
	console.log({newChannel:this.attributes})
    },

    addNode: function(nodeTail, node) {
	var attrs = {};
	attrs['node:' + nodeTail] = node;
	this.set(attrs);

	var that = this;
	node.bind('change:items', function() {
	    /* Propagate */
	    console.log('Propagate change:items from node to channel');
	    that.trigger('change:items', that);
	});
    },

    /* Simple getter */
    getNode: function(nodeTail) {
	return this.get('node:' + nodeTail);
    },

    /**
     * Grab user's channels from service
     */
    syncNodes: function(service) {
	var that = this;
	_.forEach(service.getUserNodes(this.get('id')), function(userNode) {
	    if (!that.getNode(userNode.nodeTail))
		that.addNode(userNode.nodeTail, userNode.node);
	});
    }
});

/**
 * Contains all the channels and performs discovery on a per-user
 * base. This forward approach ensures we always seek the responsible
 * server first before adding nodes to a channel. See hookUser().
 */
Channels.Channels = Backbone.Collection.extend({
    model: Channels.Channel,

    initialize: function() {
	var that = this;
	this.services = {};

	Channels.cl.bind('online', function() {
	    console.log('online');
	    that.hookUser(Channels.cl.jid);

	    Channels.cl.getRoster(function(error, roster) {
		if (!roster)
		    return;
		_.forEach(roster, function(item) {
		    that.hookUser(item.jid);
		});
	    });
	});

	/* TODO: hook roster updates */

	Channels.cl.bind('item', function(jid, nodeName, id, elements) {
	    var service = that.getService(jid);
	    var node = service.getNode(nodeName);
	    if (!node) {
		/* We only care about nodes we subscribed to.  If
		 * subscriptions haven't been synced, we'll get items
		 * later anyway.
		 */
		return;
	    }
	    node.setItem(id, elements);
	});
    },

    /**
     * Adds on demand
     * 
     * @param jid (Domain of) the service
     */
    getService: function(jid) {
	if (!this.services.hasOwnProperty(jid))
	    this.services[jid] = new Channels.Service({ id: jid });
	return this.services[jid];
    },

    /**
     * Adds on demand
     * 
     * @param jid User
     */
    getChannel: function(jid) {
	var channel = this.get(jid);
	if (!channel) {
	    channel = new Channels.Channel({ id: jid });
	    this.add(channel);
	}
	return channel;
    },

    hookUser: function(user) {
	console.log('hookUser ' + user);
	var that = this;
	Channels.cl.findUserService(user, function(serviceJids) {
	    _.forEach(serviceJids, function(serviceJid) {
		var service = that.getService(serviceJid);
		var channel = that.getChannel(user);
		/* nodes known already? populate channel! */
		channel.syncNodes(service);

		service.bind('change', function() {
		    /* new nodes: populate channel */
		    channel.syncNodes(service);
		});
	    });
	});
    }
});

/**
 * Format Date as ISO8601
 * 
 * https://developer.mozilla.org/en/JavaScript/Reference/global_objects/date#Example.3a_ISO_8601_formatted_dates
 */
function isoDateString(d) {
    function pad(n) {
	return n<10 ? '0'+n : n;
    }
    return d.getUTCFullYear()+'-'
	+ pad(d.getUTCMonth()+1)+'-'
	+ pad(d.getUTCDate())+'T'
	+ pad(d.getUTCHours())+':'
	+ pad(d.getUTCMinutes())+':'
	+ pad(d.getUTCSeconds())+'Z';
 }

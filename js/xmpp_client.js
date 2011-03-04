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
	console.log('<<< ' + Strophe.serialize(stanza));

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
	    case Strophe.Status.AUTHFAIL:
		that.trigger('error', new Error('Authentication failure'));
		that.conn.disconnect();
		break;
	    case Strophe.Status.CONNFAIL:
		that.trigger('error', new Error('Connection failure'));
		break;
	    case Strophe.Status.DISCONNECTED:
		/* TODO: reconnect */
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

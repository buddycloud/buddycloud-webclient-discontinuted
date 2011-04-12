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


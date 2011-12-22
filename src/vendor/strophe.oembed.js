Strophe.addConnectionPlugin('oembed', {
    _connection: null,

    //The plugin must have the init function.
    init: function(conn) {
        this._connection = conn;

        // checking all required plugins
        ["disco"].forEach(function (plugin) {
            if (conn[plugin] === undefined)
                throw new Error(plugin + " plugin required!");
        });

        Strophe.addNamespace('OEMBED', "http://github.com/buddycloud/bedtime");
    },

    // discovers the inbox service jid from the given domain
    discover: function (domain, success, error, timeout) {
        console.log("oembed discover", domain);
        var conn = this._connection, self = this;
        domain = domain || Strophe.getDomainFromJid(conn.jid);
        conn.disco.items(domain, null, function /*success*/ (stanza) {
            self._onDiscoItems(success, error, timeout, stanza);
        }, error, timeout);
    },

    _onDiscoItems: function (success, error, timeout, stanza) {
        var conn = this._connection, self = this;
        /* Per-item callbacks */
        var itemsPending = 1, done = false;
        var itemSuccess = function(jid) {
            itemsPending--;
            if (!done) {
                done = true;
                success(jid);
            }
        };
        var itemError = function() {
            itemsPending--;
            if (!done && itemsPending < 1) {
                done = true;
                error();
            }
        };

        Strophe.forEachChild(stanza, 'query', function(queryEl) {
            Strophe.forEachChild(queryEl, 'item', function(itemEl) {
                var jid = itemEl.getAttribute('jid');
                if (jid) {
                    conn.disco.info(jid, null,
                        function /*success*/ (stanza) {
                            self._onDiscoInfo(itemSuccess, itemError,
                                              timeout, jid, stanza);
                        },
                    itemError, timeout);
                    itemsPending++;
                }
            });
        });
        /* itemsPending initialized with 1 to catch 0 items case */
        itemError();
    },

    _onDiscoInfo: function (success, error, timeout, jid, stanza) {
        var conn = this._connection;
        var queries, i, feature,
            features = stanza.getElementsByTagName('feature');
        for (i = 0; i < features.length; i++) {
            feature = features[i];
            if (feature.getAttribute('var') == Strophe.NS.OEMBED) {
		this.service = jid;
                return success(jid);
            }
        }
        return error();
    },

    /**
     * @param {Object} parameters: { url, maxwidth, maxheight }
     * @param {Function} callback (error, result)
     */
    fetch: function(parameters, callback) {
	if (!this.service) {
	    var that = this;
	    /* Discover and return... */
	    return this.discover(null, function() {
		/* Success discovering, recurse: */
		that.fetch(parameters, callback);
	    }, function(error) {
		/* Discovery error, bail out */
		callback(error);
	    });
	}

        var conn = this._connection;
        var iqid = conn.getUniqueId("oembed");
	var oembedAttrs = parameters;
	oembedAttrs.xmlns = Strophe.NS.OEMBED;
        var iq = $iq({ to: this.service,
		       type:'get',
		       id: iqid
		     })
	    .c('oembed', oembedAttrs);
        conn.sendIQ(iq.tree(), function(reply) {
	    var result = {};
	    Strophe.forEachChild(reply, 'oembed', function(oembedEl) {
		Strophe.forEachChild(oembedEl, undefined, function(keyEl) {
		    var key = keyEl.localName;
		    var value = keyEl.textContent;
		    result[key] = value;
		});
	    });
	    callback(null, result);
	}, function(error) {
	    callback(error);
	});
        return iqid;
    }
});

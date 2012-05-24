/*
This library is free software; you can redistribute it and/or modify it
 under the terms of the GNU Lesser General Public License as published
 by the Free Software Foundation; either version 2.1 of the License, or
 (at your option) any later version.
 .
 This library is distributed in the hope that it will be useful, but
 WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser
 General Public License for more details.

  Copyright (c) dodo <dodo@blacksec.org>, 2011

*/

/**
* File: strophe.buddycloud.js
* A Strophe plugin for buddycloud (http://buddycloud.org/wiki/XMPP_XEP).
*/
Strophe.getJidFromNode = function (node) {
    var match = node.match(/\/([^\/]+)\/([^\/]+)\/([^\/]+)/);
    return match.length > 3 ? match[2] : null;
};

Strophe.StanzaError = function(condition, text) {
    this.name = "StanzaError";
    this.condition = condition;
    this.text = text;
    this.message = condition + ": " + text;
};
/* https://developer.mozilla.org/en/JavaScript/Reference/Global_Objects/Error#Custom_Error_Types */
Strophe.StanzaError.prototype = new Error();
Strophe.StanzaError.prototype.constructor = Strophe.StanzaError;

Strophe.addConnectionPlugin('buddycloud', {
    _connection: null,

    //The plugin must have the init function.
    init: function(conn) {
        this._connection = conn;

        // checking all required plugins
        ["roster","pubsub","register","disco","dataforms"].forEach(function (plugin) {
            if (conn[plugin] === undefined)
                throw new Error(plugin + " plugin required!");
        });

        Strophe.addNamespace('FORWARD', "urn:xmpp:forward:tmp");
        Strophe.addNamespace('MAM', "urn:xmpp:archive#management");

        // generate _postParsers with the right namespaces
        this._postParsers = this._postParsers_template();
    },

    // Called by Strophe on connection event
    statusChanged: function (status, condition) {
        var conn = this._connection;
        if (status === Strophe.Status.CONNECTED)
            conn.pubsub.jid = conn.jid;
    },

    connect: function (channelserver) {
        var conn = this._connection;
        this.channels = {jid:channelserver};
        conn.pubsub.connect(channelserver);
    },

    // discovers the inbox service jid from the given domain
    discover: function (domain, success, error, timeout) {
        console.log("discover", domain);
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
        var queries, i, identity,
            identities = stanza.getElementsByTagName('identity');
        for (i = 0; i < identities.length; i++) {
            identity = identities[i];
            if (identity.getAttribute('category') == "pubsub" &&
                identity.getAttribute('type') == "inbox") {
                return success(jid);
            }
        }
        return error();
    },

    createChannel: function (success, error, timeout) {
        var register, conn = this._connection;
        register = $iq({from:conn.jid, to:this.channels.jid, type:'set'})
            .c('query', {xmlns: Strophe.NS.REGISTER});
        conn.sendIQ(register, success, this._errorcode(error), timeout);
    },

    createNode: function(node, metadata, success, error) {
	var config = this._metadata_to_config(metadata);
	this._connection.pubsub.createNode(node, config, success, this._errorcode(error));
    },

    subscribeNode: function (node, succ, err) {
        var conn = this._connection;
        conn.pubsub.subscribe(node, null, succ, this._errorcode(err));
    },

    unsubscribeNode: function (node, succ, err) {
        var conn = this._connection;
        conn.pubsub.unsubscribe(node, null, null, succ, this._errorcode(err));
    },

    getChannelPosts: function (options, succ, err, timeout) {
        var self = this, conn = this._connection;
        conn.pubsub.items(options,
            function  /*success*/ (stanza) {
                if (succ) self._parsePost(stanza, succ);
            }, self._errorcode(err), timeout);
    },

    publishAtom: function(node, atoms, success, error) {
        this._connection.pubsub.publishAtom(node, atoms, success,
                                            this._errorcode(error));
    },

    /* TODO: what is this for?
     * using code in connector.coffee is commented out
     */
    getChannelPostStream: function (node, succ, err, timeout) {
        this._connection.addHandler(
            this._onChannelPost(succ, err),
            Strophe.NS.PUBSUB, 'iq', 'result', null, null);
        this.getChannelPosts(node, null, null, timeout);
    },

    _onChannelPost: function (succ, err) {
        var self = this;
        return this._iqcbsoup(function (stanza) {
            self._parsePost(stanza, succ);
        },  self._errorcode(err));
    },

    /**
     * Parse *multiple* posts
     *
     * @param el <items/> element that contains <item/> children
     */
    _parsePost: function (el, callback) {
        var posts = [];
        var items = el.getElementsByTagName('item');
        for(var i = 0; i < items.length; i++) {
            var item = items[i];
            /* Get first item child */
            var postEl = null;
            Strophe.forEachChild(item, null, function(child) {
                if (!postEl)
                    postEl = child;
            });

            if (postEl)
                try {
                    var parser = this._postParsers[
                        '{' + postEl.namespaceURI + '}' + postEl.nodeName];
                    var post = parser.call(this, postEl);
                    if (post) {
                        if (!post.id)
                            post.id = item.getAttribute('id');
                        posts.push(post);
                    }
                } catch(e) {
                    console.error("Cannot parse post", postEl, e.stack || e);
                }
        }
	this._applyRSM(el, posts);
        callback(posts);
    },

    /* This is just a simple function that we call in the constructor to
     * generate _postParsers from it with the right namespaces.
     */
    _postParsers_template: function () {
        var parsers = {};
        parsers['{'+Strophe.NS.ATOM+'}entry'] = function(entry) {
            var attr, post;
	    /**   ^
	     *   / \ The variable `attr' actually refers
	     *  / ! \ to elements in this function.
	     * /_____\
	     */

            // Takes an <item /> element and returns a hash of it's attributes
            post = this._parsetag(entry, "id", "published", "updated", "clientinterface");

            // content
            attr = entry.getElementsByTagName("content");
            if (attr.length > 0) {
                attr = attr.item(0);
                post.content = {
                    type: attr.getAttribute("type"),
                    value:attr.textContent,
                };
            }

            // author
            attr = entry.getElementsByTagName("author");
            if (attr.length > 0) {
                post.author = this._parsetag(attr.item(0),
                                             "name", "uri");
                if (post.author.uri)
                    post.author.jid = post.author.uri.replace(/^[^:]+:/,"");
            }

            // geo
            attr = entry.getElementsByTagName("geo");
            if (attr.length > 0)
                post.geo = this._parsetag(attr.item(0),
                                          "country", "locality", "text");

            // in reply to
            var in_reply_tos = entry.getElementsByTagNameNS(
                Strophe.NS.ATOM_THR, "in-reply-to");
            if (in_reply_tos.length > 0)
                post.in_reply_to = in_reply_tos[0].getAttribute("ref");

            return post;
        };
        parsers['{'+Strophe.NS.DISCO_ITEMS+'}query'] = function(query) {
            var post = { subscriptions: {} };
            Strophe.forEachChild(query, 'item', function(item) {
                var jid = item.getAttribute('jid'),
                    node = item.getAttribute('node'),
                    subscription = item.getAttributeNS(
                        Strophe.NS.PUBSUB, 'subscription'),
                    affiliation = item.getAttributeNS(
                        Strophe.NS.PUBSUB, 'affiliation'),
                    updated;
                Strophe.forEachChild(item, 'updated', function(updated) {
                    updated = updated.textContent;
                });
                if (jid && node)
                    post.subscriptions[node] = {
                        jid: jid,
                        node: node,
                        subscription: subscription,
                        affiliation: affiliation,
                        updated: updated,
                    };
            });
            return post;
        };
        return parsers;
    },

    _applyRSM: function(el, target) {
	var rsmEl;
	if ((rsmEl = el.getElementsByTagNameNS(Strophe.NS.RSM, 'set')[0])) {
	    target.rsm = {};
	    var lastEl = rsmEl.getElementsByTagName('last')[0];
	    if (lastEl)
		target.rsm.last = lastEl.textContent;
	}
    },

    getMetadata: function (jid, node, succ, err, timeout) {
        var self = this, conn = this._connection;
        if (typeof node === 'function') {
            err = succ;
            succ = node;
            node = jid;
            jid = undefined;
        }
        jid = jid || this.channels.jid;
        conn.disco.info(jid, node,
            function /*success*/ (stanza) {
                if (!succ) return;
                // Flatten the namespaced fields into a hash
                var i,key,field,fields = {}, form = conn.dataforms.parse(stanza);
                for (i = 0; i < form.fields.length; i++) {
                    field = form.fields[i];
                    key = field.variable.replace(/.+#/,'');
                    fields[key] = {
                        value: field.value,
                        label: field.label,
                        type:  field.type,
                    };
                }
                succ(fields);
            }, self._errorcode(err), timeout);
    },

    setMetadata: function(node, metadata, success, error) {
	var config = this._metadata_to_config(metadata);
	this._connection.pubsub.setConfig(node, config, success, error);
    },

    _metadata_to_config: function(metadata) {
	var config = {};
	for(var key in metadata)
	    if (metadata.hasOwnProperty(key)) {
		var value = metadata[key];
		switch(key) {
		case 'title':
		case 'description':
		case 'access_model':
		case 'publish_model':
		case 'creation_date':
		    config["pubsub#" + key] = value;
		    break;
		case 'default_affiliation':
		case 'channel_type':
		    config["buddycloud#" + key] = value;
		    break;
		}
	    }
	return config;
    },

    /**
     * Attention:
     *
     * subscriptions may contain extraneous `rsm' key that must be
     * filtered from the user ids.
     */
    getSubscribers: function(node, success, error) {
        var that = this;
        this._connection.pubsub.getNodeSubscriptions(node, function(stanza) {
            var pubsub, subscribers = {};
            pubsub = stanza.getElementsByTagNameNS(
                Strophe.NS.PUBSUB_OWNER, 'pubsub')[0];
            if (pubsub)
                Strophe.forEachChild(pubsub, 'subscriptions',
                    function(subscriptions) {
                        Strophe.forEachChild(subscriptions, 'subscription',
                            function(subscription) {
                                var jid = subscription.getAttribute('jid');
                                if (jid)
                                    subscribers[jid] =
                                        subscription.getAttribute('subscription') ||
                                        "subscribed";
                        });
                });

            that._applyRSM(stanza, subscribers);
            return success(subscribers);
        }, this._errorcode(error));
    },

    getAffiliations: function(node, success, error) {
        var that = this;
        this._connection.pubsub.getNodeAffiliations(node, function(stanza) {
            var pubsub, affiliations = {};
            pubsub = stanza.getElementsByTagNameNS(
                Strophe.NS.PUBSUB_OWNER, 'pubsub')[0];
            if (pubsub)
                Strophe.forEachChild(pubsub, 'affiliations',
                    function(affiliationsEl) {
                        Strophe.forEachChild(affiliationsEl, 'affiliation',
                            function(affiliation) {
                                var jid = affiliation.getAttribute('jid');
                                if (jid)
                                    affiliations[jid] =
                                        affiliation.getAttribute('affiliation') ||
                                        "none";
                        });
                });

            that._applyRSM(stanza, affiliations);
            return success(affiliations);
        }, this._errorcode(error));
    },

    /**
     * @param start {Date} Optional
     * @param end {Date} Optional
     */
    replayNotifications: function(start, end, success, error) {
        var conn = this._connection;
        var queryAttrs = { xmlns: Strophe.NS.MAM };
        if (start)
            queryAttrs.start = start.toISOString ? start.toISOString() : start;
        if (end)
            queryAttrs.end = end.toISOString ? end.toISOString() : end;
        var iq = $iq({ from: conn.jid,
                       to: this.channels.jid,
                       type: 'get' }).
            c('query', queryAttrs);
        conn.sendIQ(iq, success, this._errorcode(error));
    },

    /**
     * TODO: filter for sender
     */
    addNotificationListener: function(listener) {
        var that = this;
        var safeListener = function() {
            try {
                listener.apply(that, arguments);
            } catch(e) {
                Strophe.fatal(e.stack || e);
            }
        };
        this._connection.pubsub.addNotificationListener(function(stanza) {
            that._handleNotification(stanza, safeListener);
        });
        this._connection.addHandler(function(stanza) {
            Strophe.forEachChild(stanza, 'forwarded', function(forwarded) {
                Strophe.forEachChild(forwarded, 'message', function(innerStanza) {
                    that._handleNotification(innerStanza, safeListener);
                });
            });
            return true;
        }, Strophe.NS.FORWARD, 'message');
    },

    _handleNotification: function(stanza, listener) {
        var that = this;
        Strophe.forEachChild(stanza, 'event', function(eventEl) {
            Strophe.forEachChild(eventEl, null, function(child) {
                if (child.nodeName === 'subscription') {
                    listener({
                        type: 'subscription',
                        node: child.getAttribute('node'),
                        jid: child.getAttribute('jid'),
                        subscription: child.getAttribute('subscription')
                    });
                } else if (child.nodeName === 'affiliation') {
                    listener({
                        type: 'affiliation',
                        node: child.getAttribute('node'),
                        jid: child.getAttribute('jid'),
                        affiliation: child.getAttribute('affiliation')
                    });
                } else if (child.nodeName === 'items') {
                    that._parsePost(child, function(posts) {
                        listener({
                            type: 'posts',
                            node: child.getAttribute('node'),
                            posts: posts
                        });
                    });
                } else if (child.nodeName === 'configuration') {
                    Strophe.forEachChild(child, 'x', function(x) {
                        // Flatten the namespaced fields into a hash
                        var i,key,field,config = {},
                            form = that._connection.dataforms.parse(x);
                        for (i = 0; i < form.fields.length; i++) {
                            field = form.fields[i];
                            key = field.variable.replace(/.+#/,'');
                            config[key] = {
                                value: field.value,
                                label: field.label,
                                type:  field.type,
                            };
                        }
                        if (config.FORM_TYPE &&
                          config.FORM_TYPE.value === Strophe.NS.PUBSUB_NODE_CONFIG)
                            listener({
                                type: 'config',
                                node: child.getAttribute('node'),
                                config: config
                            });
                    });
                } else
                    console.warn("Unhandled buddycloud event type", child.nodeName);
            });
        });
    },

    // helper

    /**
     * Wraps a callback to convert stanza error XML to a
     * Strophe.StanzaError object.
     */
    _errorcode: function (callback) {
        return function (stanza) {
            if (!stanza)
                return;
            var errors = stanza.getElementsByTagName("error");
            var condition = 'error', text = null;
            for(var i = 0; i < errors.length; i++) {
                var errorEl = errors[i];
                for(var j = 0; j < errorEl.childNodes.length; j++) {
                    var errorChild = errorEl.childNodes[j];
                    if (errorChild.namespaceURI === Strophe.NS.STANZAS) {
                        if (errorChild.localName === "text")
                            text = errorChild.textContent;
                        else
                            condition = errorChild.localName;
                    }
                }
            }
            callback(new Strophe.StanzaError(condition, text));
        };
    },

    _iqcbsoup: function (success, error) {
        return function (stanza) {
            var iqtype = stanza.getAttribute('type');
            if (iqtype == 'result') {
                if (success) success(stanza);
            } else if (iqtype == 'error') {
                if (error) error(stanza);
            } else {
                throw {
                    name: "StropheError",
                    message: "Got bad IQ type of " + iqtype
                };
            }
        };
    },

    _parsetag: function (tag) {
        var attr, res = {};
        Array.prototype.slice.call(arguments,1).forEach(function (name) {
            attr = tag.getElementsByTagName(name);
            if (attr.length > 0)
                res[name] = attr.item(0).textContent;
        });
        return res;
    },

});

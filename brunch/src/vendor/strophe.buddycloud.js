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
}

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
    },

    // Called by Strophe on connection event
    statusChanged: function (status, condition) {
        var that = this._connection;
        if (status === Strophe.Status.CONNECTED)
            that.pubsub.jid = that.jid;
    },

    connect: function (channelserver) {
        var that = this._connection;
        this.channels = {jid:channelserver};
        that.pubsub.connect(channelserver);
    },

    // discovers the channel server jid from the given domain
    discover: function (domain, success, error, timeout) {
        if (typeof domain === 'function') {
            timeout = error;
            error = success;
            success = domain;
            domain = undefined;
        }
        var that = this._connection, self = this;
        domain = domain || Strophe.getDomainFromJid(that.jid);
        that.disco.items(domain, null, function /*success*/ () {
            var args = Array.prototype.slice.call(arguments);
            self._onDiscoItems.apply(self,[success,error,timeout].concat(args));
        }, error, timeout);
    },

    _onDiscoItems: function (success, error, timeout, stanza) {
        var that = this._connection, self = this;
        var i, item, jid, items = stanza.getElementsByTagName('item');
        for (i = 0; i < items.length; i++) {
            item = items[i];
            jid = item.getAttribute('jid');
            if (jid) {
                that.disco.info(jid, null,
                    function /*success*/ () {
                        var args = Array.prototype.slice.call(arguments);
                        self._onDiscoInfo.apply(self,
                            [success, error, timeout, jid].concat(args));
                    },
                error, timeout);
            }
        }
    },

    _onDiscoInfo: function (success, error, timeout, jid, stanza) {
        var that = this._connection;
        var queries, i, identity,
            identities = stanza.getElementsByTagName('identity');
        for (i = 0; i < identities.length; i++) {
            identity = identities[i];
            if (identity.getAttribute('category') == "pubsub"
              &&identity.getAttribute('type') == "inbox") {
                return success(jid);
            }
        }
    },

    createChannel: function (success, error, timeout) {
        var register, that = this._connection;
        register = $iq({from:that.jid, to:this.channels.jid, type:'set'})
            .c('query', {xmlns: Strophe.NS.REGISTER});
        that.sendIQ(register, success, error, timeout);
    },

    subscribeChannel: function (node, succ, err) {
        var that = this._connection;
        that.pubsub.subscribe(node, null, null, this._iqcbsoup(succ, err));
    },

    getChannelPosts: function (node, succ, err, timeout) {
        var self = this, that = this._connection;
        that.pubsub.items(node,
            function  /*success*/ (stanza) {
                if (succ) self._parsePost(stanza, succ);
            }, self._errorcode(err), timeout);
    },

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

    _parsePost: function (stanza, callback) {
        var i, j, item, attr, post, posts = [], entry, entries,
            items = stanza.getElementsByTagName("item");
        for (i = 0; i < items.length; i++) {
            item = items[i];
            entries = item.getElementsByTagName("entry");
            for(j = 0; j < entries.length; j++) {
                entry = entries[j];
                // Takes an <item /> stanza and returns a hash of it's attributes
                post = this._parsetag(entry, "id", "published", "updated");
                post.id = parseInt(post.id.replace(/.+:/,''));

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
                if (attr.length > 0)
                    post.author = this._parsetag(attr.item(0),
                        "name", "jid", "affiliation");

                // geoloc
                attr = entry.getElementsByTagName("geoloc");
                if (attr.length > 0)
                    post.geoloc = this._parsetag(attr.item(0),
                        "country", "locality", "text");

                // in reply to
                attr = entry.getElementsByTagName("thr:in-reply-to");
                if (attr.length > 0)
                    post.in_reply_to = parseInt(attr.item(0).getAttribute("ref"));

                posts.push(post);
            }
        }
        callback(posts);

    },

    getUserSubscriptions: function (succ, err) {
        var self = this, that = this._connection;
        that.pubsub.getSubscriptions(self._iqcbsoup(
            function  /*success*/ (stanza) {
                if (!succ) return;
                var i, sub, node, result = [],
                    subscriptions = stanza.getElementsByTagName("subscription");
                for (i = 0; i < subscriptions.length; i++) {
                    sub = subscriptions[i];
                    node = sub.getAttribute('node');
                    result.push({
                        node: node,
                        jid: Strophe.getJidFromNode(node),
                        subscription: sub.getAttribute('subscription'),
                    });
                }
                succ(result);
            }, self._errorcode(err))
        );
    },

    getUserAffiliations: function (succ, err) {
        var self = this, that = this._connection;
        that.pubsub.getAffiliations(self._iqcbsoup(
            function /*success*/ (stanza) {
                if (!succ) return;
                var i, aff, node, result = [],
                    affiliations = stanza.getElementsByTagName("affiliation");
                for (i = 0; i < affiliations.length; i++) {
                    aff = affiliations[i];
                    node = aff.getAttribute('node');
                    result.push({
                        node: node,
                        jid: Strophe.getJidFromNode(node),
                        affiliation: aff.getAttribute('affiliation'),
                    });
                }
                succ(result);
            }, self._errorcode(err))
        );
    },

    getMetadata: function (jid, node, succ, err, timeout) {
        var self = this, that = this._connection;
        if (typeof node === 'function') {
            err = succ;
            succ = node;
            node = jid;
            jid = undefined;
        }
        jid = jid || this.channels.jid;
        that.disco.info(jid, node,
            function /*success*/ (stanza) {
                if (!succ) return;
                // Flatten the namespaced fields into a hash
                var i,key,field,fields = {}, form = that.dataforms.parse(stanza);
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

    // helper

    _errorcode: function (error) {
        return function (stanza) {
            if (!error) return;
            var errors = stanza.getElementsByTagName("error");
            var code = errors.item(0).getAttribute('code');
            error(code);
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
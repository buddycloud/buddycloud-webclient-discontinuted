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

    connect: function (channelserver) {
        var that = this._connection;
        this.channels = {jid:channelserver};
        that.pubsub.connect(channelserver);
    },

    createChannel: function (success, error) {
        var register, that = this._connection;
        register = $iq({from:that.jid, to:this.channels.jid, type:'set'})
            .c('query', {xmlns: Strophe.NS.REGISTER});
        that.sendIQ(register, success, error);
    },

    subscribeChannel: function (node, succ, err) {
        this._connection.pubsub.subscribe(node, null, null, iqcbsoup(succ,err));
    },

    // Get the subscriptions for a user, calls succ with an array of hashes of channels
    getUserSubscriptions: function (succ, err) {
        var that = this._connection;
        that.pubsub.getSubscriptions(iqcbsoup(
            function  /*success*/ (stanza) {
                if (!succ) return;
                var i, sub, channels = [],
                    subscriptions = stanza.getElementsByTagName("subscription");
                for (i = 0; i < subscriptions.length; i++) {
                    sub = subscriptions[i];
                    channels.push({
                        jid : sub.getAttribute('jid'),
                        node: sub.getAttribute('node'),
                        affiliation: sub.getAttribute('affiliation'),
                    });
                }
                succ(channels);
            }, function /*error*/ (stanza) {
                if (!err) return;
                var errors = stanza.getElementsByTagName("error");
                var code = errors[0].getAttribute('code');
                err(code);
            })
        );
    },

    getMetadata: function (jid, node, succ, err) {
        var that = this._connection;
        if (err === undefined) {
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
                var i,key,field, res = {}, form = that.dataforms.parse(stanza);
                for (i = 0; i < form.fields.length; i++) {
                    field = form.fields[i];
                    key = field.variable.replace(/.+#/,'');
                    res[key] = {
                        value: field.value,
                        label: field.label,
                        type:  field.type,
                    };
                }
                succ(res);
            },function /*error*/ (stanza) {
                if (!err) return;
                var errors = stanza.getElementsByTagName("error");
                var code = errors[0].getAttribute('code');
                err(code);
            });
    },
});


// helper

var iqcbsoup = function (success, error) {
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
};
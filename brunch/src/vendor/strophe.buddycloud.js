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
        ["roster", "pubsub", "register", "disco"].forEach(function (plugin) {
            if (conn[plugin] === undefined)
                throw new Error(plugin + " plugin required!");
        });
    },
    connect: function (channelserver) {
        this.channels = {jid:channelserver};
    },
    createChannel: function (success, error) {
        var register, that = this._connection;
        register = $iq({from:that.jid, to:this.channels.jid, type:"set"}).c(
            "query", {xmlns: Strophe.NS.REGISTER});
        that.sendIQ(register, success, error);
    },
});
/*
    This program is distributed under the terms of the MIT license.
    Please see the LICENSE file for details.

    Copyright 2008, Stanziq  Inc.

    Overhauled in October 2009 by Liam Breck [How does this affect copyright?]
*/

/** File: strophe.pubsub.js
 *  A Strophe plugin for XMPP Publish-Subscribe.
 *
 *  Provides Strophe.Connection.pubsub object,
 *  parially implementing XEP 0060.
 *
 *  Strophe.Builder.prototype methods should probably move to strophe.js
 */

/** Function: Strophe.Builder.form
 *  Add an options form child element.
 *
 *  Does not change the current element.
 *
 *  Parameters:
 *    (String) ns - form namespace.
 *    (Object) options - form properties.
 *
 *  Returns:
 *    The Strophe.Builder object.
 */
Strophe.Builder.prototype.form = function (ns, options)
{
    var aX = this.node.appendChild(Strophe.xmlElement('x', {"xmlns": Strophe.NS.DATA, "type": "submit"}));
    aX.appendChild(Strophe.xmlElement('field', {"var":"FORM_TYPE", "type": "hidden"}))
      .appendChild(Strophe.xmlElement('value'))
      .appendChild(Strophe.xmlTextNode(ns));

    for (var i in options) {
        aX.appendChild(Strophe.xmlElement('field', {"var": i}))
        .appendChild(Strophe.xmlElement('value'))
        .appendChild(Strophe.xmlTextNode(options[i]));
    }
    return this;
};

/** Function: Strophe.Builder.list
 *  Add many child elements.
 *
 *  Does not change the current element.
 *
 *  Parameters:
 *    (String) tag - tag name for children.
 *    (Array) array - list of objects with format:
 *          { attrs: { [string]:[string], ... }, // attributes of each tag element
 *             data: [string | XML_element] }    // contents of each tag element
 *
 *  Returns:
 *    The Strophe.Builder object.
 */
Strophe.Builder.prototype.list = function (tag, array)
{
    for (var i=0; i < array.length; ++i) {
        this.c(tag, array[i].attrs)
        this.node.appendChild(array[i].data.cloneNode
                            ? array[i].data.cloneNode(true)
                            : Strophe.xmlTextNode(array[i].data));
        this.up();
    }
    return this;
};

Strophe.Builder.prototype.children = function (object) {
    var key, value;
    for (key in object) {
        if (!object.hasOwnProperty(key)) continue;
        value = object[key];
        if (Array.isArray(value)) {
            this.list(key, value);
        } else if (typeof value === 'string') {
            this.c(key, {}, value);
        } else if (typeof value === 'number') {
            this.c(key, {}, ""+value);
        } else if (typeof value === 'object') {
            this.c(key).children(value).up();
        } else {
            this.c(key).up();
        }
    }
    return this;
};

// TODO Ideas Adding possible conf values?
/* Extend Strophe.Connection to have member 'pubsub'.
 */
Strophe.addConnectionPlugin('pubsub', {
/*
Extend connection object to have plugin name 'pubsub'.
*/
    _connection: null,
    _autoService: true,
    service: null,
    jid: null,

    //The plugin must have the init function.
    init: function(conn) {

        this._connection = conn;

        /*
        Function used to setup plugin.
        */

        /* extend name space
        *  NS.PUBSUB - XMPP Publish Subscribe namespace
        *              from XEP 60.
        *
        *  NS.PUBSUB_SUBSCRIBE_OPTIONS - XMPP pubsub
        *                                options namespace from XEP 60.
        */
        Strophe.addNamespace('PUBSUB',"http://jabber.org/protocol/pubsub");
        Strophe.addNamespace('PUBSUB_SUBSCRIBE_OPTIONS',
                             Strophe.NS.PUBSUB+"#subscribe_options");
        Strophe.addNamespace('PUBSUB_ERRORS',Strophe.NS.PUBSUB+"#errors");
        Strophe.addNamespace('PUBSUB_EVENT',Strophe.NS.PUBSUB+"#event");
        Strophe.addNamespace('PUBSUB_OWNER',Strophe.NS.PUBSUB+"#owner");
        Strophe.addNamespace('PUBSUB_AUTO_CREATE',
                             Strophe.NS.PUBSUB+"#auto-create");
        Strophe.addNamespace('PUBSUB_PUBLISH_OPTIONS',
                             Strophe.NS.PUBSUB+"#publish-options");
        Strophe.addNamespace('PUBSUB_NODE_CONFIG',
                             Strophe.NS.PUBSUB+"#node_config");
        Strophe.addNamespace('PUBSUB_CREATE_AND_CONFIGURE',
                             Strophe.NS.PUBSUB+"#create-and-configure");
        Strophe.addNamespace('PUBSUB_SUBSCRIBE_AUTHORIZATION',
                             Strophe.NS.PUBSUB+"#subscribe_authorization");
        Strophe.addNamespace('PUBSUB_GET_PENDING',
                             Strophe.NS.PUBSUB+"#get-pending");
        Strophe.addNamespace('PUBSUB_MANAGE_SUBSCRIPTIONS',
                             Strophe.NS.PUBSUB+"#manage-subscriptions");
        Strophe.addNamespace('PUBSUB_META_DATA',
                             Strophe.NS.PUBSUB+"#meta-data");
        Strophe.addNamespace('ATOM', "http://www.w3.org/2005/Atom");
        Strophe.addNamespace('ATOM_THR', "http://purl.org/syndication/thread/1.0");
	Strophe.addNamespace('RSM', "http://jabber.org/protocol/rsm");
	Strophe.addNamespace('DATA', "jabber:x:data");

        if (conn.disco)
            conn.disco.addFeature(Strophe.NS.PUBSUB);

        /* Setup notification handling */
        this._notificationListeners = [];
        var that = this;
        conn.addHandler(function(stanza) {
            return that.onEventNotification(stanza);
        }, Strophe.NS.PUBSUB_EVENT, 'message');
    },

    // Called by Strophe on connection event
    statusChanged: function (status, condition) {
        var that = this._connection;
        if (this._autoService && status === Strophe.Status.CONNECTED) {
            this.service =  'pubsub.'+Strophe.getDomainFromJid(that.jid);
            this.jid = that.jid;
        }
    },

    /***Function

    Parameters:
    (String) jid - The node owner's jid.
    (String) service - The name of the pubsub service.
    */
    connect: function (jid, service) {
        var that = this._connection;
        if (service === undefined) {
            service = jid;
            jid = undefined;
        }
        this.jid = jid || that.jid;
        this.service = service || null;
        this._autoService = false;
    },

    /***Function

    Create a pubsub node on the given service with the given node
    name.

    Parameters:
    (String) node -  The name of the pubsub node.
    (Dictionary) options -  The configuration options for the  node.
    (Function) call_back - Used to determine if node
    creation was sucessful.

    Returns:
    Iq id used to send subscription.
    */
    createNode: function(node,options, success, error) {
        var that = this._connection;
        var iqid = that.getUniqueId("pubsubcreatenode");

        var iq = $iq({from:this.jid, to:this.service, type:'set', id:iqid})
          .c('pubsub', {xmlns:Strophe.NS.PUBSUB})
          .c('create',{node:node});
        if(options) {
            iq.up().c('configure').form(Strophe.NS.PUBSUB_NODE_CONFIG, options);
        }

        that.sendIQ(iq.tree(), success, error);
        return iqid;
    },

    /** Function: deleteNode
     *  Delete a pubsub node.
     *
     *  Parameters:
     *    (String) node -  The name of the pubsub node.
     *    (Function) call_back - Called on server response.
     *
     *  Returns:
     *    Iq id
     */
    deleteNode: function(node, success, error) {
        var that = this._connection;
        var iqid = that.getUniqueId("pubsubdeletenode");

        var iq = $iq({from:this.jid, to:this.service, type:'set', id:iqid})
          .c('pubsub', {xmlns:Strophe.NS.PUBSUB_OWNER})
          .c('delete', {node:node});

        that.sendIQ(iq.tree(), success, error);

        return iqid;
    },

    /** Function
     *
     * Get all nodes that currently exist.
     *
     * Parameters:
     *   (Function) success - Used to determine if node creation was sucessful.
     *   (Function) error - Used to determine if node
     * creation had errors.
     */
    discoverNodes: function(success, error, timeout) {

        //ask for all nodes
        var iq = $iq({from:this.jid, to:this.service, type:'get'})
          .c('query', { xmlns:Strophe.NS.DISCO_ITEMS });

        return this._connection.sendIQ(iq.tree(), success, error, timeout);
    },

    /** Function: getConfig
     *  Get node configuration form.
     *
     *  Parameters:
     *    (String) node -  The name of the pubsub node.
     *    (Function) call_back - Receives config form.
     *
     *  Returns:
     *    Iq id
     */
    getConfig: function (node, success, error) {
        var that = this._connection;
        var iqid = that.getUniqueId("pubsubgetconfigurenode");

        var iq = $iq({from:this.jid, to:this.service, type:'get', id:iqid})
          .c('pubsub', {xmlns:Strophe.NS.PUBSUB_OWNER})
          .c('configure', {node:node});

        that.sendIQ(iq.tree(), success, error);

        return iqid;
    },

    setConfig: function(node, config, success, error) {
        var that = this._connection;
        var iqid = that.getUniqueId("pubsubsetconfigurenode");

        var iq = $iq({from:this.jid, to:this.service, type:'set', id:iqid})
          .c('pubsub', {xmlns:Strophe.NS.PUBSUB_OWNER})
          .c('configure', {node:node})
	  .c('x', {xmlns: Strophe.NS.DATA, type: 'submit'});
	iq.c('field', {var: 'FORM_TYPE', type: 'hidden'})
	  .c('value')
	  .t(Strophe.NS.PUBSUB + "#node_config")
	  .up().up();
	for(var key in config)
	    if (config.hasOwnProperty(key))
		iq.c('field', {var: key})
		    .c('value')
		    .t(config[key])
		    .up().up();

        that.sendIQ(iq.tree(), success, error);

        return iqid;
    },

    /**
     *  Parameters:
     *    (Function) call_back - Receives subscriptions.
     *
     *  http://xmpp.org/extensions/tmp/xep-0060-1.13.html
     *  8.3 Request Default Node Configuration Options
     *
     *  Returns:
     *    Iq id
     */
    getDefaultNodeConfig: function(success, error) {
        var that = this._connection;
        var iqid = that.getUniqueId("pubsubdefaultnodeconfig");

        var iq = $iq({from:this.jid, to:this.service, type:'get', id:iqid})
          .c('pubsub', {'xmlns':Strophe.NS.PUBSUB_OWNER})
          .c('default');

        that.sendIQ(iq.tree(), success, error);

        return iqid;
    },

    /***Function
        Subscribe to a node in order to receive event items.

        Parameters:
        (String) node         - The name of the pubsub node.
        (Array) options       - The configuration options for the  node.
        (Function) success    - callback function for successful node creation.
        (Function) error      - error callback function.
        (Boolean) barejid     - use barejid creation was sucessful.

        Returns:
        Iq id used to send subscription.
    */
    subscribe: function(node, options, success, error, barejid) {
        var that = this._connection;
        var iqid = that.getUniqueId("subscribenode");

        var jid = this.jid;
        if(barejid)
            jid = Strophe.getBareJidFromJid(jid);

        var iq = $iq({from:this.jid, to:this.service, type:'set', id:iqid})
          .c('pubsub', { xmlns:Strophe.NS.PUBSUB })
          .c('subscribe', {'node':node, 'jid':jid});
        if(options) {
            iq.up().c('options').form(Strophe.NS.PUBSUB_SUBSCRIBE_OPTIONS, options);
        }

        that.sendIQ(iq.tree(), success, error);
        return iqid;
    },

    /***Function
        Unsubscribe from a node.

        Parameters:
        (String) node       - The name of the pubsub node.
        (Function) success  - callback function for successful node creation.
        (Function) error    - error callback function.

    */
    unsubscribe: function(node, jid, subid, success, error) {
        var that = this._connection;
        var iqid = that.getUniqueId("pubsubunsubscribenode");

        var iq = $iq({from:this.jid, to:this.service, type:'set', id:iqid})
          .c('pubsub', { xmlns:Strophe.NS.PUBSUB })
          .c('unsubscribe', {'node':node});
        if (jid) iq.attrs({jid:jid});
        if (subid) iq.attrs({subid:subid});

        that.sendIQ(iq.tree(), success, error);
        return iqid;
    },

    /***Function

    Publish and item to the given pubsub node.

    Parameters:
    (String) node -  The name of the pubsub node.
    (Array) items -  The list of items to be published.
    (Function) call_back - Used to determine if node
    creation was sucessful.
    */
    publish: function(node, items, success, error) {
        var that = this._connection;
        var iqid = that.getUniqueId("pubsubpublishnode");

        var iq = $iq({from:this.jid, to:this.service, type:'set', id:iqid})
          .c('pubsub', { xmlns:Strophe.NS.PUBSUB })
          .c('publish', { node:node })
          .list('item', items);

        that.sendIQ(iq.tree(), success, error);

        return iqid;
    },

    /**
     * Delete items of a node
     */
    retract: function(node, itemIds, success, error) {
        var that = this._connection;
        var iqid = that.getUniqueId("pubsubretractitems");

        var iq = $iq({from:this.jid, to:this.service, type:'set', id:iqid})
          .c('pubsub', { xmlns:Strophe.NS.PUBSUB })
          .c('retract', { node:node });
	for(var i = 0; i < itemIds.length; i++) {
	    iq.c('item', { id: itemIds[i] }).up();
	}

        that.sendIQ(iq.tree(), success, error);

        return iqid;
    },

    /*Function: items
    Used to retrieve the persistent items from the pubsub node.

    */
    items: function(options, success, error, timeout) {
        //ask for all items
	var node = options.node || options;
        var iq = $iq({from:this.jid, to:this.service, type:'get'})
          .c('pubsub', { xmlns:Strophe.NS.PUBSUB })
          .c('items', {node:node}).up()
	  .c('set', { xmlns: Strophe.NS.RSM })
	  .c('max').t("40")
	  .up();
	if (options.rsmAfter)
	    iq.c('after').t(options.rsmAfter);

        return this._connection.sendIQ(iq.tree(), success, error, timeout);
    },

    /** Function: getSubscriptions
     *  Get subscriptions of a JID.
     *
     *  Parameters:
     *    (Function) call_back - Receives subscriptions.
     *
     *  http://xmpp.org/extensions/tmp/xep-0060-1.13.html
     *  5.6 Retrieve Subscriptions
     *
     *  Returns:
     *    Iq id
     */
    getSubscriptions: function(success, error, timeout) {
        var that = this._connection;
        var iqid = that.getUniqueId("pubsubsubscriptions");

        var iq = $iq({from:this.jid, to:this.service, type:'get', id:iqid})
          .c('pubsub', {'xmlns':Strophe.NS.PUBSUB})
          .c('subscriptions');

        that.sendIQ(iq.tree(), success, error, timeout);

        return iqid;
    },

    /** Function: getNodeSubscriptions
     *  Get node subscriptions of a JID.
     *
     *  Parameters:
     *    (Function) call_back - Receives subscriptions.
     *
     *  http://xmpp.org/extensions/tmp/xep-0060-1.13.html
     *  5.6 Retrieve Subscriptions
     *
     *  Returns:
     *    Iq id
     */
    getNodeSubscriptions: function(options, success, error) {
        var that = this._connection;
	var node = options.node || options;
        var iqid = that.getUniqueId("pubsubsubscriptions");

        var iq = $iq({from:this.jid, to:this.service, type:'get', id:iqid})
            .c('pubsub', {'xmlns':Strophe.NS.PUBSUB_OWNER})
            .c('subscriptions', {'node':node});
	if (options.rsmAfter)
	    iq.up().
		c('set', { xmlns: Strophe.NS.RSM }).
		c('after').t(options.rsmAfter);

       that.sendIQ(iq.tree(), success, error);

       return iqid;
    },

    /** Function: getSubOptions
     *  Get subscription options form.
     *
     *  Parameters:
     *    (String) node -  The name of the pubsub node.
     *    (String) subid - The subscription id (optional).
     *    (Function) call_back - Receives options form.
     *
     *  Returns:
     *    Iq id
     */
    getSubOptions: function(node, subid, success, error) {
        var that = this._connection;
        var iqid = that.getUniqueId("pubsubsuboptions");

        var iq = $iq({from:this.jid, to:this.service, type:'get', id:iqid})
          .c('pubsub', {xmlns:Strophe.NS.PUBSUB})
          .c('options', {node:node, jid:this.jid});
        if (subid) iq.attrs({subid:subid});

        that.sendIQ(iq.tree(), success, error);

        return iqid;
    },

    /**
     *  Parameters:
     *    (String) node -  The name of the pubsub node.
     *    (Function) call_back - Receives subscriptions.
     *
     *  http://xmpp.org/extensions/tmp/xep-0060-1.13.html
     *  8.9 Manage Affiliations - 8.9.1.1 Request
     *
     *  Returns:
     *    Iq id
     */
    getAffiliations: function(node, success, error) {
        var that = this._connection;
        var iqid = that.getUniqueId("pubsubaffiliations");

        if (typeof node === 'function') {
            call_back = node;
            node = undefined;
        }

        var attrs = {}, xmlns = {'xmlns':Strophe.NS.PUBSUB};
        if (node) {
            attrs.node = node;
            xmlns = {'xmlns':Strophe.NS.PUBSUB_OWNER};
        }

        var iq = $iq({from:this.jid, to:this.service, type:'get', id:iqid})
          .c('pubsub', xmlns).c('affiliations', attrs);

        that.sendIQ(iq.tree(), success, error);

        return iqid;
    },

    /**
     *  Parameters:
     *    (String) node -  The name of the pubsub node.
     *    (Function) call_back - Receives subscriptions.
     *
     *  http://xmpp.org/extensions/tmp/xep-0060-1.13.html
     *  8.9.2 Modify Affiliation - 8.9.2.1 Request
     *
     *  Returns:
     *    Iq id
     */
    setAffiliation: function(node, jid, affiliation, success, error) {
        var that = this._connection;
        var iqid = thiat.getUniqueId("pubsubaffiliations");

        var iq = $iq({from:this.jid, to:this.service, type:'set', id:iqid})
          .c('pubsub', {'xmlns':Strophe.NS.PUBSUB_OWNER})
          .c('affiliations', {'node':node})
          .c('affiliation', {'jid':jid, 'affiliation':affiliation});

        that.sendIQ(iq.tree(), success, error);

        return iqid;
    },

    /** Function: publishAtom
     */
    publishAtom: function(node, atoms, success, error) {
        if (!Array.isArray(atoms))
            atoms = [atoms];

        var i, atom, entries = [];
        for (i = 0; i < atoms.length; i++) {
            atom = atoms[i];

            atom.updated = atom.updated || (new Date()).toISOString();
            if (atom.published && atom.published.toISOString)
                atom.published = atom.published.toISOString();

            /* Rescue threading information because it does not get formatted with Builder::children */
            var in_reply_to = atom.in_reply_to;
            delete atom.in_reply_to;
            var entry = $build("entry", { xmlns:Strophe.NS.ATOM,
                                          'xmlns:thr':Strophe.NS.ATOM_THR })
                .children(atom);
            if (in_reply_to)
                entry.cnode($('<thr:in-reply-to/>').attr('ref', in_reply_to)[0]);
            entries.push({
                data: entry.tree(),
                attrs:(atom.id ? { id:atom.id } : {}),
            });
        }
        return this.publish(node, entries, success, error);
    },

    /**
     * TODO: filter for sender
     * TODO: should payload parsing go into strophe.buddycloud.js?
     */
    onEventNotification: function(stanza) {
        var hasEvent = false;
        Strophe.forEachChild(stanza, 'event', function(eventEl) {
            hasEvent = true;
        });
        if (hasEvent)
            this._callNotificationListeners(stanza);

        return true;
    },

    _callNotificationListeners: function(stanza) {
        this._notificationListeners.forEach(function(listener) {
            listener(stanza);
        });
    },

    addNotificationListener: function(listener) {
        this._notificationListeners.push(listener);
    }

});

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
    var aX = this.node.appendChild(Strophe.xmlElement('x', {"xmlns": "jabber:x:data", "type": "submit"}));
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
        this.node.appendChild(this._makeNode(tag, array[i].attrs))
          .appendChild(array[i].data.cloneNode
                     ? array[i].data.cloneNode(true)
                     : Strophe.xmlTextNode(array[i].data));
    }
    return this;
};

/* extend name space
 *  NS.PUBSUB - XMPP Publish Subscribe namespace from XEP 0060.
 */
Strophe.addNamespace('PUBSUB',                         "http://jabber.org/protocol/pubsub");
Strophe.addNamespace('PUBSUB_SUBSCRIBE_OPTIONS',       Strophe.NS.PUBSUB+"#subscribe_options");
Strophe.addNamespace('PUBSUB_ERRORS',                  Strophe.NS.PUBSUB+"#errors");
Strophe.addNamespace('PUBSUB_EVENT',                   Strophe.NS.PUBSUB+"#event");
Strophe.addNamespace('PUBSUB_OWNER',                   Strophe.NS.PUBSUB+"#owner");
Strophe.addNamespace('PUBSUB_AUTO_CREATE',             Strophe.NS.PUBSUB+"#auto-create");
Strophe.addNamespace('PUBSUB_PUBLISH_OPTIONS',         Strophe.NS.PUBSUB+"#publish-options");
Strophe.addNamespace('PUBSUB_NODE_CONFIG',             Strophe.NS.PUBSUB+"#node_config");
Strophe.addNamespace('PUBSUB_CREATE_AND_CONFIGURE',    Strophe.NS.PUBSUB+"#create-and-configure");
Strophe.addNamespace('PUBSUB_SUBSCRIBE_AUTHORIZATION', Strophe.NS.PUBSUB+"#subscribe_authorization");
Strophe.addNamespace('PUBSUB_GET_PENDING',             Strophe.NS.PUBSUB+"#get-pending");
Strophe.addNamespace('PUBSUB_MANAGE_SUBSCRIPTIONS',    Strophe.NS.PUBSUB+"#manage-subscriptions");
Strophe.addNamespace('PUBSUB_META_DATA',               Strophe.NS.PUBSUB+"#meta-data");

// Ideas Adding possible conf values?
// Added function getSubscriptions
// Added function getDefaultNodeConfig
// Added function getAffiliationsOfNode
// added jid to unsubscribe

/* Extend Strophe.Connection to have member 'pubsub'.
 */
Strophe.addConnectionPlugin('pubsub',
{
    _connection: null,
    _service: null,
    _autoService: true,

    // Called by Strophe.Connection constructor
    init: function(conn)
    {
        this._connection = conn;
    },

    // Called by Strophe on connection event
    statusChanged: function(status, condition)
    {
        if (this._autoService)
            this._service = status === Strophe.Status.CONNECTED ? 'pubsub.'+Strophe.getDomainFromJid(this._connection.jid) : null;
    },

    /** Function: setService
     *  Set pubsub service address. Use if 'pubsub.domain' isn't it.
     *
     *  Parameters:
     *    (String) service - service name
     */
    setService: function(service)
    {
        this._autoService = false;
        this._service = service;
    },

    /** Function: createNode
     *  Create a pubsub node on the service with the given node name.
     *
     *  Parameters:
     *    (String) node -  The name of the pubsub node.
     *    (Object) options -  The configuration options for the  node.
     *    (Function) call_back - Called on server response.
     *
     *  Returns:
     *    Iq id
     */
    createNode: function(node, options, call_back)
    {
        var iqid = this._connection.getUniqueId("createnode");

        var iq = $iq({from:this._connection.jid, to:this._service, type:'set', id:iqid})
          .c('pubsub', {xmlns:Strophe.NS.PUBSUB})
          .c('create',{node:node});
        if(options) {
            iq.up().c('configure').form(Strophe.NS.PUBSUB_NODE_CONFIG, options);
        }

        this._connection.addHandler(call_back, null, 'iq', null, iqid, null);
        this._connection.send(iq.tree());

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
    deleteNode: function(node, call_back)
    {
        var iqid = this._connection.getUniqueId("deletenode");

        var iq = $iq({from:this._connection.jid, to:this._service, type:'set', id:iqid})
          .c('pubsub', {xmlns:Strophe.NS.PUBSUB_OWNER})
          .c('delete', {node:node});

        this._connection.addHandler(call_back, null, 'iq', null, iqid, null);
        this._connection.send(iq.tree());

        return iqid;
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
    getConfig: function(node, call_back)
    {
        var iqid = this._connection.getUniqueId("configurenode");

        var iq = $iq({from:this._connection.jid, to:this._service, type:'get', id:iqid})
          .c('pubsub', {xmlns:Strophe.NS.PUBSUB_OWNER})
          .c('configure', {node:node});

        this._connection.addHandler(call_back, null, 'iq', null, iqid, null);
        this._connection.send(iq.tree());

        return iqid;
    },

    /** Function: subscribe
     *  Subscribe to a node in order to receive event items.
     *
     *  Parameters:
     *    (String) node -  The name of the pubsub node.
     *    (Object) options -  The configuration options for the  node.
     *    (Function) event_cb - Used to recieve subscription events (optional).
     *    (Function) call_back - Called on server response.
     *
     *  Returns:
     *    Iq id
     *
     *    TUOMAS added possibility to subscribe on bare or full JID
     */
    subscribe: function(node, options, event_cb, call_back, barejid)
    {
        var iqid = this._connection.getUniqueId("subscribenode");

        var jid = this._connection.jid;
        if(barejid) {
            jid = Strophe.getBareJidFromJid(this._connection.jid);
        }

        var iq = $iq({from:this._connection.jid, to:this._service, type:'set', id:iqid})
          .c('pubsub', { xmlns:Strophe.NS.PUBSUB })
          .c('subscribe', {'node':node, 'jid':jid});
        if(options) {
            iq.up().c('options').form(Strophe.NS.PUBSUB_SUBSCRIBE_OPTIONS, options);
        }

        this._connection.addHandler(call_back, null, 'iq', null, iqid, null);
        if (event_cb) this._connection.addHandler(event_cb, null, 'message', null, null, null);
        this._connection.send(iq.tree());

        return iqid;
    },

    /** Function: unsubscribe
     *  Unsubscribe from a node.
     *
     *  Parameters:
     *    (String) node -  The name of the pubsub node.
     *    (String) jid  -
     *    (String) subid - The subscription id (optional).
     *    (Function) call_back - Called on server response.
     *
     *  Returns:
     *    Iq id
     *
     *    TUOMAS added jid here
     */
    unsubscribe: function(node, jid, subid, call_back)
    {
        var iqid = this._connection.getUniqueId("unsubscribenode");

        var iq = $iq({from:this._connection.jid, to:this._service, type:'set', id:iqid})
          .c('pubsub', { xmlns:Strophe.NS.PUBSUB })
          .c('unsubscribe', {'node':node, 'jid':jid});
        if (subid) iq.attrs({subid:subid});

        this._connection.addHandler(call_back, null, 'iq', null, iqid, null);
        this._connection.send(iq.tree());

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
    getSubOptions: function(node, subid, call_back)
    {
        var iqid = this._connection.getUniqueId("suboptions");

        var iq = $iq({from:this._connection.jid, to:this._service, type:'get', id:iqid})
          .c('pubsub', {xmlns:Strophe.NS.PUBSUB})
          .c('options', {node:node, jid:this._connection.jid});
        if (subid) iq.attrs({subid:subid});

        this._connection.addHandler(call_back, null, 'iq', null, iqid, null);
        this._connection.send(iq.tree());

        return iqid;
    },

    /** Function: publish
     *  Publish a list of items to the given pubsub node.
     *
     *  Parameters:
     *    (String) node -  The name of the pubsub node.
     *    (Array) items -  See Strophe.Builder.list() array parameter.
     *    (Function) call_back - Called on server response.
     *
     *  Returns:
     *    Iq id
     */
    publish: function(node, items, call_back)
    {
        var iqid = this._connection.getUniqueId("publishnode");

        var iq = $iq({from:this._connection.jid, to:this._service, type:'set', id:iqid})
          .c('pubsub', { xmlns:Strophe.NS.PUBSUB })
          .c('publish', { node:node, jid:this._connection.jid })
          .list('item', items);

        this._connection.addHandler(call_back, null, 'iq', null, iqid, null);
        this._connection.send(iq.tree());

        return iqid;
    },

    /** Function: publishItem
     *  Publish a single item to the given pubsub node.
     *
     *  Parameters:
     *    (String) node -  The name of the pubsub node.
     *    (String | XML_element) data -  Item contents.
     *    (Object) attrs -  Item attributes (optional).
     *    (Function) call_back - Called on server response.
     *
     *  Returns:
     *    Iq id
     */
    publishItem: function(node, data, attrs, call_back) {
        return this.publish(node, [ {data: data, attrs: attrs ? attrs : {}} ], call_back);
    },

    /** Function: publishAtomEntry
     *  publishItem variant for ejabberd, which allows only one <item/> and it has to be an Atom entry :-\
     */
    publishAtomEntry: function(node, text, attrs, call_back)
    {
        var en = Strophe.xmlElement('entry', [['xmlns', 'http://www.w3.org/2005/Atom']]);
        en.appendChild(Strophe.xmlTextNode(text));
        return this.publishItem(node, en, attrs, call_back);
    },

    /** Function: items
     *  Retrieve the persistent items from the pubsub node.
     *
     *  Parameters:
     *    (String) node -  The name of the pubsub node.
     *    (Function) call_back - Called on server response.
     *
     *  Returns:
     *    Iq id
     */
    items: function(node, call_back)
    {
        var iq = $iq({from:this._connection.jid, to:this._service, type:'get'})
          .c('pubsub', { xmlns:Strophe.NS.PUBSUB })
          .c('items', {node:node});

        return this._connection.sendIQ(iq.tree(), call_back, call_back);
    },


    /** Tuomas added stuff */


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
    getSubscriptions: function(call_back)
    {
        var iqid = this._connection.getUniqueId("subscriptions");

        var iq = $iq({from:this._connection.jid, to:this._service, type:'get', id:iqid})
          .c('pubsub', {'xmlns':Strophe.NS.PUBSUB})
          .c('subscriptions');

        this._connection.addHandler(call_back, null, 'iq', null, iqid, null);
        this._connection.send(iq.tree());

        return iqid;
    },

    getNodeSubscriptions: function(node, call_back) {
       var iqid = this._connection.getUniqueId("subscriptions");

       var iq = $iq({from:this._connection.jid, to:this._service, type:'get', id:iqid})
         .c('pubsub', {'xmlns':Strophe.NS.PUBSUB_OWNER})
         .c('subscriptions', {'node':node});

       this._connection.addHandler(call_back, null, 'iq', null, iqid, null);
       this._connection.send(iq.tree());

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
    getDefaultNodeConfig: function(call_back)
    {
        var iqid = this._connection.getUniqueId("defaultnodeconfig");

        var iq = $iq({from:this._connection.jid, to:this._service, type:'get', id:iqid})
          .c('pubsub', {'xmlns':Strophe.NS.PUBSUB_OWNER})
          .c('default');

        this._connection.addHandler(call_back, null, 'iq', null, iqid, null);
        this._connection.send(iq.tree());

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
    getAffiliations: function(node, call_back)
    {
        var iqid = this._connection.getUniqueId("affiliations");

        var iq = $iq({from:this._connection.jid, to:this._service, type:'get', id:iqid})
          .c('pubsub', {'xmlns':Strophe.NS.PUBSUB_OWNER})
          .c('affiliations', {'node':node});
        if (node) iq.attrs({'node':node});

        this._connection.addHandler(call_back, null, 'iq', null, iqid, null);
        this._connection.send(iq.tree());

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
    setAffiliation: function(node, jid, affiliation, call_back)
    {
        var iqid = this._connection.getUniqueId("affiliations");

        var iq = $iq({from:this._connection.jid, to:this._service, type:'set', id:iqid})
          .c('pubsub', {'xmlns':Strophe.NS.PUBSUB_OWNER})
          .c('affiliations', {'node':node})
          .c('affiliation', {'jid':jid, 'affiliation':affiliation})

        this._connection.addHandler(call_back, null, 'iq', null, iqid, null);
        this._connection.send(iq.tree());

        return iqid;
    }
});

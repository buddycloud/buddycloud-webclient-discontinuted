
// export config
window.config = {

    /* address of the bosh gateway. this should be reachable from webclient domain */
    //bosh_service: 'http://beta.buddycloud.org:5280/http-bind/',
    bosh_service: 'https://beta.buddycloud.org:443/http-bind/', // secure
    //bosh_service: 'http://bosh.metajack.im:5280/xmpp-httpbind', // just for testing!

    /*this is the inbox domain for anon users */
    home_domain: "buddycloud.org",

    /* domain to authenticate against for anon users */
    anon_domain: "anon.buddycloud.org",

    /* overall used domain for this webclient instance.
     * used for registration and login. */
    domain: "buddycloud.org",

    topic_domain: "topics.buddycloud.org",

    embedly_key: "593c0a9858e611e188dc4040d3dc5c07",

    directoryService: "search.buddycloud.org",
};
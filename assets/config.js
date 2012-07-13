// export config
window.config = {

    /* address of the bosh gateway. this should be reachable from webclient domain */
    bosh_service: 'https://example.com:443/http-bind/',

    /* enable or disable registration */
    registration: true,

    /*this is the inbox domain for anon users */
    home_domain: "example.com",

    /* domain to authenticate against for annon users */
    anon_domain: "anon.example.com",

    /* overall used domain for this webclient instance.
     * used for registration and login. */
    domain: "example.com",

    /* Default domain to create topics under
     * unless the user specifies …@domain as the name. (see: https://buddycloud.org/wiki/Install#Advanced_Topics) */
    //topic_domain: "topics.example.com",
    directoryService: "search.buddycloud.org",

    /* Sign up for an embed.ly account to use OEmbed */
    embedly_key:undefined,

    /* list of url paths to the plugin file
     * e.g ["web/js/show-client-0.1.0.js"] */
    plugins: [],

};

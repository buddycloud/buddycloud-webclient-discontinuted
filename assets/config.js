
// export config
window.config = {

    /* address of the bosh gateway. this should be reachable from webclient domain */
    bosh_service: 'https://beta.buddycloud.org:443/http-bind/',

    /*this is the inbox domain for anon users */
    home_domain: "example.com",

    /* domain to authenticate against for anon users */
    anon_domain: "anon.example.com",

    /* overall used domain for this webclient instance.
     * used for registration and login. */
    domain: "example.com",

    /* Default domain to create topics under
     * unless the user specifies …@domain as the name. */
    //topic_domain: "topics.example.com",

    /* Sign up for an embed.ly account to use OStatus */
    //embedly_key: "xxx"
};

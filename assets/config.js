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
    
    /* text for the homepage */
    homepage-text: "Share, discover, communicate in a magically simple way." 
    + "<p>"
    + "buddycloud is a new kind of social network. In your buddycloud channel you can communicate "
    + "and share with other thinkers and makers: buddycloud’s easy to understand privacy model and "
    + "strong encryption keep you safe online."
    + "<ul>"
    + "<li>create channels and share them with the world or keep them private</li>"
    + "<li>share your photos, movies and ideas about any subject</li>"
    + "<li>discover great channels from other buddycloud users around the world</li>"
    + "<p>"
    + "Learn more <a href='http://buddycloud.com/features'>about buddycloud</a>."
    + "<p>"
    + "For help with this buddycloud on" + $domain "contact <a href='mailto:your-friendly-sysadmin@example.org'>your friendly sysadmin'</a>"
    + "Coming soon for Android™ and iPhone®.",

    /* Default domain to create topics under
     * unless the user specifies …@domain as the name. (see: https://buddycloud.org/wiki/Install#Advanced_Topics) */
    //topic_domain: "topics.example.com",

    directoryService: "search.buddycloud.org",

    /* enable store password checkbox by default when true */
    store_credential_default: true,

    /* Sign up for an embed.ly account to use OEmbed */
    embedly_key:undefined,

    /* list of url paths to the plugin file
     * e.g ["web/js/show-client-0.1.0.js"] */
    plugins: [],

};

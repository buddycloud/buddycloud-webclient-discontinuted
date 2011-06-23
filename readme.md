This is the brunch and coffeescript rewrite of the buddycloud webclient to implment the buddycloud protocol

# protocol

The [current draft](http://buddycloud.org/wiki/XMPP_XEP) should be submitted to the XEP standardisation process in mid-2011

# buddycloud server implementations

This The XMPP extensions that Buddycloud describes have been implemented in two projects:

* [Node.js channel server](https://github.com/buddycloud/channel-server)
* [java channel server](https://github.com/buddycloud/channel-server-java)

# Installation

make sure you have [npm](http://npmjs.org) installed.

    ./configure
    ./build.sh


This repository needs to be in the webroot of your computer. On OS X - you can set up a vhost by editing:

    /private/etc/apache2/extra/httpd-vhosts.conf

And adding a section like this:

# Use name-based virtual hosting.
NameVirtualHost *:80

    <VirtualHost *:80>
            ServerName buddycloud.local
            DocumentRoot /Users/someone/programming/buddycloud-web-client
            Options Indexes FollowSymLinks MultiViews
            <Directory />
                    AllowOverride All
                    Order allow,deny
                    Allow from all
            </Directory>
    </VirtualHost>

Then edit your `/etc/hosts` file and add an entry like:

    127.0.0.1       buddycloud.local

Restart apache with `sudo apachectl restart` and you should be able to browse to the web client at [http://buddycloud.local/](buddycloud.local). Linux is as above but your vhost configuration will be different.
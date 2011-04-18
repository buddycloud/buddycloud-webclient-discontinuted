This is the Buddycloud web client. See my [introduction](http://bennolan.com/2011/04/12/distributed-social-networking.html) at [bennolan.com](http://bennolan.com/). It is a Javascript + PHP implementation of a social network powered by XMPP.

# Funding

The original Diaspora-x codebase that this project is an extension of was created by Ben Nolan as a part-time project. Further development has been kindly funded by Imaginator Ltd, operators of buddycloud.com.

# Buddycloud protocol

The buddycloud protocol is being submitted as a XEP. The [current draft](http://buddycloud.org/wiki/XMPP_XEP) should be submitted in mid-2011.

# Buddycloud server implementations

The XMPP extensions that Buddycloud describes have been implemented in three projects:

* [Node.js server](https://github.com/buddycloud/channel-server)
* [Prosody implementation](http://buddycloud.com/cms/content/buddycloud-channels-built-prosody)
* The original ejabberd implementation of Buddycloud channels (obsolete)

# Installation

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

The PHP API isn't enabled at the moment, but in the future we will be using .htaccess and php5, so revisit this installation section in the future.

# Compiling the .jst files

You will see that we use .jst templates for index.html and /spec/index.html. These .jst templates are compiled using [capt](https://github.com/bnolan/capt). If you checkout capt and install it to `/usr/local/bin` you should be able to 

# API

The php aspects of the client provide an API for services that cannot be easily done on the client, eg - automated sending of email and uploading of images.

## Authentication

All requests to the API must be authenticated using http-auth with the the users jid and password. Requests should be over https. The api will connect to the users jabber server to ensure the password is correct. This authentication check against the jabber server will only happen once per session.

## /api/email

    { data : [ {
        recipient : "friend@gmail.com",
        subject : "Visit me on Diaspora-x",
        message : "Hey Friend, come join me at..."
      }, { ... }, { ...} ]
    }

Used to send invitation or notification emails. Returns `{ success : true }` on success. Does no validation on the subject, recipient or message. Does not support html messages. The reply-to is set as "no-reply@DOMAIN". The from is the jid of the authenticated user.

# Licence

Copyright 2010-2011 Ben Nolan

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

# Assorted notes follow - 

## References

* http://onesocialweb.org/spec/1.0/osw-activities.html
* http://xmpp.org/extensions/xep-0277.html#reply

## Content licence

Users should be able to select their own licence. By default the licence should be creative commons. The licence should be attached to content using [RFC 4946](http://tools.ietf.org/html/rfc4946).

# Enabling ejabberdctl

To allow register / delete / reset password on users - you need to enable ejabberdctl for the web user. The easiest way to do this is:

    cp /var/lib/ejabberd/.erlang.cookie ~ben
    
    
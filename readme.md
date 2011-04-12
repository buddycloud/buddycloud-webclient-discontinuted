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

Requires [capt](http://github.com/bnolan/capt) and php5. (todo - this section needs expansion)

# API

The php aspects of the client provide an API for services that cannot be easily done on the client, eg - automated sending of email and uploading of images.

## Authentication

All requests to the API must be authenticated using http-auth with the the users jid and password. Requests should obviously be over https. The api will connect to the users jabber server to ensure the password is correct. This authentication check against the jabber server will only happen once per session.

## /api/email

    { data : [ {
        recipient : "friend@gmail.com",
        subject : "Visit me on Diaspora-x",
        message : "Hey Friend, come join me at..."
      }, { ... }, { ...} ]
    }

Used to send invitation emails to friends. Returns `{ success : true }` on success.

# Licenced under the BSD

Copyright 2010 Ben Nolan. All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are
permitted provided that the following conditions are met:

   1. Redistributions of source code must retain the above copyright notice, this list of
      conditions and the following disclaimer.

   2. Redistributions in binary form must reproduce the above copyright notice, this list
      of conditions and the following disclaimer in the documentation and/or other materials
      provided with the distribution.

THIS SOFTWARE IS PROVIDED BY BEN NOLAN ``AS IS'' AND ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL BEN NOLAN OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

The views and conclusions contained in the software and documentation are those of the
authors and should not be interpreted as representing official policies, either expressed
or implied, of Ben Nolan.

# Assorted notes follow - 

## References

* http://onesocialweb.org/spec/1.0/osw-activities.html
* http://xmpp.org/extensions/xep-0277.html#reply

## Content licence

Users should be able to select their own licence. By default the licence should be creative commons. The licence should be attached to content using [RFC 4946](http://tools.ietf.org/html/rfc4946).


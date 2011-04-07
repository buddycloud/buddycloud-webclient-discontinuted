#!/bin/sh

# Starts a local nginx to:
# * Serve static files
# * Proxy BOSH XMPP HTTP binding

nginx -c nginx.conf -p `pwd`/

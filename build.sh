#!/bin/sh -e
echo 'brunching bits...'
./node_modules/.bin/brunch build --minify $@
echo 'packing bits of awesomeness...'
rm -f build.tar.gz
( cd brunch/build && tar cpzf ../../build.tar.gz * )
echo 'done.'

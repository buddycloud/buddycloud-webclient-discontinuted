#!/bin/sh
echo 'packing bits of awesomeness ...'
./node_modules/.bin/brunch build --minify $@
echo 'done.'

#!/bin/sh
echo 'packing bits of awesomeness ...'
./node_modules/.bin/brunch --minify build $@
echo 'done.'

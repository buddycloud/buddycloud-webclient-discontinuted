Place plugins in this directory. File structure should be as follows:

<plugin-name>-<version>/<plugin-name>.js

Then configure in config.js as follows:

plugins: {
    '<plugin-name>':  '<version>',
    '<plugin2-name>': '<version2>',
}

For example:

plugins: {
    'show-client': '0.1.0'
}

For examples of plugins please see https://github.com/lloydwatkin/buddycloud/buddycloud-webclient-plugins

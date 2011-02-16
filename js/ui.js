var cl = new Channels.ChannelsClient('astro@hq.c3d2.de', '***');

$(document).load(function() {
    $('#wrap').hide();
    cl.onConnect = function() {
	$('#wrap').show();
    };
});

cl.on('newService', function(service) {
    service.on('newNode', function(node) {
	var m;
	if ((m = node.name.match(/^\/user\/([^\/]+)/))) {
	}
    });
});


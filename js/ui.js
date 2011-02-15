var cl = new Channels.ChannelsClient('astro@hq.c3d2.de', '***');

$(document).load(function() {
    $('#wrap').hide();
    cl.onConnect = function() {
	$('#wrap').show();
    };
});

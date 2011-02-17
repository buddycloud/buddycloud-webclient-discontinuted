var cl = new Channels.ChannelsClient('astro@hq.c3d2.de', '***');

$(document).load(function() {
    $('#wrap').hide();
    cl.onConnect = function() {
	$('#wrap').show();
    };
});


/** by user id */
var myChannelViews = {};

cl.on('newService', function(service) {
    service.on('newNode', function(node) {
	var m;
	if ((m = node.name.match(/^\/user\/([^\/]+)/))) {
	    var user = m[1];
	    if (!myChannelViews.hasOwnProperty(user))
		myChannelViews[user] = new MyChannelView(user);
	    myChannelViews[user].addNode(node);
	}
    });
});

function MyChannelView(user) {
    this.user = user;
    this.nodes = {};

    this.div = $('<div class="channel"><div class="avatar"><img src="/img/avatar.gif" alt="" /><span class="count">55</span></div><ul><li class="ci1"></li><li class="ci2"><span class="cict1">sobering up</span><span class="cict2">Home sweet home</span><span class="cict3 strike">Schwabinger 7</span></li></ul></div>');
    $('#col1').append(this.div);

    this.update();
}

MyChannelView.prototype.addNode = function(node) {
    var that = this;
    node.on('update', function() {
	that.update();
    });

    this.nodes[node.name] = node;
    this.update();
};

MyChannelView.prototype.update = function() {
    this.div.find('.ci1').text(this.user);

    var channelNode = this.nodes['/user/' + this.user + '/channel'];
    if (channelNode) {
	var channelDiv = this.div.find('.ci3');
	if (channelDiv.length < 1) {
	    channelDiv = $('<li class="ci3"><span class="cict4"></span></li>');
	    this.div.find('ul').append(channelDiv);
	}
	channelDiv.find('.cict4').text('TTT');
    }
};

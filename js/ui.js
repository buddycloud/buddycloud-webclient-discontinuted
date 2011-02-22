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

/**
 * Subscribed channel summaries on the left
 */

function MyChannelView(user) {
    var that = this;
    this.user = user;
    this.nodes = {};

    this.div = $('<div class="channel"><div class="avatar"><img src="/img/avatar.gif" alt="" /><span class="count">55</span></div><ul><li class="ci1"></li><li class="ci2"><span class="cict1">sobering up</span><span class="cict2">Home sweet home</span><span class="cict3 strike">Schwabinger 7</span></li><li class="ci3"></li></ul></div>');
    $('#col1').append(this.div);

    var subview = function(parent, template, getter) {
	parent = that.div.find(parent)[0];
	var isVisible = false, label;
	return { update: function() {
		     var value = undefined;
		     try {
			 value = getter();
		     } catch (e) {
			 console.error(e.stack);
		     }

		     if (value && !isVisible) {
			 console.log(parent + ' show');
			 label = $(template);
			 $(parent).append(label);
			 isVisible = true;
		     } else if (!value && isVisible) {
			 console.log(parent + ' hide');
			 label.remove();
			 label = undefined;
			 isVisible = false;
		     }

		     console.log(parent + ' contains ' + value);
		     if (value && label)
			 label.text(value);
		 } };
    };
    this.views = [subview('.avatar', '<img alt="Avatar" />', function() {
			      return "/img/avatar.gif";
			  }),
		  subview('.ci1', '<span></span>', function() {
			      return that.user;
			  }),
		  subview('.ci3', '<span class="cict4"></span>', function() {
			      var channelNode = that.nodes['/user/' + that.user + '/channel'];
			      var lastItem = channelNode && channelNode.getLastItem();
			      if (lastItem)
				  console.log({lastItem:lastItem,user:that.user,channelNode:channelNode});
			      return lastItem && $($(lastItem).find('title')[0] || $(lastItem).find('content')[0]).text();
			  })];

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
    for(var i = 0; i < this.views.length; i++)
	this.views[i].update();
};

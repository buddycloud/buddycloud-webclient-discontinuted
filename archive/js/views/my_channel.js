/**
 * Get text content of the last entry of a node.
 */
function peek(channel, nodeTail) {
    var node = channel.getNode(nodeTail);
    var item = node && node.getLastItem();
    return item && item.getTextContent();
}


/**
 * col1 MyChannelView
 *
 * TODO:
 * * indicate loading state
 * * filter by actual subscribed channels
 */
 var MyChannelView = Backbone.View.extend({
    initialize: function(channel) {
        this.channel = channel;
        this.el = $(this.template);
         _.bindAll(this, 'render');
        channel.bind('change', this.render);
        channel.bind('change:items', this.render);
        channel.bind('all', function(ev) {
            console.log('channel ' + channel.get('id') + ' - ' + ev);
        });
	this.render();
    },

    render: function() {
	this.$('.avatar img').attr('src', this.channel.getAvatarURL());

        var jid = this.channel.get('id');
	this.$('.ci1 a').text(jid);
	this.$('.ci1 a').attr('href', '#browse/' + jid);

	var geoPrevious = peek(this.channel, 'geo/previous');
	var geoCurrent = peek(this.channel, 'geo/current');
	var geoFuture = peek(this.channel, 'geo/future');
	if (geoFuture || geoCurrent || geoPrevious) {
	    this.$('.ci2').show();
	    this.$('.ci2 .cict1').text(geoFuture);
	    this.$('.ci2 .cict2').text(geoCurrent);
	    this.$('.ci2 .cict3').text(geoPrevious);
	} else
	    this.$('.ci2').hide();

        var channelLast = peek(this.channel, 'channel');
	if (channelLast) {
	    this.$('.ci3').show();
	    this.$('.ci3').text(channelLast);
	} else
	    this.$('.ci3').hide();
    }
});

$(function() {
    MyChannelView.prototype.template = $('#my_channel_template').html();
});

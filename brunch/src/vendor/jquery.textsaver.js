/*
	textSaver.js v0.1.1
	Copyright (c) 2011 David Hu (http://d.aweed.us)
	Licensed under the GNU General Public License v3 (http://www.gnu.org/licenses/gpl.html)
	
	For more information, see: http://d.aweed.us/textsaver
*/

(function($) {
	var tsVars = {
		noNameCounter: 0,
		n: 0, // used in case we need to keep track of multiple forms (for submitting/clearing purposes)
		tsNames: []
	};
	$.fn.textSaver = function() {
		return this.each(function() {
			var m = tsVars.n;
			tsVars.tsNames[m] = [];
			if($(this).get(0).tagName == "FORM") {
				$(this).children("input, textarea").each(function() {
					ts($(this), m);
				});
				$(this).submit(function() {
					for(var k in tsVars.tsNames[m]) {
						localStorage.removeItem(tsVars.tsNames[m][k]);
					}
				});
			} else {
				ts($(this), m);
			}
			tsVars.n++;
		});
	}
	
	function ts(obj, m) {
		var tsName = get_tsName(obj, m);
		if(localStorage.getItem(tsName) != null) {
			obj.val(localStorage.getItem(tsName));
		}
		obj.bind('keyup', function() {
			localStorage.setItem(tsName, obj.val());
		});
	}
	
	function get_tsName(obj, m) {
		var tsName = obj.parent().attr('id');
		if(tsName === '') {
			tsName = window.location.host+window.location.pathname;
		}
		if(obj.attr('name') !== '') {
			tsName += '_'+obj.attr('name');
		} else {
			tsName += "_"+obj.get(0).tagName;
			tsName += tsVars.noNameCounter;
			tsVars.noNameCounter++;
		}
		tsName += "_ts";
		tsVars.tsNames[m].push(tsName);
		return tsName;
	}

})(jQuery);
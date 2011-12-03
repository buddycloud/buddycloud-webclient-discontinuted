
(function($){

    $.fn.autoResize.AutoResizer.prototype.bind = function() {

        var check = $.proxy(function(){
            this.check();
            return true;
        }, this);

        this.unbind();

        // use the special oninput event
        this.el.input(function() {
            setTimeout(function() { check(); }, 0);
        });

        if (!this.el.is(':hidden')) {
            this.check(null, true);
        }

    };

})(jQuery);

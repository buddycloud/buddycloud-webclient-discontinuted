// by dodo

(function( $ ) {

    //constants
    var classprefix = "auto-suggestion-";

    $.fn.autoSuggestion = function (options) {
        options = options || {};
        options.suffix = options.suffix || "";

        return this.each(function () {
            var el = $(this);

            // creating a completly new input field
            var input = $("<input type=\""+el.prop('type')+"\" "+
                "class=\""+classprefix+"input\" "+
                "id=\""+classprefix+el.prop('id')+"\"/>");


            var suffix = options.suffix;
            if (typeof options.suffix === 'function')
                suffix = options.suffix(el.val());
            // creating the area where the suggestions can be showen
            var preview = $("<div class=\""+classprefix+"preview\">"+
                //"<span class=\""+classprefix+"prefix\"></span>"+ TODO
                "<span class=\""+classprefix+"content\"></span>"+
                "<span class=\""+classprefix+"suffix\">"+suffix+"</span>"+
                "&nbsp;</div>");

            var container = $("<div class=\""+classprefix+"container\"></div>");

            // add the children
            container.append(input);
            container.append(preview);

            // set needed css properties
            input.css('position', "absolute");
            input.css('z-index', el.css('z-index'));
            input.css('z-index', "+=1");
            preview.copyCSS(el);

            if (el.attr('placeholder'))
                input.prop('placeholder', el.prop('placeholder'));

            // don't show original input field
            el.prop('type', "hidden");

            // patch all labels for the old input box to the new one, so focus is still right
            $("label[for="+el.prop('id')+"]").each(function () {
                $(this).prop('for', classprefix+el.prop('id'));
            });

            // pipe keys through
            input.keyup(function (ev) {
                var code = ev.keyCode || ev.which;
                var val = input.val();
                if (ev.type === 'keydown') {
                    if ((31 < code && code < 127) || code > 159)
                        val += String.fromCharCode(code);
                }
                preview.find('.'+classprefix+'content').text(val+" ");
                el.val(val);
                if (typeof options.suffix === 'function') {
                    var suffix = options.suffix(val);
                    preview.find('.'+classprefix+'suffix').text(suffix);
                    el.val(val+suffix);
                }
            });

            // insert into dom
            el.before(container);
            el.hide();
        });
    };


})( jQuery );

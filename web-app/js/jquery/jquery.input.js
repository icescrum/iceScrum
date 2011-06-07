(function($) {

    var helper = {}

    $.input = {
        defaults: {
            'className': 'input'
        }
    };

    $.fn.extend({
                input: function(settings) {

                    settings = $.extend({}, $.input.defaults, settings);

                    return this.each(function() {
                        var elt = $(this);
                        var input = $(this).find('input, textarea');

                        input.focus(
                                function() {
                                    elt.addClass(settings.className + "-focus");
                                }).blur(function() {
                                    elt.removeClass(settings.className + "-focus");
                                });
                    });
                }
            });

    $.fn.extend({
                inputFocus: function(settings) {

                    settings = $.extend({}, $.input.defaults, settings);

                    return this.each(function() {
                        var elt = $(this);
                        var input = $(this).find('input, textarea');
                        elt.addClass(settings.className + "-focus");
                        input.focus();
                    });
                }
            });


})(jQuery);
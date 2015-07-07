(function ($) {
    $.extend($.icescrum, {
        startTour: function (tourName, autoStart) {
            $('#script-tour-' + tourName).remove();
            $(document.body).append('<script type="text/javascript" id="script-tour-' + tourName + '" src="' + $.icescrum.o.baseUrlSpace + 'guidedTour?tourName=' + tourName + '&autoStart=' + (autoStart ? true : false) + '"/>');
        }
      })
}(jQuery));

(function($) {

    $.fn.progress = function(options) {

        var settings = {
            timer:500,
            label:"",
            showOnCreate:false,
            className:null,
            iframe:false,
            iframeSrc:null,
            startValue:0,
            url:null,
            before:function(xhr) {
            },
            onComplete:function(ui, data) {
            },
            onError:function(ui, data) {
            },
            startOn:null,
            startOnWhen:null,
            animated:true,
            labelError:"Error",
            params:{},
            timerID:"timer" + new Date().getTime()
        };

        if (options) {
            $.extend(settings, options);
        }

        var self = $(this);
        self.data('settings', settings);
        $(this).addClass(settings.className);

        if (!self.data('settings').showOnCreate) {
            self.hide();
        }

        var label = $('<span>').addClass('label');
        label.appendTo(self);

        if (self.data('settings').iframe) {
            self.append('<iframe style="display:none;" src="' + self.data('settings').iframeSrc + '"/>');
        }
        self.progressbar({value: self.data('settings').startValue});
        self.addClass('is-progressbar');

        if (settings.animated) {
            self.find('.ui-progressbar-value').addClass('animated');
        }

        label.text(self.data('settings').label);
        var statusTracker = function() {
            if (!self.is(':visible')) {
                self.css('display', 'block')
            }
            if (self.data('settings') == null) {
                return false;
            }
            jQuery.ajax({type:'GET',
                        url: self.data('settings').url,
                        global:false,
                        cache:false,
                        beforeSend:self.data('settings').before,
                        data:self.data('settings').params,
                        success:function(data, textStatus) {
                            if (!self.is(':visible')) {
                                return;
                            }
                            if (data.value == null) {
                                data.value = Math.round(data.bytesReceived * 100 / data.bytesLength);
                                data.label = data.value + "%";
                            }
                            if (data.error && !self.data('complete')) {
                                label.text('Error');
                                self.find('.ui-progressbar-value').addClass('ui-progressbar-value-error')
                                self.progressbar('value', data.value);
                                self.data('settings').onError(self, data);
                                self.trigger('error', [ self,data ]);
                            }
                            else if (!self.data('complete')) {
                                $.doTimeout(self.data('settings').timer, function() {
                                    statusTracker()
                                });
                                self.progressbar('value', data.value);
                                label.text(data.label);
                                self.data('complete', false);

                            }
                            if (data.complete && !self.data('complete')) {
                                self.data('complete', true);
                                self.trigger('complete', [ self,data ]);
                            }
                            if (self.data('complete')) {
                                $.doTimeout(self.data('settings').timerID);
                                self.data('settings').onComplete(self, data);
                            }
                        },
                        error:function(XMLHttpRequest, textStatus, errorThrown) {
                            if (!self.data('complete') && self.is(':visible')) {
                                self.find('.ui-progressbar-value').addClass('ui-progressbar-value-error');
                                self.progressbar('value', 100);
                                label.text(self.data('settings').labelError);
                                self.data('settings').onError(self, $.parseJSON(XMLHttpRequest.responseText));
                                self.trigger('error', [ self,$.parseJSON(XMLHttpRequest.responseText)]);
                            }
                        }
                    });
        };

        if (self.data('settings').startOn == null || self.data('settings').startOnWhen == null) {
            $.doTimeout(self.data('settings').timer, function() {
                statusTracker()
            });
        } else {
            $(self.data('settings').startOn).bind(self.data('settings').startOnWhen, function() {
                $.doTimeout(self.data('settings').timer, function() {
                    statusTracker()
                });
            });
        }
    };

})(jQuery);
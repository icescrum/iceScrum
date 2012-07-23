(function($) {

    jQuery.extend($.icescrum, {
                addToWidgetBar:function(id, callback) {
                    if ($.inArray(id, this.o.widgetsList) == -1) {
                        jQuery.ajax({
                                    type:'GET',
                                    global:false,
                                    url:this.o.urlOpenWidget + '/' + id,
                                    success:function(data, textStatus) {
                                        if ($.inArray(id, $.icescrum.o.widgetsList) == -1) {
                                            $(data).appendTo($.icescrum.o.widgetContainer);
                                            $.icescrum.o.widgetsList.push(id);
                                            if (callback) {
                                                callback();
                                            }
                                        }
                                    },
                                    error:function() {
                                        $.icescrum.o.widgetsList = $.grep($.icescrum.o.widgetsList, function(value) {
                                            return value != id;
                                        });
                                    }
                                });
                    }
                    return false;
                },

                widgetToWindow:function(obj, event) {
                    var opts = obj.data('opts');
                    $.icescrum.openWindow(obj.data('id'));
                    this.stopEvent(event);
                },

                closeWidget:function(obj, event) {
                    var opts = obj.data('opts');
                    $.icescrum.o.widgetsList = $.grep($.icescrum.o.widgetsList, function(value) {
                        return value != obj.data('id');
                    });
                    var callback;
                    if (event) {
                        callback = function() {
                            jQuery.ajax({
                                        type:'GET',
                                        url:$.icescrum.o.urlCloseWidget + '/' + obj.data('id'),
                                        success:function(data, textStatus) {
                                            obj.remove();
                                        }
                                    });
                        };
                    } else
                        callback = function() {
                            obj.remove();
                        };

                    obj.effect('blind', null, 'fast', callback);
                    if (opts && opts.onClose)
                        opts.onClose();

                    if (event)
                        this.stopEvent(event);
                }
            });

    $.fn.isWidget = function(options) {
        var opts = $.extend({}, $.fn.isWidget.defaults, options);
        var obj = $(this);
        var widgetid = $(this).attr('id');
        var id = widgetid.substring(widgetid.lastIndexOf("-") + 1, widgetid.length);
        var iconWindow;

        obj.data('opts', opts);
        obj.data('widgetid', widgetid);
        obj.data('id', id);

        if (opts.windowable) {
            iconWindow = $("#" + widgetid + ' .widget-maxicon');
            iconWindow.parent().bind('click', function(event) {
                $.icescrum.widgetToWindow(obj, event)
            });
            iconWindow.parents('.resizable:first').bind('dblclick', function(event) {
                $.icescrum.widgetToWindow(obj, event)
            });
            obj.addClass('draggable-to-desktop');
        }

        if (opts.closeable) {
            $("#" + widgetid + ' .widget-close').bind('click', function(event) {
                $.icescrum.closeWidget(obj, event)
            });
        }

        if (opts.resizable) {

            var content = $("#widget-content-" + id, obj);
            var dif = obj.height() - content.height();
            var savedHeight = $.icescrum.product.id ? $.cookie('widget-'+id+$.icescrum.product.id) : null;
            if (savedHeight && $(content.children()[0]).height() > savedHeight){
                content.height(savedHeight);
            }

            opts.resizable.minWidth = obj.width();
            opts.resizable.maxWidth = obj.width();
            opts.resizable.start = function(event, ui){
                obj.resizable('option','maxHeight',$(content.children()[0]).height() + dif);
            };
            opts.resizable.resize = function(event, ui){
                content.height(ui.size.height - dif);
            };
            opts.resizable.stop = function(event, ui){
                $.cookie('widget-'+id+$.icescrum.product.id,ui.size.height - dif);
            };

            obj.resizable(opts.resizable);
        }
    };

})(jQuery);

$.fn.isWidget.defaults = {
    windowable:false,
    resizable:null,
    closeable:true,
    onClose:null
};
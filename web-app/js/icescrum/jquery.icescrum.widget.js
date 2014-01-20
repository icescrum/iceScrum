(function($) {

    jQuery.extend($.icescrum, {
                addToWidgetBar:function(id, callback) {
                    if ($.inArray(id,  $.icescrum.getWidgetsList()) == -1) {
                        $.icescrum.addToWidgetsList(id);
                        jQuery.ajax({
                                type:'GET',
                                url:this.o.urlOpenWidget + '/' + id,
                                success:function(data) {
                                    if (data == ''){
                                        $.icescrum.removeFromWidgetsList(id);
                                    } else{
                                        var widget = $(data).appendTo($.icescrum.o.widgetContainer);
                                        if (callback) {
                                            callback();
                                        }
                                        $(widget[0]).isWidget($(widget[0]).html5data('is'));
                                        attachOnDomUpdate(widget[0]);
                                    }
                                },
                                error:function() {
                                    $.icescrum.removeFromWidgetsList(id);
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
                    obj.effect('blind', null, 'fast', function() { obj.remove(); });
                    this.removeFromWidgetsList(obj.data('id'));
                    if (opts && opts.onClose)
                        opts.onClose();
                    if (event)
                        this.stopEvent(event);
                },

                saveWidgetsList:function(widgetsList){
                    var key = 'widgets-' + ($.icescrum.product.id ? $.icescrum.product.id : 'noproduct') + '-' +($.icescrum.user.id ? $.icescrum.user.id : 'anonymous');
                    localStorage[key] = JSON.stringify($.unique(widgetsList));
                },

                getWidgetsList:function(){
                    var key = 'widgets-' + ($.icescrum.product.id ? $.icescrum.product.id : 'noproduct') + '-' +($.icescrum.user.id ? $.icescrum.user.id : 'anonymous');
                    return localStorage[key] ? JSON.parse(localStorage[key]) : [];
                },

                removeFromWidgetsList:function(id){
                    var list = $.grep(this.getWidgetsList(), function(value) {
                        return value != id;
                    });
                    this.saveWidgetsList(list);
                },

                addToWidgetsList:function(id){
                    var list = this.getWidgetsList();
                    list.push(id);
                    this.saveWidgetsList(list);
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
            iconWindow = $("#" + widgetid + ' .widget-window');
            iconWindow.parent().bind('click', function(event) {
                $.icescrum.widgetToWindow(obj, event)
            });
            iconWindow.parents('.resizable:first').bind('dblclick', function(event) {
                $.icescrum.widgetToWindow(obj, event)
            });
            obj.addClass('draggable-to-main');
        }

        if (opts.closeable) {
            $("#" + widgetid + ' .widget-close').bind('click', function(event) {
                $.icescrum.closeWidget(obj, event)
            });
        }

        if (opts.resizableOptions) {

            var content = $("#widget-content-" + id, obj);
            var dif = obj.height() - content.height();
            var savedHeight = $.icescrum.product.id ? parseInt(localStorage['widget-'+id+$.icescrum.product.id]) : null;

            if ($('.box-blank', content).is(':visible')){
                content.height(opts.resizableOptions.minHeight);
            }else{
                if (savedHeight && $(content.children()[0]).height() > savedHeight){
                    content.height(savedHeight);
                }else if (!savedHeight && $(content.children()[0]).height() > opts.resizableOptions.defaultHeight){
                    content.height(opts.resizableOptions.defaultHeight);
                }
            }
            content.css('max-height', savedHeight ? savedHeight : opts.resizableOptions.defaultHeight);
            opts.resizableOptions.minHeight += dif;
            opts.resizableOptions.zIndex = 990;
            opts.resizableOptions.minWidth = obj.width();
            opts.resizableOptions.maxWidth = obj.width();
            opts.resizableOptions.handles = 'se';
            opts.resizableOptions.start = function(event, ui){
                var totalHeight = $(content.children()[0]).height() + dif;
                obj.resizable('option','maxHeight', totalHeight >= opts.resizableOptions.minHeight ? totalHeight : opts.resizableOptions.minHeight);
            };
            opts.resizableOptions.resize = function(event, ui){
                content.css('max-height','none');
                content.height(ui.size.height - dif);
            };
            opts.resizableOptions.stop = function(event, ui){
                localStorage['widget-'+id+$.icescrum.product.id] = ui.size.height - dif;
            };
            obj.resizable(opts.resizableOptions);
        }
    };

})(jQuery);

$.fn.isWidget.defaults = {
    windowable:false,
    resizableOptions:{},
    closeable:true,
    onClose:null
};
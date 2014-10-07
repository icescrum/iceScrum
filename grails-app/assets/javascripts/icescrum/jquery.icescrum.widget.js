(function($) {

    jQuery.extend($.icescrum, {
                openWidget:function(id, callback, force) {
                    if ($.inArray(id, this.getWidgetsList()) == -1 || force){
                        jQuery.ajax({
                            type:'GET',
                            url:this.o.urlOpenWidget + '/' + id,
                            success:function(data) {
                                if (data){
                                    var widget = $(data).appendTo($.icescrum.o.widgetContainer);
                                    if (callback) {
                                        callback();
                                    }
                                    $(widget[0]).isWidget($(widget[0]).data('is'));
//                                    attachOnDomUpdate(widget[0]);
                                }
                            },
                            complete:function() {
                                $.icescrum.manageWidgetsList();
                            }
                        });
                        return false;
                    }
                },

                widgetToWindow:function(obj, event) {
                    var opts = obj.data('opts');
                    $.icescrum.openWindow(obj.data('id'));
                    this.stopEvent(event);
                },

                closeWidget:function(obj, event) {
                    var opts = obj.data('opts');
                    obj.fadeOut({done:function() {
                        obj.remove();
                        $.icescrum.manageWidgetsList();
                    }});
                    if (opts && opts.onClose)
                        opts.onClose();
                    if (event)
                        this.stopEvent(event);
                },

                manageWidgetsList:function(){
                        var key = 'widgets-' + ($.icescrum.product.id ? $.icescrum.product.id : 'noproduct') + '-' +($.icescrum.user.id ? $.icescrum.user.id : 'anonymous');
                        var list = $(".widget").map(function(){return $(this).data("widgetName");}).get();
                        localStorage[key] = JSON.stringify(list);
                        this.checkSidebar();
                },

                getWidgetsList:function(){
                    var key = 'widgets-' + ($.icescrum.product.id ? $.icescrum.product.id : 'noproduct') + '-' +($.icescrum.user.id ? $.icescrum.user.id : 'anonymous');
                    return localStorage[key] ? JSON.parse(localStorage[key]) : [];
                },

                checkSidebar:function(){
                    var list = this.getWidgetsList();
                    var $sidebar = $('#sidebar');
                    var $container = $sidebar.parent();
                    if ($sidebar.find('> .alert').length > 0){
                        localStorage['sidebar'] = null;
                    }
                    if(localStorage['sidebar'] == 'true'){
                        $container.addClass('sidebar-docked');
                    }
                    var hasContent = $sidebar.find('> div:visible:not(".sidebar-content,.sidebar-toggle")').length > 0 || list.length > 0;
                    if (hasContent && $container.hasClass('sidebar-hidden')){
                        $container.removeClass('sidebar-hidden');
                        $(window).trigger('resize');
                    } else if(!hasContent && !$container.hasClass('sidebar-hidden')) {
                        $container.addClass('sidebar-hidden');
                        $(window).trigger('resize');
                    }
                    $(document).off('click.sidebar').on('click.sidebar', '.sidebar-toggle, .sidebar-docked > #sidebar', function(e){
                        e.stopPropagation();
                        $container.toggleClass('sidebar-docked');
                        localStorage['sidebar'] = $container.hasClass('sidebar-docked');
                        $(window).trigger('resize');
                    });
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
            $('.widget-window', obj).parent().off('click').on('click', function(event) {
                document.location.hash = id;
            });
            obj.addClass('draggable-to-main');
        }

        if (opts.closeable) {
            $('.widget-close', obj).off('click').on('click', function(event) {
                $.icescrum.closeWidget(obj, event)
            });
        }

        if (opts.resizableOptions) {
            var content = $('.panel-body', obj);
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
            opts.resizableOptions.handles = 's';
            opts.resizableOptions.start = function(event, ui){
                var totalHeight = $(content.children()[0]).height() + dif;
                obj.resizable('option','maxHeight', totalHeight >= opts.resizableOptions.minHeight ? totalHeight : opts.resizableOptions.minHeight);
            };
            opts.resizableOptions.resize = function(event, ui){
                content.css('max-height','none');
                //soustract 3 px to get something look good (WTF? should be out of box)
                content.height(ui.size.height - dif -3);
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
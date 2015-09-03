(function($) {
    $.extend($.icescrum, {

                closeWindow:function(obj, event, disableAnim) {
                    var opts = obj.data('opts');
                    $.icescrum.o.currentOpenedWindow = null;
                    var closeClosure = function() {
                        obj.trigger('beforeIsCloseWindow');
                        obj.remove();
                    };
                    if (!disableAnim) {
                        var speed = 'fast';
                        obj.fadeOut(speed, function() {
                            closeClosure();
                        });
                    } else {
                        closeClosure();
                    }
                    if (opts.onClose)
                        opts.onClose();
                    if (event)
                        this.stopEvent(event);
                    location.hash = '';
                    $.post($.icescrum.o.push.url, {window:''});
                    this.o.fullscreen = false;
                },

                setDefaultView:function(xhr, element, view){
                    view = view ? view : $(element).data("defaultView");
                    $.cookie('view-'+ ($.icescrum.product.id ? $.icescrum.product.id : '-no-product'), view);
                    if (element){
                        $('#menu-display-list').find('.content').html('<span class="ico"></span>'+ $(element).text());
                    }
                },

                getDefaultView:function(){
                    var view = $.cookie('view-'+ ($.icescrum.product.id ? $.icescrum.product.id : '-no-product'));
                    return view ? view : 'postitsView';
                },

                openWindow:function(id, callback, async) {
                    var targetWindow = id;
                    if(targetWindow.indexOf('/') >= 0) {
                        targetWindow = targetWindow.substring(0, targetWindow.indexOf('/'))
                    }
                    if(targetWindow.indexOf('?') >= 0) {
                        targetWindow = targetWindow.substring(0, targetWindow.indexOf('?'))
                    }
                    if ($.inArray(targetWindow, $.icescrum.getWidgetsList()) != -1) {
                        var obj = $("#widget-id-" + targetWindow);
                        this.closeWidget(obj);
                    }

                    if (this.o.currentOpenedWindow != null && this.o.currentOpenedWindow.data('id') != targetWindow) {
                        $(document).unbind('keydown.' + this.o.currentOpenedWindow.data('id'));
                        if (this.o.currentOpenedWindow.data('opts').widgetable) {
                            this.addToWidgetBar(this.o.currentOpenedWindow.data('id'));
                        }
                    }
                    var view = this.getDefaultView();
                    return $.ajax({
                                type:'GET',
                                async: async,
                                url:this.o.urlOpenWindow + '/' + id + (view != 'postitsView' ? (id.indexOf('?') >= 0 ? '&' : '?') + 'viewType='+view : '' ),
                                beforeSend:function(){
                                    if ($('#window-loading').size() == 0){
                                        var loading = $('<div/>').attr('id','window-loading').css('opacity',0).css('z-index',998);
                                        if ($.icescrum.o.fullscreen) {
                                            $(document.body).prepend(loading);
                                            loading.addClass('window-fullscreen loading').animate({opacity:0.2},250);
                                        }else{
                                            $('#main').prepend(loading);
                                            loading.addClass('modal-background loading').animate({opacity:0.2},250);
                                        }
                                    }
                                },
                                complete:function(){
                                    var loading = $('#window-loading');
                                    if(loading.size() > 0){
                                        loading.stop().animate({opacity:0.0},250,function(){  $(this).remove(); });
                                    }
                                    $('#tiptip_holder').hide();
                                },
                                success:function(data, textStatus) {
                                    var content = '#window-id-' + targetWindow;
                                    if ($.icescrum.o.fullscreen) {
                                        $.icescrum.o.currentOpenedWindow.remove();
                                        $(document.body).prepend(data);
                                        $(content).addClass('window-fullscreen');
                                    } else {
                                        $($.icescrum.o.windowContainer).html('').html(data);
                                        var viewSelector = $('#menu-display-list');
                                        if (viewSelector.length != -1){
                                            viewSelector.find('.content').html('<span class="ico"></span>' + viewSelector.find('a[data-default-view='+view+']').text());
                                        }
                                    }

                                    attachOnDomUpdate($(content));

                                    if (callback) {
                                        callback();
                                    }
                                    var url = location.hash.replace(/^.*#/, '');
                                    if (url != id) {
                                        $.icescrum.o.openWindow = true;
                                        location.hash = id;
                                    }
                                    var $dialog  = $('#dialog');
                                    if($dialog.length){
                                        $dialog.dialog('close');
                                    }
                                    if (!$("#dropmenu").is(':visible')) {
                                        $("input:visible:not(.select2-focusser), textarea:visible", content).first().focus()
                                    }
                                    $.icescrum.checkToolbar();
                                    $.post($.icescrum.o.push.url, {window:id});
                                    return false;
                                }
                            });
                },

                maximizeWindow:function(obj, event) {
                    var opts = obj.data('opts');
                    if (!this.o.fullscreen) {
                        $(document.body).prepend(obj);
                        this.o.fullscreen = true;
                        $(document.body).fullScreen(true);

                    } else {
                        $('#main-content').prepend(obj);
                        this.o.fullscreen = false;
                    }
                    obj.toggleClass('window-fullscreen');
                    obj.resize();

                    if (this.o.fullscreen) {
                        obj.trigger('afterIsWindowMaximize');
                        if (opts.afterMaximize)
                            opts.afterMaximize();
                    } else {
                        obj.trigger('afterIsWindowUnMaximize');
                        if (opts.onUnMaximize)
                            opts.onUnMaximize();
                    }
                    if (event)
                        this.stopEvent(event);
                    $(window).trigger('resize');
                },

                windowToWidget:function(obj, event) {
                    var opts = obj.data('opts');
                    $.icescrum.closeWindow(obj);
                    $.icescrum.addToWidgetBar(obj.data('id'));
                    this.stopEvent(event);
                }
            });

    $.fn.isWindow = function(options) {
        var opts = $.extend({}, $.fn.isWindow.defaults, options);
        var obj = $(this);
        var windowid = $(this).attr('id'), id = windowid.substring(windowid.lastIndexOf("-") + 1, windowid.length);
        var iconMaximize;

        obj.data('opts', opts);
        obj.data('windowid', windowid);
        obj.data('id', id);

        if (opts.maximizeable) {
            iconMaximize = $("#" + windowid + ' .window-maxicon');
            //icon action
            iconMaximize.parent().bind('click', function(event) {
                $.icescrum.maximizeWindow(obj, event)
            });
            //barre action
            iconMaximize.parents('.resizable:first').bind('dblclick', function(event) {
                if (!$(event.target).is('a,span')) {
                    $.icescrum.maximizeWindow(obj, event)
                }
            });
        }

        if (opts.widgetable) {
            $("#" + windowid + ' .window-minimize').bind('click', function(event) {
                $.icescrum.windowToWidget(obj, event)
            });
        }

        if (opts.closeable) {
            $("#" + windowid + ' .window-close').bind('click', function(event) {
                $.icescrum.closeWindow(obj, event)
            });
        }

        $.icescrum.o.currentOpenedWindow = obj;
    };

    $(document).bind("fullscreenchange", function() {
        if ($(document).fullScreen()){
            console.log("Fullscreen on");
        }else{
            $.icescrum.maximizeWindow($('.box-window'));
            console.log("Fullscreen off");
        }
    });

})(jQuery);

$.fn.isWindow.defaults = {
    maximizeable:false,
    widgetable:false,
    closeable:true,
    onMaximize:null,
    onUnMaximize:null,
    onClose:null
};
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
                            this.openWidget(this.o.currentOpenedWindow.data('id'));
                        }
                    }

                    if (this.o.currentOpenedWindow != null && this.o.currentOpenedWindow.data('id') == targetWindow) {
                        var subHash = id.split('/');
                        subHash = subHash.length == 2 ? subHash[1] : null;
                        this.o.currentOpenedWindow.trigger('subhashchange', [subHash]);
                        return;
                    }

                    $.ajax({
                                type:'GET',
                                async: async,
                                url:this.o.urlOpenWindow + '/' + id,
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
                                    $('#tiptip_holder').remove();
                                },
                                success:function(data, textStatus) {
                                    var content = '#window-id-' + targetWindow;
                                    if ($.icescrum.o.fullscreen) {
                                        $.icescrum.o.currentOpenedWindow.remove();
                                        $(document.body).prepend(data);
                                        $(content).addClass('window-fullscreen');
                                    } else {
                                        $($.icescrum.o.windowContainer).html('').html(data);
                                    }
                                    $(content).isWindow($(content).data('is'));
//                                    attachOnDomUpdate($(content));

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

                                    $('#mainmenu').find('.menubar.active').removeClass('active');
                                    $('#elem_'+targetWindow).addClass('active');
                                    $(document.body).removeClass('left-open');
                                    $.post($.icescrum.o.push.url, {window:id});
                                    return false;
                                }
                            });
                },

                windowToWidget:function(obj, event) {
                    var opts = obj.data('opts');
                    $.icescrum.closeWindow(obj);
                    $.icescrum.openWidget(obj.data('id'));
                    this.stopEvent(event);
                }
            });

    $.fn.isWindow = function(options) {
        var obj = $(this);
        var opts = $.extend({}, $.fn.isWindow.defaults, options);
        var windowid = obj.attr('id'), id = windowid.substring(windowid.lastIndexOf("-") + 1, windowid.length);
        var iconMaximize;

        obj.data('opts', opts);
        obj.data('windowid', windowid);
        obj.data('id', id);

        if (opts.fullScreen) {
            obj.find('.btn-fullscreen').bind('click', function(event) {
                if($(document).fullScreen() != null){
                    obj.fullScreen(!$(document).fullScreen());
                }
            });
            $(document).off("fullscreenchange."+windowid).on("fullscreenchange."+windowid, function() {
                if (obj.fullScreen()){
                    obj.addClass('window-fullscreen well');
                    _.each(obj.find('.btn-fullscreen span'), function(btn){
                        $(btn).toggleClass('glyphicon-resize-small').toggleClass('glyphicon-fullscreen');
                    });
                    obj.trigger('afterIsWindowMaximize');
                    if (opts.afterMaximize)
                        opts.afterMaximize();
                }else{
                    obj.removeClass('window-fullscreen well');
                    _.each(obj.find('.btn-fullscreen span'), function(btn){
                        $(btn).toggleClass('glyphicon-resize-small').toggleClass('glyphicon-fullscreen');
                    });
                    obj.trigger('afterIsWindowUnMaximize');
                    if (opts.onUnMaximize)
                        opts.onUnMaximize();
                }
                $(window).trigger('resize');
            });
        }

        if (opts.widgetable) {
            obj.find('.btn-widget').bind('click', function(event) {
                $.icescrum.windowToWidget(obj, event);
            });
        }

        document.title = options.title;
        $.icescrum.o.currentOpenedWindow = obj;
    };
})(jQuery);

$.fn.isWindow.defaults = {
    maximizeable:false,
    widgetable:false,
    onMaximize:null,
    onUnMaximize:null,
    onClose:null
};
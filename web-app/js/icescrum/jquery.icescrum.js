/*
 * Copyright (c) 2010 iceScrum Technologies.
 *
 * This file is part of iceScrum.
 *
 * iceScrum is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License.
 *
 * iceScrum is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with iceScrum.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *
 * Vincent Barrier (vbarrier@kagilum.com)
 * Stéphane Maldini (stephane.maldini@icescrum.com)
 * Manuarii Stein (manuarii.stein@icescrum.com)
 *
 */

var stack_bottomleft = {"dir1": "up", "dir2": "right"};
var autoCompleteCache = {}, autoCompleteLastXhr;

(function($) {
    $.icescrum = {

        defaults:{
            debug:false,
            baseUrlSpace:null,
            baseUrl:null,
            versionUrl:null,
            grailsServer:null,
            urlOpenWidget:null,
            urlOpenWindow:null,
            widgetContainer:"#widget-list",
            windowContainer:"#main-content",
            deleting:false,
            fullscreen:false,
            deleteConfirmMessage:'Are you sure?',
            cancelFormConfirmMessage:'Do you want to quit this form?',
            more:'more',
            uploading:'',
            dialogErrorContent:null,
            openWindow:false,
            locale:'en',
            showUpgrade:true,
            push:{enable:true,websocket:false,url:null},
            selectedObject:{obj:'',time:'',callback:''}
        },
        o:{},

        init:function(options) {
            if (typeof icescrum === undefined) {
                icescrum = options;
            }
            this.o = jQuery.extend({}, this.defaults, icescrum);

            $.ajaxSetup({ timeout:45000 });
            $(document).ajaxSend(function(event, xhr, settings){
                xhr.setRequestHeader("If-Modified-Since",new Date(1970,1,1).toUTCString());
                xhr.setRequestHeader("Pragma","no-cache");
                if ($.icescrum.o.push && $.icescrum.o.push.uuid && settings.url.indexOf('X-Atmosphere-tracking-id') == -1){
                    xhr.setRequestHeader("X-Atmosphere-tracking-id", $.icescrum.o.push.uuid);
                }
            });

            $.fn.editable.defaults.placeholder = "&nbsp;";
            $.cookie.defaults = { path: '/' };

            if (!window.console) window.console = {};
            if (!window.console.log) window.console.log = function () { };

            $.datepicker.setDefaults($.datepicker.regional[this.o.locale]);
            if (!$.getUrlVar('ref')){
                var url = location.hash.replace(/^.*#/, '');
                if (url != '') {
                    $.icescrum.openWindow(url);
                }
            }

            $.icescrum.initHistory();

            var currentWindow = location.hash.replace(/^.*#/, '');
            var $menubar = $('li.menubar:first a');
            if ($.icescrum.o.baseUrlSpace && !currentWindow && $menubar.length > 0){
                var menubar = $menubar.attr('href').replace(/^.*#/, '');
                document.location.hash = menubar;
                $.icescrum.removeFromWidgetsList(menubar);
            }

            if ($.icescrum.getWidgetsList().length > 0) {
                var tmp = $.icescrum.getWidgetsList();
                $.icescrum.saveWidgetsList([]);
                for (i = 0; i < tmp.length; i++) {
                    this.addToWidgetBar(tmp[i]);
                }
            }

            $.event.trigger('init.icescrum');

            if (this.o.push.enable){
                $.icescrum.listenServer();
            }

            if (window.webkitNotifications) {
                console.log("[notifications] are supported!");
                if (!window.webkitNotifications.checkPermission()) {
                    console.log("[notifications] got permission");
                    this.o.notifications = true;
                }
                else if(window.webkitNotifications.checkPermission() != 2 && $.cookie('hide_notifications') != "true"){
                    $("#notifications").show();
                    $("#accept_notifications").click(function(){
                        window.webkitNotifications.requestPermission(function(){
                            if (window.webkitNotifications.checkPermission() == 0){
                                console.log("[notifications] got permission");
                                $.icescrum.o.notifications = true;
                            }
                            $.cookie('hide_notifications', true, { expires: 15 });
                            $("#notifications").remove();
                        });
                    });
                    $("#hide_notifications").click(function(){
                        $.cookie('hide_notifications', true, { expires: 15 });
                        $("#notifications").remove();
                    });
                }else{
                    console.log("[notifications] permission refused");
                    $("#notifications").remove();
                }
            }else{
                $("#accept_notifications").remove();
                console.log("Notifications are not supported for this Browser/OS version yet.");
                this.o.notifications = false;
            }

            $(window).bind('resize',function(){
                $.icescrum.checkBars();
            });

            //post every 25 min to cancel session timeout
            $.doTimeout(1000 * 60 * 25,function(){
                $.get($.icescrum.o.versionUrl);
                return true;
            });

            $.icescrum.showUpgrade();
            $.icescrum.guidedTour();
            $.icescrum.whatsNew();
        },

        log:function() {
            if (window.console) {
                console.log.apply(console, arguments);
            }
        },

        renderNotice:function(text, type, title) {
            var timeout = 7000;
            var titleP = "";
            if (title) {
                titleP = title;
            }
            var typeP = "notice";
            if (typeP) {
                typeP = type;
            }
            if (this.o.notifications){
                var notification = this.displayNotification(title ? title : 'iceScrum '+ (type ?' - '+type : ''), text, type);
                if(notification) {
                    $.doTimeout(timeout,function(){
                        notification.close();
                    });
                }
            }else{
                $.pnotify({
                    pnotify_addclass:'stack-bottomleft',
                    pnotify_animation:{effect_in: 'slide', effect_out: 'fade'},
                    pnotify_delay:timeout,
                    pnotify_history:false,
                    pnotify_stack:stack_bottomleft,
                    pnotify_text:text,
                    pnotify_type:typeP,
                    pnotify_title:titleP
                });
            }
        },

        displayNotification:function(title, msg, type){
            var image = $.icescrum.o.baseUrl + "themes/is/images/";
            image += type == "error" ?  "logo-disconnected.png" : "logo-connected.png";
            if (this.o.notifications){
                var notification = window.webkitNotifications.createNotification(image, title, $('<div/>').html(msg.replace(/<\/?[^>]+>/gi, '')).text());
                notification.show();
            }
        },

        displayView:function() {
            $('#menu-display-list').find('.content').html('<span class="ico"></span>');
        },

        selectableAction:function(action, doNotConfirm, idParam, onSuccess) {
            var elements = jQuery('.ui-selected, .table-row-focus');
            if (elements.length && !this.o.deleting) {
                this.o.deleting = true;
                if (!doNotConfirm && !confirm(this.o.deleteConfirmMessage)) {
                    this.o.deleting = false;
                    return false;
                }
                var dataToSend = $.icescrum.postit.ids(elements, idParam);
                if (!action || (action && action.indexOf('/') == -1)) {
                    action = $.icescrum.o.currentOpenedWindow.data('id') + '/' + (action ? action : 'delete');
                }

                jQuery.ajax({type:'POST', data:dataToSend,
                            url: $.icescrum.o.baseUrlSpace + action,
                            success:function(data) {
                                $.icescrum.o.deleting = false;
                                if (data.dialog){
                                    $(document.body).append(data.dialog);
                                    attachOnDomUpdate($('.ui-dialog'));
                                    return;
                                }
                                if (onSuccess) {
                                    onSuccess(data);
                                }
                            },
                            error:function() {
                                elements.css('background-color', '');
                                $.icescrum.o.deleting = false;
                            }
                        });
                return false;
            }
            return true;
        },

        //really used
        changeRank:function(container, source, ui, name, call) {
            var postitid = ui.attr('id');
            if (!postitid){
                 return;
            }
            var idmoved = postitid.substring(postitid.lastIndexOf("-") + 1, postitid.length);
            var newPosition = $(container).index(ui) + 1;
            //finally we send the update to server
            var params = {id:idmoved};
            params[name] = newPosition;
            call(params, source);
        },

        dblclickSelectable:function(obj, delay, callback, force) {
            if (force != undefined && force) {
                if ($.icescrum.o.selectedObject.obj != "" && $('#' + $.icescrum.o.selectedObject.obj.selected.id).hasClass('ui-selected')) {
                    if ($.icescrum.o.selectedObject.callback) {
                        callback($.icescrum.o.selectedObject.obj);
                    }
                }
                return false;
            }
            if ($.icescrum.o.selectedObject.obj == "" || (obj.selected.id != $.icescrum.o.selectedObject.obj.selected.id)) {
                $.icescrum.o.selectedObject.obj = obj;
                $.icescrum.o.selectedObject.time = new Date().getTime();
                $.icescrum.o.selectedObject.callback = callback;
            }
            else {
                var c = new Date().getTime();
                var d = c - $.icescrum.o.selectedObject.time;
                if (d <= delay) {
                    if ($.icescrum.o.selectedObject.callback) {
                        $.icescrum.o.selectedObject.callback(obj);
                    }
                    $.icescrum.o.selectedObject = {obj:'',time:'',callback:''};
                }
                else {
                    $.icescrum.o.selectedObject = {obj:'',time:'',callback:''};
                    $.icescrum.dblclickSelectable(obj, delay, callback);
                }
            }
            return false;
        },

        openCommentTab:function(relation) {
            $('#commentEditorContainer').show();
            $.icescrum.openTab(relation, true);
        },

        openTab:function(relation, scrollBottom) {
            $('.panel-box a[rel=' + relation + ']').click();
            if (scrollBottom) {
                var contentWindow = jQuery('div .window-content');
                contentWindow.scrollTop(contentWindow.outerHeight());
            }
        },

        displayChart:function(container, url, save) {
            jQuery.ajax({
                        type:'GET',
                        global:false,
                        cache:true,
                        url:$.icescrum.o.baseUrlSpace + url,
                        data:'withButtonBar=false',
                        beforeSend:function() {
                            $(container).addClass('loading').html('');
                        },
                        success:function(data) {
                            $(container).height(300);
                            $(container)
                                    .removeClass('loading')
                                    .html(data);
                            $('.save-chart', $(container)).remove();
                            if (typeof save != 'undefined' && save) {
                                $.cookie(container + $.icescrum.product.id, url);
                            }
                            var test = /\/(.*)/;
                            var match = test.exec(url);
                            if (match[1]) {
                                if (match[1].indexOf('/') == match[1].length - 1){
                                    match[1] = match[1].substr(0, match[1].length - 1)
                                }
                                $('#panel-chart').find('.right').removeClass('selected');
                                $('#chart-' + match[1]).addClass('selected');
                            }
                        },
                        error:function(XMLHttpRequest) {
                            var data = $.parseJSON(XMLHttpRequest.responseText);
                            $(container).css("height", null);
                            $(container)
                                    .removeClass('loading')
                                    .addClass('error-loading')
                                    .html(data.notice.text);
                        }
                    });
        },

        //really used
        displayChartFromCookie:function(container, url, save) {
            var saveChartType = $.cookie(container + $.icescrum.product.id);
            if (saveChartType) {
                this.displayChart(container, saveChartType, false);
            } else {
                this.displayChart(container, url, save);
            }
        },

        listenServer:function() {
            var socket = $.atmosphere;
            var request = { url : $.icescrum.o.push.url,
                            contentType : "application/json",
                            data:{window : ($.icescrum.o.currentOpenedWindow ? $.icescrum.o.currentOpenedWindow.data('id') : null)},
                            transport : $.icescrum.o.push.websocket && (window.MozWebSocket || window.WebSocket) ? 'websocket' : 'streaming',
                            enableXDR : true,
                            enableProtocol : true,
                            closeTimeout: 5 * 1000,
                            trackMessageLength : true,
                            fallbackTransport : 'long-polling'
            };

            request.onOpen = function(response) {
                if(response.request){
                    $.icescrum.o.push.uuid = response.request.uuid;
                    var window = location.hash.replace(/^.*#/, '');
                    if (window){
                        $.post($.icescrum.o.push.url, {window:window});
                    }
                    $("#is-logo").removeClass().addClass('connected');
                }
            };


            request.onMessage = function (response) {
                var message = response.responseBody;
                  try {
                      var json = JSON.parse(message);
                      $(json).each(function() {
                          if (this.call && this.object) {
                              if (this.object['class']) {
                                  var type = this.object['class'].substring(this.object['class'].lastIndexOf('.') + 1).toLowerCase();
                                  this.call = (this.call == 'delete') ? 'remove' : this.call;
                                  $.event.trigger(this.call + '_' + type + '.stream', this.object);
                              } else{
                                  $.event.trigger(this.call + '.stream', this.object);
                              }
                          } else if(this.command) {
                              if(this.command == 'connected' && this.object.length > 1){
                                  var users = [];
                                  $(this.object).each(function(){
                                      users.push(this.fullName);
                                  });
                                  $('#menu-project').find('.content').attr('title',users.length+' users online ('+users.join(', ')+')');
                              }else if (this.command == 'connected'){
                                  $('#menu-project').find('.content').attr('title', 'Do you feel lonely?');
                              } else {
                                  $.icescrum.commands[this.command].apply(null,[this.data, this.from]);
                              }
                          }
                      });
                  } catch (e) {
                      console.log('Error: ', message.data);
                  }
            };

            request.onError = function() {
                $("#is-logo").removeClass().addClass('disconnected');
            };

            request.onClose = function() {
                $("#is-logo").removeClass().addClass('disconnected');
            };

            $(window).on("beforeunload", function() {
                $(window).trigger("unload.atmosphere");
            });

            socket.subscribe(request);
        },

        //really used
        formattedTaskEstimation:function(estimation, defaultChar) {
            if(estimation == null && defaultChar)
                return '?';
            else if(estimation == null)
                return null;
            else
                return estimation.toString().indexOf('.') == -1 ? estimation.toString().concat('.0') : estimation;
        },

        redirectOnLogin:function(data){
            var refVar = "?ref=";
            var ref = '';
            if (window.location.href.indexOf(refVar) > 0){
                ref = window.location.href.slice(window.location.href.indexOf(refVar) + refVar.length);
            }
            var hash = ref ? ref : data ? data.url : '';
            if(hash.indexOf('#') == 0){
                var url = document.location.toString();
                document.location = url.substring(0,url.indexOf('login')) + hash;
            }else {
                document.location = hash;
            }
        },

        showAndHideOnClickAnywhere:function(selector){
            var element = $(selector);
            if(element.css('display') == 'none') {
                element.show();
                var handler = function(){
                    element.hide();
                    $(document).off("click", handler);
                };
                setTimeout(function () {
                    $(document).on("click", handler)
                ;}, 10);
            }
        },

        showUpgrade:function(){
            if (this.o.showUpgrade){
                var upgrade = $('#upgrade');
                if (upgrade.length && $.cookie('hide_upgrade') != "true"){
                    upgrade.show();
                    upgrade.find('.close').click(function(){
                        upgrade.remove();
                        $.cookie('hide_upgrade', true, { expires: 30 });
                    });
                }else if(upgrade.length){
                    upgrade.remove();
                }
            }
        },

        whatsNew:function(){
            if ($(document.body).data('whatsnew')){
                $.get($.icescrum.o.baseUrl+"whatsNew", function(data){
                    if (data.dialog){
                        $(document.body).append(data.dialog);
                    }
                });
            }
        },

        openWizard: function(){
            return $.get($.icescrum.o.baseUrl+"project/openWizard", function(data){
                if (data.dialog){
                    $(document.body).append(data.dialog);
                    attachOnDomUpdate($('.ui-dialog'));
                }
            });
        },

        guidedTour: function (tourName, autoStart) {
            //start a named tour
            if(tourName){
                $('#script-tour-' + tourName).remove();
                $(document.body).append('<script type="text/javascript" id="script-tour-' + tourName + '" src="' + $.icescrum.o.baseUrl + 'guidedTour?tourName=' + tourName + '&autoStart=' + (autoStart ? true : false) + '"/>');
            } else {
                var defaultTours = $(document.body).data('guided-tour');
                if(defaultTours.welcomeTour && !$.icescrum.product.id){
                    this.guidedTour('welcome', true);
                } else if(defaultTours.fullProjectTour && $.icescrum.product.id){
                    this.guidedTour('fullProject', true);
                }
            }
        }
    };

    $.icescrum.commands = {
        send:function(command,to,data,callback){
            $.ajax({
                type:"POST",
                url:$.icescrum.o.push.url,
                data:{command:command,to:to,data:data},
                success:callback,
                headers:{"X-Atmosphere-tracking-id":$.icescrum.o.push.uuid},
                global:false
            });
        }
    }

})(jQuery);

$.fn.icescrum = function(options) {
    if ((typeof options) == "string") {
        //TODO : refactor icescrum('toolbar')
        if (options == 'toolbar')
            return $.icescrum[options](this, arguments);
        else
            return $.icescrum[options].apply(this, arguments);
    }
    return $.icescrum;
};

$.escapeSelector = function(unescapedSelector) {
    var isNumber = !isNaN(parseInt(unescapedSelector));
    if (isNumber) {
        return unescapedSelector;
    } else {
        return unescapedSelector.replace(/(!|\"|#|\$|\%|&|'|\(|\)|\*|\+|\,|\.|\/|:|;|<|=|>|\?|@|\[|\\|\]|\^|`|\{|\||\}|\~)/g, "\\$1");
    }
};

$.ui.dialog.prototype._allowInteraction = function(e) {
    return !!$(e.target).closest('.ui-dialog, .ui-datepicker, .select2-drop').length;
};
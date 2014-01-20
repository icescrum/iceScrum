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
            push:{enable:true,websocket:false,url:null}
        },
        o:{},

        init:function(options) {
            if (typeof icescrum === undefined) {
                icescrum = options;
            }
            this.o = jQuery.extend({}, this.defaults, icescrum);

            $.icescrum.initAjaxSetup();

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
            $.icescrum.initAtmosphere();
            $.icescrum.initNotifications();
            $.icescrum.showUpgrade();
            $.icescrum.whatsNew();

            $(window).bind('resize',function(){
                $.icescrum.checkBars();
            });

            //post every 25 min to cancel session timeout
            $.doTimeout(1000 * 60 * 25,function(){
                $.get($.icescrum.o.versionUrl);
                return true;
            });

            $.event.trigger('init.icescrum');
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
                                localStorage[container + $.icescrum.product.id] = url;
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
            var saveChartType = localStorage[container + $.icescrum.product.id];
            if (saveChartType) {
                this.displayChart(container, saveChartType, false);
            } else {
                this.displayChart(container, url, save);
            }
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

$.ui.dialog.prototype._allowInteraction = function(e) {
    return !!$(e.target).closest('.ui-dialog, .ui-datepicker, .select2-drop').length;
};
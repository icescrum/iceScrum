/*
 * Copyright (c) 2014 Kagilum SAS
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
 * Nicolas Noullet (nnoullet@kagilum.com)
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
            widgetContainer:"#sidebar .sidebar-content",
            windowContainer:"#main-content",
            deleting:false,
            fullscreen:false,
            deleteConfirmMessage:'Are you sure?',
            cancelFormConfirmMessage:'Do you want to quit this form?',
            more:'more',
            uploading:'',
            openWindow:false,
            locale:'en',
            isPro:false,
            push:{enable:true,websocket:false,url:null},
            showAsGrid:true
        },
        o:{},

        init:function(options) {
            if (typeof icescrum === undefined) {
                icescrum = options;
            }
            this.o = jQuery.extend({}, this.defaults, icescrum);

            if (!window.console) window.console = {};
            if (!window.console.log) window.console.log = function () { };

            //$.datepicker.setDefaults($.datepicker.regional[this.o.locale]);
            if ($.timeago.locales[this.o.locale]) {
                $.timeago.settings.strings = $.timeago.locales[this.o.locale];
            } if ($.fn.select2.locales[this.o.locale]) {
                $.extend($.fn.select2.defaults, $.fn.select2.locales[this.o.locale]);
            }

            $.icescrum.initLocalStorage();

            $.icescrum.initAjaxSetup();

            $.icescrum.initUpgrade();

            $.icescrum.checkSidebar();

            $.icescrum.whatsNew();

            //$.icescrum.initAtmosphere(); TODO rewire atmosphere

            //post every 25 min to cancel session timeout
            /*$.doTimeout(1000 * 60 * 25,function(){
                $.get($.icescrum.o.versionUrl);
                return true;
            });*/

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
//                                    attachOnDomUpdate($('.ui-dialog'));
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


        //really used
        formattedTaskEstimation:function(estimation, defaultChar) {
            if(estimation == null && defaultChar)
                return '?';
            else if(estimation == null)
                return null;
            else
                return estimation.toString().indexOf('.') == -1 ? estimation.toString().concat('.0') : estimation;
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
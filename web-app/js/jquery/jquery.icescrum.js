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
 * Vincent Barrier (vincent.barrier@icescrum.com)
 * Stéphane Maldini (stephane.maldini@icescrum.com)
 * Manuarii Stein (manuarii.stein@icescrum.com)
 *
 */

var stack_bottomleft = {"dir1": "up", "dir2": "right"};

if (typeof console != "object") {
	var console = {
		'log':function(){}
	};
}

$(document).ready(function($) {

    // Ajax Cache Init
    $.ajaxSetup({
        timeout:45000
    });

});


(function($) {

    $.icescrum = {

        defaults:{
            debug:false,
            baseUrlProduct:null,
            baseUrl:null,
            grailsServer:null,
            urlOpenWidget:null,
            urlCloseWindow:null,
            urlOpenWindow:null,
            urlCloseWidget:null,
            widgetContainer:"#widget-list",
            windowContainer:"#main-content",
            deleting:false,
            fullscreen:false,
            deleteConfirmMessage:'Are you sure?',
            cancelFormConfirmMessage:'Do you want to quit this form?',
            acceptedState:'Accepted',
            estimatedState:'Estimated',
            widgetsList:[],
            maskSpinner:false,
            dialogErrorContent:null,
            openWindow:false,
            locale:'en',
            selectedObject:{obj:'',time:'',callback:''}
        },
        o:{},

        init:function(options) {
            if (typeof icescrum === undefined) { icescrum = options; }
            this.o = jQuery.extend({}, this.defaults, icescrum);
            var old_console_log = console.log;
            console.log = function() {
                if ( $.icescrum.o.debug ) {
                    old_console_log.apply(this, arguments);
                }
            };

            if (this.o.widgetsList.length > 0) {
                var tmp = this.o.widgetsList;
                this.o.widgetsList = [];
                for (i = 0; i < tmp.length; i++) {
                    this.addToWidgetBar(tmp[i]);
                }
            }

            $.datepicker.setDefaults($.datepicker.regional[this.o.locale]);
            var url = location.hash.replace(/^.*#/, '');

            if(url != ''){
                $.icescrum.openWindow(url);
            }
            $.icescrum.initHistory();
        },

        debug:function(value){
            if (value){
                this.o.debug = value;
            }else{
                return this.o.debug;
            }
        },

        addHistory:function(hash){
            var url = location.hash.replace(/^.*#/, '');
            if (url != hash){
                $.icescrum.o.openWindow = true;
                location.hash = hash;
            }
        },

        initHistory:function() {
            $(window).hashchange( function(){
                if ($.icescrum.o.openWindow){
                    $.icescrum.o.openWindow = false;
                }else{
                    var url = location.hash.replace(/^.*#/, '');
                    if(url != ''){
                        $.icescrum.openWindow(url);
                    }else{
                        if ($.icescrum.o.currentOpenedWindow){
                            $.icescrum.closeWindow($.icescrum.o.currentOpenedWindow);
                        }
                    }
                }
            });
        },

        checkMenuBar:function(last){
            if (last == null){
                last = "#profile-name"
            }

            var lastMenuItem = $('.navigation-content .menubar:visible:last');

            var menuDropList = $('#menubar-list-button');
            var posMenuDropList = null;
            if (menuDropList.size() > 0){
                posMenuDropList = menuDropList.offset().left + menuDropList.width();
            }

            var lastPos = null;
            if ($(last).offset() != null){
                lastPos = $(last).offset().left;
            }

            var contentMenuDrop = $('#menubar-list-content > ul');
            if(lastPos && posMenuDropList && posMenuDropList > lastPos){
                if (lastMenuItem.size() != 0){
                    menuDropList.css('visibility','visible');
                    lastMenuItem.removeClass('draggable-to-desktop');
                    lastMenuItem.appendTo(contentMenuDrop);
                    $.icescrum.checkMenuBar(last);
                    return;
                }
            }

            var widthLastHidden = null;
            var lastHidden = contentMenuDrop.find('.menubar[hidden!=true]:last');

            if (lastHidden.size() > 0){
                contentMenuDrop.parent().css('visibility','hidden').show();
                widthLastHidden = lastHidden.width();
                contentMenuDrop.parent().hide().css('visibility','visible');
            }else if(contentMenuDrop.find('.menubar').size() == 0){
                menuDropList.css('visibility','hidden');
            }

            if (lastPos && posMenuDropList && widthLastHidden && (posMenuDropList + widthLastHidden < lastPos)){
                lastHidden.addClass('draggable-to-desktop');
                menuDropList.before(lastHidden);
                $.icescrum.checkMenuBar(last);
                return;
            }
            return;
        },

        uploading:function(){
            return $('.field-file .is-progressbar .ui-progressbar-value:not(.ui-progressbar-value-error)').size() > 0;
        },

        renderNotice:function(text,type,title){
            var titleP = "";
            if (title){
                titleP = title;
            }
            var typeP = "notice";
            if (typeP){
                typeP = type;
            }
            $.pnotify({
                pnotify_addclass:'stack-bottomleft',
                pnotify_animation:{effect_in: 'slide', effect_out: 'fade'},
                pnotify_delay:7000,
                pnotify_history:false,
                pnotify_stack:stack_bottomleft,
                pnotify_text:text,
                pnotify_type:typeP,
                pnotify_title:titleP
            });
        },


        htmlEncode:function(value){
          return $('<div/>').text(value).html();
        },

        htmlDecode:function(value){
          return $('<div/>').html(value).text();
        },

        cancelForm:function(){
            if (!confirm(this.o.cancelFormConfirmMessage)) {
                return false;
            }else{
                $("#cancelForm").click();
                return false;
            }
        },

        displayTemplate:function(selector, show) {
            if (show) {
                $(selector + " .text-template").show();
                 $("#displayTemplate").val('1');
            } else {
                $(selector + " .text-template").hide();
                 $("#displayTemplate").val('0');
            }
        },

        displayView:function(view){
            $('#menu-display-list .content').html('<span class="ico"></span>'+view);
        },

        selectableAction:function(action, doNotConfirm, idParam, onSuccess) {
            var elements = jQuery('.ui-selected, .table-row-focus');
            if (elements.length && !this.o.deleting) {
                this.o.deleting = true;
                if (!doNotConfirm && !confirm(this.o.deleteConfirmMessage)) {
                    this.o.deleting = false;
                    return false;
                }
                var data = '';
                data = elements.icescrum('postit').requestIds(idParam);

                if (!action || (action && action.indexOf('/') == -1)){
                    action = $.icescrum.o.currentOpenedWindow.data('id') + '/' + (action ? action : 'delete');
                }

                jQuery.ajax({type:'POST', data:data,
                    url: $.icescrum.o.baseUrlProduct + action,
                    success:function(data, textStatus) {
                        $.icescrum.o.deleting = false;

                        if (!onSuccess){
                            jQuery('#window-content-' + $.icescrum.o.currentOpenedWindow.data('id')).html(data);
                        }else{
                            onSuccess(data);
                        }
                    },
                    error:function(XMLHttpRequest, textStatus, errorThrown) {
                        elements.css('background-color', '');
                        $.icescrum.o.deleting = false;
                    }
                });
                return false;
            }
            return true;
        },

        touchHandler:function(event) {
            var touches = event.changedTouches,first = touches[0],type = '';
            var types = {'touchstart': 'mousedown', 'touchmove': 'mousemove', 'touchend': 'mouseup'};
            if (typeof(types[event.type]) == 'undefined')
                return;
            type = types[event.type];
            if (event.type == 'touchstart') {
                _t = first;
            } else {
                if (event.type == 'touchend') {
                    if (_prev == 'touchstart') {
                        type = 'click';
                    }
                }
                if (type != 'click' && _prev == 'touchstart') {
                    var se = document.createEvent('MouseEvent');
                    se.initMouseEvent('mousedown', true, true, window, 1, _t.screenX, _t.screenY, _t.clientX, _t.clientY, false, false, false, false, 0, null);
                    _t.target.dispatchEvent(se);
                }
                if (event.type != 'touchstart') {
                    var se = document.createEvent('MouseEvent');
                    se.initMouseEvent(type, true, true, window, 1, first.screenX, first.screenY, first.clientX, first.clientY, false, false, false, false, 0, null);
                    first.target.dispatchEvent(se);
                }
            }
            _prev = event.type;
            event.preventDefault();
            return true;
        }

        ,

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
                    error:function(){
                        $.icescrum.o.widgetsList = $.grep($.icescrum.o.widgetsList, function(value) {
                            return value != id;
                        });
                    }
                });
            }
            return false;
        }
        ,

        closeWindow:function(obj, event, disableAnim) {
            var opts = obj.data('opts');
            $.icescrum.o.currentOpenedWindow = null;
            var closeClosure = function() {
                jQuery.ajax({
                    type:'GET',
                    url:$.icescrum.o.urlCloseWindow + '/' + obj.data('id')
                });
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
            this.o.fullscreen = false;
        }
        ,


        stopEvent:function(event) {
            event = jQuery.event.fix(event || window.event);
            event.stopPropagation();
            return this;
        }
        ,

        dialogError:function(error) {
            $('#window-dialog').dialog('destroy');
            $(document.body).append(this.o.dialogErrorContent);
            $('#comments').focus();
            $('#stackError').val(error);
            $('#stackError-field').input({className:'area'});
            $('#comments-field').input({className:'area'});
            $('#window-dialog').dialog({
                dialogClass: 'no-titlebar',
                closeOnEscape:true,
                closeText:'Close',
                draggable:false,
                modal:true,
                position:'top',
                resizable:false,
                stack:true,
                width:600,
                zindex:1000,
                close:function(ev, ui) {
                    $(this).remove();
                },
                buttons:{
                    'Cancel': function() {
                        $(this).dialog('close');
                    },
                    'OK': function(){
                        jQuery.ajax({
                            type:'POST',
                            data:jQuery('#window-dialog form:first').serialize(),
                            url:$.icescrum.o.baseUrl+'reportError',
                            success:function(data,textStatus){
                                $.icescrum.renderNotice(data.notice.text,data.notice.type);
                                $('#window-dialog').dialog('close');
                             },
                            error:function(){
                                $('#window-dialog').dialog('close');
                            }
                        });
                    }
                }
            });
        },

        openWindow:function(id,callback) {

            var targetWindow = id;
            var openPanel = false;
            var targetIndex = id.indexOf('/');
            if (targetIndex >= 0) {
                targetWindow = id.substring(0, targetIndex);
                openPanel = true;
            }
            var targetParam = targetWindow.indexOf('?');
            if (targetParam >= 0) {
                targetWindow = targetWindow.substring(0, targetParam);
            }

            if ($.inArray(targetWindow, this.o.widgetsList) != -1) {
                var obj = $("#widget-id-" + targetWindow);
                this.closeWidget(obj);
            }


            if (this.o.currentOpenedWindow != null && this.o.currentOpenedWindow.data('id') != targetWindow) {
                $(document).unbind('keydown.' + this.o.currentOpenedWindow.data('id'));
                if (this.o.currentOpenedWindow.data('opts').widgetable) {
                    this.addToWidgetBar(this.o.currentOpenedWindow.data('id'));
                }
            }

            jQuery.ajax({
                type:'GET',
                url:this.o.urlOpenWindow + '/' + id,
                success:function(data, textStatus) {
                    if ($.icescrum.o.fullscreen){
                        $.icescrum.o.currentOpenedWindow.remove();
                        $(document.body).prepend(data);
                        $('#window-id-'+targetWindow).addClass('window-fullscreen');
                    }else{
                       $($.icescrum.o.windowContainer).html("");
                       $($.icescrum.o.windowContainer).html(data);
                    }
                    if (callback) {
                        callback();
                    }
                    var url = location.hash.replace(/^.*#/, '');
                    if (url != id){
                        $.icescrum.o.openWindow = true;
                        location.hash = id;
                    }
                    return false;
                }
            });
        }
        ,

        setFixButtonBar:function(opt) {

            /*var bar = opt.bar;
             var mask = $('.mask-submit', bar);
             var parent = bar.parent();
             parent.append(mask);
             var container = $($.icescrum.o.windowContainer).find('.box-window');
             var containerHtml = $('<div></div>');
             bar.hide();
             containerHtml.addClass('form-button-bar-fixed').append(bar);
             container.addClass('box-buttons-bar').append(containerHtml);
             bar.show();*/
        },

        maximizeWindow:function(obj, event) {
            var opts = obj.data('opts');
            if (!this.o.fullscreen) {
                $(document.body).prepend(obj);
                this.o.fullscreen = true;
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
        }
        ,

        updateWizardDate:function(datepicker){
             var startDate = jQuery(datepicker).datepicker('getDate');
             var endDateProject = new Date(startDate.getTime() + 3*24*60*60*1000);
             var endDate = new Date(startDate.getTime() + 90*24*60*60*1000);
             var endDateFirstSprint = new Date(startDate.getTime() + 88*24*60*60*1000);
             jQuery('#datepicker-productendDate').datepicker('option', {minDate:endDateProject,defaultDate:endDate,maxDate:null});
             jQuery('#datepicker-productendDate').datepicker('setDate',endDate);
             jQuery('#datepicker-firstSprint').datepicker('option', {minDate:startDate,defaultDate:startDate,maxDate:endDateFirstSprint});
             jQuery('#datepicker-firstSprint').datepicker('setDate',startDate);
        },

        widgetToWindow:function(obj, event) {
            var opts = obj.data('opts');
            $.icescrum.openWindow(obj.data('id'));
            this.stopEvent(event);
        }
        ,

        windowToWidget:function(obj, event) {
            var opts = obj.data('opts');
            $.icescrum.closeWindow(obj);
            $.icescrum.addToWidgetBar(obj.data('id'));
            this.stopEvent(event);
        }
        ,

        dblclickSelectable:function(obj, delay, callback, force) {
            var id;
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
            if (opts.onClose)
                opts.onClose();

            if (event)
                this.stopEvent(event);
        }
        ,

        changeRank:function(container, source, ui, call) {
            var postitid = ui.attr('id');
            var idmoved = postitid.substring(postitid.lastIndexOf("-") + 1, postitid.length);
            var newPosition = $(container).index(ui);

            //finally we send the update to server
            var params = "idmoved=" + idmoved + "&position=" + (newPosition + 1);
            call(params, source);
        }
        ,

        openCommentTab:function(relation) {
            jQuery('#commentEditorContainer').show();
            jQuery.icescrum.openTab(relation, true);
        },

        openTab:function(relation, scrollBottom) {
            jQuery('.panel-box a[rel='+relation+']').click();
            if(scrollBottom) {
                var contentWindow = jQuery('div .window-content');
                contentWindow.scrollTop(contentWindow.outerHeight());
            }
        },

        displayChart:function(url,container){
            jQuery.ajax({
                type:'GET',
                global:false,
                url:$.icescrum.o.baseUrlProduct + url,
                data:'withButtonBar=false',
                beforeSend:function(){
                    $(container).addClass('loading-chart').html('');
                },
                success:function(data, textStatus) {
                    $(container)
                            .removeClass('loading-chart')
                            .html(data);
                },
                error:function(XMLHttpRequest, textStatus, errorThrown){
                    var data = $.parseJSON(XMLHttpRequest.responseText);
                    $(container)
                            .removeClass('loading-chart')
                            .addClass('error-loading-chart')
                            .html(data.notice.text);
                }
            });
        },

        isValidEmail:function(email) {
            var filter = /^([\w-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([\w-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$/;
            return filter.test(email);
        },

        toolbar:function(target, params) {
            var self = target;
            var elemMethods = {
                target:null,
                disable: function() {
                    if (!this.target) return;
                    $.each(this.target, function(index, element) {
                        if ($(element).attr('disablable') && $(element).attr('disablable') == 'true') {
                            var link = $(element).find('a');
                            var oldSrc = $(element).find('img').attr('src');
                            var extension = oldSrc.lastIndexOf('.');
                            if (extension != -1) {
                                var temp = oldSrc.substring(extension - 2, extension);
                                if (temp != '_d') {
                                    link.data('onclickEvent', link.attr('onclick'));
                                    link[0].onclick = function() {
                                        return false;
                                    };
                                    $(element).find('img').attr('src', oldSrc.substring(0, extension) + '_d' + oldSrc.substring(extension, oldSrc.length));
                                }
                            }
                        }
                    });
                },
                enable: function() {
                    if (!this.target) return;
                    $.each(this.target, function(index, element) {
                        if ($(element).attr('disablable') && $(element).attr('disablable') == 'true') {
                            var link = $(element).find('a');
                            var oldSrc = $(element).find('img').attr('src');
                            var extension = oldSrc.lastIndexOf('.');
                            if (extension != -1) {
                                var temp = oldSrc.substring(extension - 2, extension);
                                if (temp == '_d') {
                                    if (link.data('onclickEvent'))
                                        link[0].onclick = link.data('onclickEvent');
                                    $(element).find('img').attr('src', oldSrc.replace('_d.', '.'));
                                }
                            }
                        }
                    });
                },
                replace: function(options) {
                    if (options.icon)
                        this.target.find('img').attr('src', options.icon);
                    if (options.click != null) {
                        this.target.find('a')[0].onclick = options.click;
                    }
                },
                selectIcon: function() {
                    $('.tool-button').removeClass('select');
                    this.target.find('.tool-button').addClass('select');
                },
                unSelectIcon: function() {
                    $('.tool-button').removeClass('select');
                },
                hide:function() {
                    this.target.hide();
                },
                show:function() {
                    this.target.show();
                },
                toggleEnabled: function(selector) {
                    var obj = this.target;
                    var selectable = $(selector);

                    selectable.live("selectableselected", function(event, ui) {
                        obj.icescrum('toolbar').enable();
                    });
                    selectable.live("selectableunselected", function(event, ui) {
                        obj.icescrum('toolbar').disable();
                    });
                },
                reload: function(id, params) {
                    jQuery.ajax({type:'GET',
                        url: $.icescrum.o.baseUrlProduct + 'reloadToolbar/' + id,
                        data:params,
                        success:function(data, textStatus) {
                            jQuery(self).html(data);
                        },
                        error:function(XMLHttpRequest, textStatus, errorThrown) {
                            alert('Failed to reload toolbar');
                        }
                    });
                }
            };
            var methods = {
                elements:function(index) {
                    if (index == undefined)
                        elemMethods.target = $(target).children('div');
                    else if ((typeof index) == 'object')
                        if ($(index).attr('nodeName') == 'A') {
                            elemMethods.target = $(index).parent();
                        } else {
                            elemMethods.target = $(index);
                        }
                    else if ((typeof index) == 'string')
                        elemMethods.target = $(target).children('div' + index);
                    else
                        elemMethods.target = $(target).children('div:eq(' + (index) + ')');
                    return elemMethods;
                },
                buttons:function(index) {
                    if (index == undefined)
                        elemMethods.target = $(target).find('div.li');
                    else if ((typeof index) == 'object')
                        if ($(index).attr('nodeName') == 'A') {
                            elemMethods.target = $(index).parent();
                        } else {
                            elemMethods.target = $(index);
                        }
                    else if ((typeof index) == 'string')
                        elemMethods.target = $(target).children('div' + index);
                    else
                        elemMethods.target = $(target).find('div.li:eq(' + (index) + ')');
                    return elemMethods;
                }
            };
            if (!params[1]) {
                if ($(target).attr('nodeName') == 'A') {
                    elemMethods.target = $(target).parent();
                } else {
                    elemMethods.target = $(target);
                }
                return elemMethods;
            } else {
                return methods[params[1]](params[2]);
            }
        },

        createCompleteResult:function(item, idfieldname, term) {
            var res = '<div class="list-selectable-item ui-selectable" id="resultComplete-id-'+item.id+'">';
            res += '<img class="ico" src="'+item.image+'" />';
            res += '<p><strong>'+item.label+'</strong></p>';
            res += '<p>'+item.extra+'</p>';
            res += '<input class="id" type="hidden" name="_' + idfieldname + '" value="' + item.id + '"></input>';
            res += '</div>';
            return res;
        },

        createCompleteSelected:function(item, idfieldname,id) {
            var res = '<div class="field-choose-list-item clearfix">';
            res += '<span class=" button-s button-s-light clearfix"><span class="start"></span>';
            res += '<span class="content">'+item+'<span class="button-action button-delete" style="display: none;">del</span></span>';
            res += '<span class="end"></span></span>';
            res += '<input class="id" type="hidden" name="' + idfieldname + '" value="' + id + '"></input>';
            res += '</div>';
            return res;
             // elem list
        },

        chooseSelected:function(source, target, fieldname) {
            var result = $("#" + target);
            var id;
            var input;
            var label;
            $("#"+source+" .ui-selected").each(function() {
                input = $(this).find("input");
                label = $(this).find("strong").html();
                id = input.val();
                if (!$('#' + target + ' input.id[value=' + id + ']').length > 0) {
                    result.append($.icescrum.createCompleteSelected(label,fieldname,id));
                }
                $(this).removeClass('ui-selected');
            });
            $('.button-s .button-action').click(function() {
                    $(this).parent().parent().parent().remove();
            });
            $('.button-s').hover(function() {
                $(this).find('.button-action').show();
            }, function() {
                $(this).find('.button-action').hide();
            });


        },

        autoCompleteChoose:function(request, response, url, params) {
            var fieldname = params && params.idfieldname ? params.idfieldname : 'searchid';
            $.ajax({
                url: url,
                data: {
                    term: request.term
                },
                success: function(data) {
                    var out = '';
                    $.each(data, function(index, item) {
                        out += $.icescrum.createCompleteResult(item, fieldname, request.term);
                    });
                    var selectNode = $('#' + params.selectId);
                    selectNode.html(out);
                    selectNode.selectable({
                        filter:'.ui-selectable',
                        selected:function(event,ui){$.icescrum.dblclickSelectable(ui,300,function(){$.icescrum.chooseSelected(params.selectId,params.listId,fieldname);return false;});}
                    });
                    $('.ui-selectable',selectNode).draggable({opacity: 0.8, helper: 'clone',handle:'.ico'});
                    response({});
                }
            });
        },

        updateProfile:function(data){
           $('#profile-name a').html(data.name);
            if(data.updateAvatar){
                $('.avatar-user-'+data.userid).each(
                      function(){
                        $(this).attr('src',data.updateAvatar+'?nocache='+new Date().getTime());
                      }
                )
            }

            if(data.forceRefresh){
                $.doTimeout(500,function(){
                    document.location.reload(true);
                })
            }
            $.icescrum.renderNotice(data.notice,'notice');
        },

        autoCompleteSearch:function(request, response, url, params) {
            if(params.before){
                params.before();
            }
            $.ajax({
                url: url,
                data: {
                    term: request.term
                },
                success: function(data) {
                    $('#' + params.update).html(data);
                    response({});
                    var obj = $(this);
                    $.doTimeout(200,function(){$('#autoCmpTxt').focus()})
                }
            });
        }

    },

            $.fn.addOptionToSelect = function(key, value) {
                $(this).append($("<option></option>").attr("value", key).text(value));
            },

            $.fn.removeOptionToSelect = function(key) {
                var id = $(this).attr('id');
                $("#" + id + " option[value='" + key + "']").remove();
            },

            $.fn.removeOptionToSelectAndAfter = function(key) {
                var id = $(this).attr('id');
                var deleteOption = false;
                $('#' + id + ' option').each(function () {
                    var optionKey = $(this).attr('value');
                    if (optionKey == key) {
                        deleteOption = true;
                    }
                    if (deleteOption) {
                        $(this).remove();
                    }
                });
            },

            $.fn.changeSelectDate = function(date) {
                var obj = $(this);
                var id = obj.attr('id');
                var select = $('#' + id + ' option');
                var moveTo = -1;
                select.each(function () {
                    var option = $(this).val();
                    if (option <= date && date >= option) {
                        moveTo += 1;
                    }
                });
                if (moveTo != -1) {
                    obj.selectmenu('value', moveTo);
                } else {
                    obj.selectmenu('value', 0);
                }
            },

            $.fn.changeSelectValue = function(value) {
                var obj = $(this);
                var select = $('#' + obj.attr('id') + ' option');
                select.each(function () {
                    var option = $(this).val();
                    if (option == value){
                         obj.selectmenu('value', $(this).index());
                    }
                });
            },

            $.fn.refreshSelect = function() {
                var options = $(this).selectmenu('getOptions');
                $(this).selectmenu('destroy').selectmenu(options);
            },

            $.fn.toggleListDisplay = function() {
                var obj = $(this);
                var id = obj.attr('id');
                obj.bind('mouseleave', function(event) {
                    $('#' + id + '-content').hide()
                });
                obj.bind('mouseenter', function(event) {
                    $('#' + id + '-content').show()
                });
            },

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
                    iconWindow.parent().parent().parent().bind('dblclick', function(event) {
                        $.icescrum.widgetToWindow(obj, event)
                    });
                    obj.addClass('draggable-to-desktop');
                }

                if (opts.closeable) {
                    $("#" + widgetid + ' .widget-close').bind('click', function(event) {
                        $.icescrum.closeWidget(obj, event)
                    });
                }

                if (opts.height) {
                    jQuery("#widget-content-"+id).scrollbar({contentHeight:parseInt(opts.height)});
                }
            },

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
                    iconMaximize.parent().parent().parent().bind('dblclick', function(event) {
                        if(!$(event.target).is('a,span') ){
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

            $.fn.toggleEnabled = function(opt) {
                var obj = $(this);
                var selectable = $(opt);

                selectable.bind("selectableselected", function(event, ui) {
                    $('.window-toolbar').icescrum('toolbar', 'buttons', opt).enable();
                });
                selectable.bind("selectableunselected", function(event, ui) {
                    $('.window-toolbar').icescrum('toolbar', 'buttons', 0).disable();
                });
            };

            $.fn.isWizard = function(options) {
                options = $.extend({
                    submitButton: "",
                    nextButton:"",
                    previousButton:"",
                    cancelButton:"",
                    submitFunction:""
                }, options);

                var element = this;

                var steps = $(element).find(".panel");
                var count = steps.size();

                $(element).wrap("<div class='wizard clearfix'></div>");

                var wrapper = $("<div class='wizard-buttons'></div>");

                $(element).parent().parent().append(wrapper);
                $(element).before("<div id='wizard-left'><ul id='steps'></ul></div>");

                steps.each(function(i) {
                    var step = $(this).wrap("<div id='step" + i + "'></div>");
                    wrapper.append("<p id='step" + i + "commands' class='wizard-commands clearfix'></p>");
                    var section = $(this).find("h3");
                    section.hide();
                    var name = section.html();
                    $("#steps").append("<li id='stepDesc" + i + "'><p>" + (i + 1) + '.' + " <span>" + name + "</span></p></li>");
                    step.prepend("<p class='field-information field-information-nobordertop'>" + $(this).attr('description') + "</p>");

                    if (i == 0) {
                        createCancelButton(i);
                        createNextButton(i);
                        selectStep(i);
                    }
                    else if (i == count - 1) {
                        $("#step" + i).hide();
                        $("#step" + i + "commands").hide();
                        createCancelButton(i);
                        createFinishButton(i);                        
                        createPrevButton(i);
                    }
                    else {
                        $("#step" + i).hide();
                        $("#step" + i + "commands").hide();
                        createCancelButton(i);
                        createNextButton(i);
                        createPrevButton(i);
                    }
                });

                function createCancelButton(i) {
                    var stepName = "step" + i;
                    $("#" + stepName + "commands").append("<button class='ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only prev' id='" + stepName + "Cancel' class='prev'><span class='ui-button-text'>" + options.cancelButton + "</span></button>");
                    $("#" + stepName + "Cancel").bind("click", function(e) {
                        $('#dialog').dialog('close');
                    });
                }

                function createPrevButton(i) {
                    var stepName = "step" + i;
                    $("#" + stepName + "commands").append("<button class='ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only prev' id='" + stepName + "Prev' class='prev'><span class='ui-button-text'>" + options.previousButton + "</span></button>");

                    $("#" + stepName + "Prev").bind("click", function(e) {
                        $("#" + stepName).hide();
                        $("#step" + (i - 1)).show();
                        $("#step" + i + "commands").hide();
                        $("#step" + (i - 1) + "commands").show();
                        selectStep(i - 1);
                    });
                }

                function createNextButton(i) {
                    var stepName = "step" + i;
                    $("#" + stepName + "commands").append("<button class='ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only next' id='" + stepName + "Next'><span class='ui-button-text'>" + options.nextButton + "</span></button>");

                    $("#" + stepName + "Next").bind("click", function(e) {
                        $("#" + stepName).hide();
                        $("#step" + i + "commands").hide();
                        $("#step" + (i + 1) + "commands").show();
                        $("#step" + (i + 1)).show();
                        selectStep(i + 1);
                    });
                }

                function createFinishButton(i) {
                    var stepName = "step" + i;
                    $("#" + stepName + "commands").append("<button class='ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only next' id='" + stepName + "Next'><span class='ui-button-text'>" + options.submitButton + "</span></button>");

                    $("#" + stepName + "Next").bind("click", function(e) {
                        options.submitFunction();
                    });
                    $("#" + stepName + "Cancel").bind("click", function(e) {
                        $('#dialog').dialog('close');
                    });
                }

                function selectStep(i) {
                    $("#steps li").removeClass("current");
                    $("#steps li").removeClass("old");
                    $("#stepDesc" + i).addClass("current");

                    for (var j = i - 1; j >= 0; j--) {
                        $("#stepDesc" + j).addClass("old");
                    }
                }

            };

})(jQuery);

$.fn.icescrum = function(options) {
    if ((typeof options) == "string") {
        //TODO : refactor icescrum('toolbar')
        if (options == 'toolbar')
            return $.icescrum[options](this, arguments);
        else
            return $.icescrum[options].apply(this, arguments);
    }
    return $.icescrum
};

$.fn.isWindow.defaults = {
    maximizeable:false,
    widgetable:false,
    closeable:true,
    onMaximize:null,
    onUnMaximize:null,
    onClose:null
};

$.fn.isWidget.defaults = {
    windowable:false,
    height:true,
    closeable:true,
    onClose:null
};

$.fn.qtip.styles.icescrum = {
    border: {
        width: 0,
        radius: 5,
        color: '#fffdc0'
    },
    title: {
        background: '#fffca2',
        color: '#221f03',
        'font-weight': 'bold',
        padding:'2px 5px'
    },

    background: '#fffca2',
    color: '#221f03',

    width: {
        min: '200',
        max: '400'
    },

    classes: {
        title: 'qtip-title break-word',
        content: 'qtip-title break-word',
        tooltip: 'css3-shadow qtip-icescrum'
    },
    name: 'light' // Inherit the rest of the attributes from the preset dark style
};

$.icescrum.init();

/**
 * Cookie plugin
 *
 * Copyright (c) 2006 Klaus Hartl (stilbuero.de)
 * Dual licensed under the MIT and GPL licenses:
 * http://www.opensource.org/licenses/mit-license.php
 * http://www.gnu.org/licenses/gpl.html
 *
 */
jQuery.cookie = function(name, value, options) {
    if (typeof value != 'undefined') { // name and value given, set cookie
        options = options || {};
        if (value === null) {
            value = '';
            options.expires = -1;
        }
        var expires = '';
        if (options.expires && (typeof options.expires == 'number' || options.expires.toUTCString)) {
            var date;
            if (typeof options.expires == 'number') {
                date = new Date();
                date.setTime(date.getTime() + (options.expires * 24 * 60 * 60 * 1000));
            } else {
                date = options.expires;
            }
            expires = '; expires=' + date.toUTCString(); // use expires attribute, max-age is not supported by IE
        }
        // CAUTION: Needed to parenthesize options.path and options.domain
        // in the following expressions, otherwise they evaluate to undefined
        // in the packed version for some reason...
        var path = options.path ? '; path=' + (options.path) : '';
        var domain = options.domain ? '; domain=' + (options.domain) : '';
        var secure = options.secure ? '; secure' : '';
        document.cookie = [name, '=', encodeURIComponent(value), expires, path, domain, secure].join('');
    } else { // only name given, get cookie
        var cookieValue = null;
        if (document.cookie && document.cookie != '') {
            var cookies = document.cookie.split(';');
            for (var i = 0; i < cookies.length; i++) {
                var cookie = jQuery.trim(cookies[i]);
                // Does this cookie string begin with the name we want?
                if (cookie.substring(0, name.length + 1) == (name + '=')) {
                    cookieValue = decodeURIComponent(cookie.substring(name.length + 1));
                    break;
                }
            }
        }
        return cookieValue;
    }
};
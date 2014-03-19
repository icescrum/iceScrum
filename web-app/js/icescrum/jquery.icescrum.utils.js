/*
 * Copyright (c) 2011 Kagilum SAS.
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
(function($) {
    $.extend($.icescrum, {

        htmlEncode:function(value) {
            return $('<div/>').text(value).html();
        },

        htmlDecode:function(value) {
            return $('<div/>').html(value).text();
        },

        applyStringFunctionToJSON:function(object, f) {
            return JSON.parse(f(JSON.stringify(object)));
        },

        htmlEncodeJSON:function(object) {
            return $.icescrum.applyStringFunctionToJSON(object, $.icescrum.htmlEncode);
        },

        htmlDecodeJSON:function(object) {
            return $.icescrum.applyStringFunctionToJSON(object, $.icescrum.htmlDecode);
        },

        isValidEmail:function(email) {
            var filter = /^([\w-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([\w-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$/;
            return filter.test(email);
        },

        dateLocaleFormat:function(date, year, month, day) {
            var a;
            if (typeof date === 'string') {
                date = this.jsonToDate(date);
            }
            var format = $.datepicker.regional[$.icescrum.o.locale].dateFormat;
            return $.datepicker.formatDate(format, date);
        },

        jsonToDate:function(date) {
            var a;
            if (typeof date === 'string') {
                a = /^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2}(?:\.\d*)?)(Z|([+\-])(\d{2}):(\d{2}))$/.exec(date);
                if (a) {
                    date = new Date(Date.UTC(+a[1], +a[2] - 1, +a[3], +a[4], +a[5], +a[6]));
                }
            }
            return date;
        },

        serverDate:function(date, withTime) {
            if (typeof date === 'string') {
                date = this.jsonToDate(date);
            }
            var utc = date.getTime() + date.getTimezoneOffset() * 60000;
            var offset = parseInt($.icescrum.product.timezoneOffset);
            var serverMillis = utc + (3600000*offset);
            var serverDate = new Date(serverMillis);
            var dateFormat = $.datepicker.regional[$.icescrum.o.locale].dateFormat;
            var dateString = $.datepicker.formatDate(dateFormat, serverDate);
            if(withTime) {
                dateString += ' ' + serverDate.toLocaleTimeString();
            }
            return dateString;
        },

        stopEvent:function(event) {
            event = $.event.fix(event || window.event);
            event.stopPropagation();
            return this;
        },

        dialogError:function(xhr) {
            var text;
            if (xhr.status) {
                var ct = xhr.getResponseHeader("content-type") || "";
                if (ct.indexOf('json') > -1) {
                    text = $.parseJSON(xhr.responseText);
                    if (text.error != undefined) {
                        $.icescrum.renderNotice(text.error, 'error');
                        return;
                    }
                } else {
                    text = this.htmlDecode(xhr.responseText);
                }
            } else {
                text = xhr;
            }
            var $dialog = $('#dialog');
            if($dialog.length){
                $dialog.dialog('close');
                $dialog.remove();
            }
            $(document.body).append(this.o.dialogErrorContent);
            $('#comments').focus();
            $('#stackError').val(text);
            $('#stackError-field').input({className:'area'});
            $('#comments-field').input({className:'area'});
            //must revalidate selector
            $('#dialog').dialog({
                        dialogClass: 'no-titlebar',
                        closeOnEscape:true,
                        closeText:'Close',
                        draggable:false,
                        modal:true,
                        position:'top',
                        resizable:false,
                        width:600,
                        close:function(ev, ui) {
                            $(this).remove();
                        },
                        buttons:{
                            'Cancel': function() {
                                $(this).dialog('close');
                            },
                            'OK': function() {
                                $.ajax({
                                            type:'POST',
                                            data:$('#dialog').find('form:first').serialize(),
                                            url:$.icescrum.o.baseUrl + 'reportError',
                                            success:function(data, textStatus) {
                                                $.icescrum.renderNotice(data.notice.text, data.notice.type);
                                                $('#dialog').dialog('close');
                                            },
                                            error:function() {
                                                $('#dialog').dialog('close');
                                            }
                                        });
                            }
                        }
                    });
        },

        //TODO to be remove
        navigateTo:function(hash) {
            var url = location.hash.replace(/^.*#/, '');
            if (url != hash) {
                location.hash = hash;
            }
        },

        initAtmosphere:function() {
            if (!this.o.push.enable)
                return;

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
                        //TODO remove old code
                        if (this.call && this.object) {
                            if (this.object['class']) {
                                var type = this.object['class'].substring(this.object['class'].lastIndexOf('.') + 1).toLowerCase();
                                this.call = (this.call == 'delete') ? 'remove' : this.call;
                                if (this.call == 'remove'){
                                    $.icescrum.object.removeFromArray(type, this.object);
                                } else {
                                    $.icescrum.object.addOrUpdateToArray(type, this.object);
                                }
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

        initHistory:function() {

            var changeWindow = function(){
                if ($.icescrum.o.openWindow) {
                    $.icescrum.o.openWindow = false;
                } else {
                    var url = location.hash.replace(/^.*#/, '');
                    var openDialog = null;
                    if (url != '') {
                        url = url.split('!');
                        if (url[1]){
                            openDialog = function(){
                                ajaxRequest($(document.body),{url:$.icescrum.o.baseUrl+url[1]});
                            }
                        }
                        if (url[0]){
                            $.icescrum.openWindow(url[0], openDialog);
                        } else {
                            openDialog();
                        }
                    } else if (!url) {
                        if ($.icescrum.o.currentOpenedWindow) {
                            $.icescrum.closeWindow($.icescrum.o.currentOpenedWindow);
                        }
                    }
                }
            };

            $(window).hashchange(changeWindow);

            if (!$.getUrlVar('ref')){
                changeWindow();
            }

            var currentWindow = location.hash.replace(/^.*#/, '');
            var $menubar = $('#mainmenu').find('li.menubar:not(.hidden):first a');
            if ($.icescrum.o.baseUrlSpace && !currentWindow && $menubar){
                var menubar = $menubar.attr('href').replace(/^.*#/, '');
                document.location.hash = menubar;
            }

            if ($.icescrum.getWidgetsList().length > 0) {
                var tmp = $.icescrum.getWidgetsList();
                for (i = 0; i < tmp.length; i++) {
                    this.openWidget(tmp[i], null, true);
                }
            }
        },

        initLocalStorage:function(){
            if(!localStorage['date_storage']){
                localStorage['date_storage'] = new Date();
            } else if(localStorage['date_storage']) {
                var daysLater = new Date(localStorage['date_storage']);
                daysLater.setDate(daysLater.getDate()+30);
                if (localStorage['date-time'] < new Date()){
                    localStorage['date-time'] = new Date();
                    localStorage['date_storage'] = null;
                }
            }
        },

        initAjaxSetup:function(){

            $.ajaxSetup({ timeout:45000 });

            $(document).ajaxSend(function(event, xhr, settings){
                xhr.setRequestHeader("If-Modified-Since",new Date(1970,1,1).toUTCString());
                xhr.setRequestHeader("Pragma","no-cache");
                if ($.icescrum.o.push && $.icescrum.o.push.uuid && settings.url.indexOf('X-Atmosphere-tracking-id') == -1){
                    xhr.setRequestHeader("X-Atmosphere-tracking-id", $.icescrum.o.push.uuid);
                }
                $.icescrum.loading(true);
            });

            $(document).ajaxError(function(data) {
                $.icescrum.loading(false, true);
            });

            $(document).ajaxComplete(function(e,xhr,settings){
                $.icescrum.loading(false);
                if(xhr.status == 403){
                    $.icescrum.renderNotice('Access forbidden', 'error');
                }else if(xhr.status == 401){
                    ajaxRequest($(document.body), {url:$.icescrum.o.grailsServer+'/login'});
                }else if(xhr.status == 400){
                    var error = $.parseJSON(xhr.responseText);
                    $.icescrum.renderNotice( error.notice.text, 'error', error.notice.title);
                }else if(xhr.status == 500){
                    $.icescrum.dialogError(xhr);
                }
            });

            $(document).ajaxStop(function() {
                $.icescrum.loading(false);
            });
        },

        initNotifications:function(){
            if (notify.isSupported) {
                console.log("[notifications] are supported!");
                if (notify.permissionLevel() == notify.PERMISSION_GRANTED) {
                    console.log("[notifications] got permission");
                    $.icescrum.o.notifications = true;
                }
                else if(notify.permissionLevel() == notify.PERMISSION_DEFAULT && !localStorage['hide_notifications']){
                    var $alert = $("#notifications");
                    $alert.show();
                    $alert.find('a').click(function(){
                        notify.requestPermission(function(){
                            var level = notify.permissionLevel();
                            if (level == notify.PERMISSION_GRANTED){
                                console.log("[notifications] got permission");
                                $.icescrum.o.notifications = true;
                            }
                            localStorage['hide_notifications'] = true;
                            $("#notifications").remove();
                        });
                        return false;
                    });
                    $alert.find('button').click(function(){
                        localStorage['hide_notifications'] = true;
                        $("#notifications").remove();
                    });
                }else{
                    console.log("[notifications] permission refused");
                    $("#notifications").remove();
                }
            }else{
                $("#notifications").remove();
                console.log("Notifications are not supported for this Browser/OS version yet.");
                $.icescrum.o.notifications = false;
            }
        },

        initUpgrade:function(){
            var upgrade = $('#upgrade');
            if (upgrade.length && !localStorage['hide_upgrade']){
                upgrade.show();
                upgrade.find('button').click(function(){
                    upgrade.remove();
                    localStorage['hide_upgrade'] = true;
                });
            }else if(upgrade.length){
                upgrade.remove();
            }
        },

        displayNotification:function(title, msg, type){
            var image = $.icescrum.o.baseUrl + "images/";
            image += type == "error" ?  "logo-disconnected.png" : "logo-connected.png";
            if (this.o.notifications){
                notify.createNotification(title, {
                    body:$('<div/>').html(msg.replace(/<\/?[^>]+>/gi, '')).text(),
                    icon:image
                });
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
            if ($.icescrum.o.notifications){
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

        //TODO to be remove
        addHistory:function(hash) {
            var url = location.hash.replace(/^.*#/, '');
            if (url != hash) {
                $.icescrum.o.openWindow = true;
                location.hash = hash;
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

        addModal:function(modal){
            var $container = $("#dialog-container");
            if (!$container.length){
                $container = $("<div id='dialog-container'/>").appendTo(document.body);
            }else {
                var $dialog = $container.find('.modal');
                $dialog.modal('hide');
                $('body').removeClass('modal-open');
                $('.modal-backdrop').remove();
                $dialog.remove();
            }
            $(modal).appendTo($container);
            attachOnDomUpdate($container);
        },

        displayShortcuts:function(){
            var shortcuts = [];
            $('[data-is-shortcut]').each(function(){
                var shortcut = $(this);
                var title = shortcut.attr('title') ? shortcut.attr('title') : shortcut.text();
                title = title.indexOf('(') > 0 ? title.substring(0, title.indexOf('(')) : title;
                shortcuts.push({title:title, key:shortcut.data('isShortcutKey').split(' ')});
            });
            var modal = $.template('tpl-list-shortcuts', {shortcuts:shortcuts});
            $.icescrum.addModal(modal);
        },

        openChart:function(){
            var $this = $(this);
            var settings = $this.html5data('ui-chart');
            var $btn = $this.closest('.btn-group').find('.btn');
            return $.icescrum.displayChart(settings.container, $this.attr('href'), settings.save, $btn);
        },

        displayChart:function(container, url, save, button) {
            if (button){
                button.button('loading');
            }
            jQuery.ajax({
                type:'GET',
                global:false,
                cache:true,
                data:{modal:container == 'modal'},
                url:$.icescrum.o.baseUrlSpace + url,
                success:function(data) {
                    if (container != 'modal'){
                        $(container).html(data);
                        $('.save-chart', $(container)).remove();
                        if (typeof save != 'undefined' && save) {
                            localStorage[container + $.icescrum.product.id] = url;
                        }
                    } else {
                        var $container = $("#dialog-container");
                        if (!$container.length){
                            $container = $("<div id='dialog-container'/>").appendTo(document.body);
                        }else {
                            var $dialog = $container.find('.modal');
                            $dialog.modal('hide');
                            $('body').removeClass('modal-open');
                            $('.modal-backdrop').remove();
                            $dialog.remove();

                        }
                        var dialog = $(data).appendTo($container);
                        var $chart = $container.find('.chart-container');
                        dialog.on('shown.bs.modal',function(){
                            $chart.trigger('replot');
                        });
                        attachOnDomUpdate($container);
                    }
                },
                error:function(XMLHttpRequest) {
                    var data = $.parseJSON(XMLHttpRequest.responseText);
                    $(container).css("height", null);
                    $(container).html(data.notice.text);
                },
                complete:function(){
                    if (button) {
                        button.button('reset');
                    }
                }
            });
            return false;
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

        updateStartDateDatePicker:function(data) {
            var date = this.jsonToDate(data.endDate);
            date.setDate(date.getDate() + 1);
            date = this.dateLocaleFormat(date);
            var $startDate = $('#datepicker-startDate');
            $startDate.datepicker('option', {minDate:date, defaultDate:date});
            $startDate.datepicker('setDate', date);
        },

        updateEndDateDatePicker:function(data, delta) {
            var date = this.jsonToDate(data.endDate);
            date.setDate(date.getDate() + 2);
            var date2 = new Date(date);
            date2.setDate(date.getDate() + (delta - 1));
            var $endDate = $('#datepicker-endDate');
            $endDate.datepicker('option', {minDate:this.dateLocaleFormat(date), defaultDate:this.dateLocaleFormat(date2)});
            $endDate.datepicker('setDate', this.dateLocaleFormat(date2));
        },

        //todo remove
        updateFilterTask:function(data, xhr, status, element){
            if (element.data('active')){
                $('#menu-filter-task-list').addClass('filter-active');
            } else {
                $('#menu-filter-task-list').removeClass('filter-active');
            }
            $.icescrum.sprint.currentTaskFilter = element.data('filter');
            $.icescrum.sprint.updateRemaining();
            $('#menu-filter-task-navigation-item').find('.content').html('<span class="ico"></span>'+element.text());
        },

        //todo remove
        updateHideDoneState:function(show,hide){
            var filter = $('#menu-filter-task-list').find('.dropmenu-content li.last');
            if(filter.text().trim() == show){
                filter.find('a').text(hide);
            }else{
                filter.find('a').text(show);
            }
        },

        truncate:function(string, size){
            if(string.length>(size-1))
                return string.substring(0,size)+"...";
            else
                return string;
        },

        selectableShortcut:function(event){
            var key = event.data.toLowerCase();
            var $this = $(this);
            if (_.contains(['up','down','right','left'], key)){
                $.icescrum.selectableNavigate.apply(this,[event]);
            } else {
                //select All
                $this.find('.ui-selectee').addClass('ui-selected');
                var stop = $this.parent().selectableScroll("option" , "stop");
                if (stop){
                    stop({target:$this.parent()});
                }
            }
        },

        selectableNavigate:function(event){
            var $this = $(this);
            var $el = $this.find('.ui-selected');
            //cache value
            if (!$this.data('is.count') || $this.data('is.count') < 1){
                var width = $el.outerWidth(true);
                var containerWidth = $el.parent().width();
                var count = containerWidth / width;
                $this.data('is.count', Math.floor(count));
                //reset cache value on resize
                $this.one('resize',function(){
                    $this.data('is.count', -1);
                })
            }
            if ($this.data('is.count') >= 1){
                var $new = null;
                if ($el.length == 1){
                    var list = $this.children();
                    var currentIndex = $el.index();
                    var key = event.data.toLowerCase();
                    if (key == "up"){
                        if (currentIndex - $this.data('is.count') >= 0)
                            $new = $(list.get(currentIndex - $this.data('is.count')));
                    }else if(key == "down"){
                        if (currentIndex + $this.data('is.count') < list.length)
                            $new = $(list.get(currentIndex + $this.data('is.count')));
                    }else if(key == "left"){
                        $new = $el.prev();
                    }else if(key == "right"){
                        $new = $el.next();
                    }
                    if ($new && $new.length && $new.hasClass('ui-selectee')){
                        $el.removeClass('ui-selected');
                        $new.addClass('ui-selected');
                        $.doTimeout('scrollSelectable', 500, function(){
                            $this.parent().animate({ scrollTop: ($this.parent().scrollTop() + $new.position().top) } );
                        }, true);
                        var stop = $this.parent().selectableScroll("option" , "stop");
                        if (stop){
                            stop({target:$this.parent()});
                        }
                    }
                }
            }
            return false;
        },

        selectableStop:function(event, ui){
            var selectable = $(event.target);
            var els = selectable.find('.ui-selected:not(".new")');
            var toolbarButtons = $(".window-toolbar > .navigation-item > .on-selectable");
            var ids = els.map( function(){return $(this).data("elemid"); }).get();

            if (!selectable.data('init-select-hash')){
                $.icescrum.o.currentOpenedWindow.bind('subhashchange', $.icescrum.selectableHash);
                selectable.data('init-select-hash', true);
            }

            if (_.isEqual(selectable.data('current'),ids)){
                //second click grab focus
                if (ids.length){
                    var input = $('#contextual-properties').find('input:first:visible');
                    if (input.is(":focus")){
                        input.blur();
                    }
                    //to give focus
                    selectable.find('.ui-selected:last a:first').focus();
                }
                return false;
            }
            switch (els.length){
                //no selection
                case 0:
                    document.location.hash = $.icescrum.o.currentOpenedWindow.data('id');
                    toolbarButtons.addClass('on-selectable-disabled');
                    break;
                //one selection
                case 1:
                    var elem = selectable.find('.ui-selected');
                    document.location.hash = $.icescrum.o.currentOpenedWindow.data('id') + '/' +elem.data('elemid');
                    toolbarButtons.removeClass('on-selectable-disabled');
                    selectable.animate({ scrollTop: (selectable.scrollTop() + elem.position().top) }, 250);
                    break;
                //Display multiple selection
                default:
                    document.location.hash = $.icescrum.o.currentOpenedWindow.data('id') + '/+';
                    toolbarButtons.removeClass('on-selectable-disabled');
                    break;
            }
            selectable.data('current', ids);
            return true;
        },

        selectableHash:function(event){
            var selectable = event.target ? $(event.target).find('.ui-selectable') : $(this).parent();
            var subHash = document.location.hash.replace(/^.*#/, '').split('/');
            subHash = subHash.length == 2 ? subHash[1] : null;
            var id = selectable.data('current');
            var update = false;
            if (subHash == id || subHash == '+'){
                //id is undefined at the first time so update with stop to init value
                update = id == undefined;
            } else {
                var selecteds = selectable.find('.ui-selected');
                selecteds.removeClass('ui-selected');
                if (subHash && subHash != '+'){
                    selecteds.removeClass('ui-selected');
                    var elem = selectable.find('[data-elemid='+subHash+']');
                    selectable.find('[data-elemid='+subHash+']').addClass('ui-selected');
                    update = true;
                } else {
                    update = selecteds.length > 0;
                }
            }
            if (update){
                var stop = selectable.selectableScroll("option" , "stop");
                if (stop){
                    stop({target:selectable});
                }
            }
        },

        onDropToWidgetBar:function(event, ui){
            var id = ui.draggable.attr('id').replace('elem_','');
            if (id != ui.draggable.attr('id')) {
                var $selector = $("#window-id-" + id);
                if ($selector.is(':visible')) {
                    $.icescrum.windowToWidget($selector, event);
                } else {
                    $.icescrum.openWidget(id);
                }
            }
        },

        toggleGridList:function(container, button){
            var $button = $(button);
            var $containerItems = $(container).find('.item');
            $button.find('span').toggleClass('glyphicon-th').toggleClass('glyphicon-th-list');
            if ($button.find('span').hasClass('glyphicon-th')){
                $containerItems.removeClass('list-group-item').addClass('grid-group-item');
                $.icescrum.o.showAsGrid = true;
            } else {
                $containerItems.addClass('list-group-item');
                $.icescrum.o.showAsGrid = false;
            }
        },

        onDropToWindow:function(event, ui){
            //hack when drop to dropdown hidden menu
            if ($('.menubar-hidden .ui-sortable-placeholder').length > 0){
                return;
            }

            var id = ui.draggable.attr('id').replace('widget-id-','');
            if (id == ui.draggable.attr('id')){
                id = ui.draggable.attr('id').replace('elem_','');
            }
            $.icescrum.openWindow(id);
        },

        onStartDragWidget:function(){
            $(this).hide()
        },

        onStopDragWidget:function(){
            var $this = $(this);
            if ($this.attr('remove') == 'true') {
                $this.remove();
            } else {
                $this.show();
            }
        },

        downloadExport:function(select){
            var $select = $(select);
            $select.data('ajaxBegin', function(){
                $select.select2('readonly', true);
            });
            $select.data('ajaxComplete', function(){
                $select.select2('readonly', false);
                $select.select2('data', null);
            });
            ajaxRequest($select, {
                url:  $($select.find(':selected')).attr('url'),
                type: 'GET',
                data: []
            });
        },

        loading:function(load, error) {
            var $logo = $("#is-logo");
            if (!$logo.hasClass('disconnected')){
                if (load != undefined && !load) {
                    $(document.body).css('cursor','default');
                    $logo.removeClass().addClass('connected');
                } else {
                    $(document.body).css('cursor','progress');
                    $logo.removeClass().addClass('loading');
                }
                if(error){
                    $logo.removeClass().addClass('disconnected');
                }
            }
        },

        toggleSidebar:function(){
            $(document.body).toggleClass('left-open');
            return false;
        }
    });

    $.fn.changeSelectDate = function(date) {
        var select = $(this);
        var id = select.attr('id');
        var options = $('#' + id + ' option');
        options.prop('selected', false);
        var lastOption = null;
        options.each(function () {
            var option = $(this);
            if (this.value <= date && date >= this.value) {
                lastOption = option;
            }
        });
        if(lastOption){
            lastOption.attr('selected','selected');
        }
        select.trigger("change");
    };

    $.fn.replaceWithPush = function(a) {
        var $a = $(a);

        this.replaceWith($a);
        return $a;
    };

    $.extend({
          getUrlVars: function(){
            var vars = [], hash;
            var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
            for(var i = 0; i < hashes.length; i++)
            {
              hash = hashes[i].split('=');
              vars.push(hash[0]);
              if (!hash[1]){
                  vars[hash[0]] = null;
              }else{
                  vars[hash[0]] = hash[1];
              }
            }
            return vars;
          },
          getUrlVar: function(name){
            var value = $.getUrlVars()[name];
            return value ? value : null;
          }
    });

    $.fn.togglePanels = function(){
      return this.each(function(){
        $(this).addClass("ui-accordion ui-accordion-icons ui-widget ui-helper-reset");
        $(this).find('h3').addClass("ui-accordion-header ui-helper-reset ui-state-default ui-corner-top ui-corner-bottom")
        .prepend('<span class="ui-icon ui-icon-triangle-1-e"></span>')
        .hover(function() { $(this).toggleClass("ui-state-hover"); })
        .click(function(){
            var headToggle = $(this).closest('h3');
            headToggle.toggleClass("ui-accordion-header-active ui-state-active ui-state-default ui-corner-bottom")
                .find("> .ui-icon").toggleClass("ui-icon-triangle-1-e ui-icon-triangle-1-s").end()
                .next().slideToggle();
            headToggle.find("> a > input.hidden[type='checkbox']").prop('checked', headToggle.hasClass("ui-accordion-header-active"));
            return false;
        })
        .next()
        .addClass("ui-accordion-content ui-helper-reset ui-widget-content ui-corner-bottom")
        .hide();

        $(this).find('h3.active').each(function(){
            var headToggle = $(this);
            headToggle.toggleClass("ui-accordion-header-active ui-state-active ui-state-default ui-corner-bottom")
                .find("> .ui-icon").toggleClass("ui-icon-triangle-1-e ui-icon-triangle-1-s").end()
                .next().slideToggle();
            headToggle.find("> a > input.hidden[type='checkbox']").prop('checked', headToggle.hasClass("ui-accordion-header-active"));
        });

      });
    };

    $.download = function(url, data, method){
        $('#download-frame').remove();
        //url and data options required
        if( url && data ){
            //data can be string of parameters or array/object
            data = typeof data == 'string' ? data : $.param(data);
            //split params into form inputs
            var inputs = '';
            $.each(data.split('&'), function(){
                var pair = this.split('=');
                inputs+='<input type="hidden" name="'+ pair[0] +'" value="'+ pair[1] +'" />';
            });
            //send request
            var frame = $('<iframe id="download-frame" style="display:none;"/>');
            frame.appendTo('body');
            $('<form action="'+ url +'" method="'+ (method||'post') +'">'+inputs+'</form>').appendTo(frame.contents().find("body")).submit().remove();
        }
    };

})($);

if (typeof String.prototype.startsWith != 'function') {
  // see below for better implementation!
  String.prototype.startsWith = function (str){
    return this.indexOf(str) == 0;
  };
}

String.prototype.formatLine = function(remove) {
    remove = remove ? "" : "<br/>";
    return this.replace(/\r\n/g, remove).replace(/\n/g, remove).replace(/"/g, '\\"');
};

/**
 * @return {boolean}
 */
function NotesToText(html, textarea){
    var dirty = $(html).html();
    $(html).after('<div id="tmp_html"></div>');
    var container = $('#tmp_html');
    var brk = '{break}';
    var dblbrk = '{dblbreak}';
    container.hide().html(dirty);
    container.find('ul').each(function(){
        var items = '';
        $(this).find('li').each(function() {
            items += '\t * ' + $(this).text() + brk;
        });
        $(this).replaceWith(brk + items + dblbrk);
    });
    container.find('h1').each(function(){
        $(this).replaceWith('h1. ' + $(this).html() + dblbrk);
    });
    container.find('h2').each(function(){
        $(this).replaceWith('h2. ' + $(this).html() + dblbrk);
    });
    var textile = container.html();
    textile = textile.replace(/ +(?= )/g,'');
    textile = textile.replace(/    \*/g, '*');
    textile = textile.replace(new RegExp(brk, 'g'), '\n');
    //textile = textile.replace(new RegExp('\t', 'g'), '');
    textile = textile.replace(new RegExp('  ', 'g'), ' ');
    textile = textile.replace(new RegExp('\\n ', 'g'), '\n');
    textile = textile.replace(new RegExp(dblbrk, 'g'), '\n');
    textile = textile.replace(new RegExp('\\n\\n', 'g'), '\n');
    $('h1'+textarea).show();
    var $textarea = $('textarea'+textarea);
    $textarea.show().val($.trim(textile));
    $textarea.parent().animate({scrollTop: $(textarea).offset().top}, 500,'easeInOutCubic');
    container.remove();
    return false;
}

/**
 * @return {boolean}
 */
function NotesToHtml(html, textarea){
    var text = $(html).html();
    text = text.replace(/ +(?= )/g,'');
    text = text.replace(/    \*/g, '*');
    text = text.replace(new RegExp('\t', 'g'), '');
    text = text.replace(new RegExp('  ', 'g'), ' ');
    text = text.replace(new RegExp('\\n ', 'g'), '\n');
    text = text.replace(new RegExp('\\n\\n', 'g'), '\n');
    $('h1'+textarea).show();
    var $textarea = $('textarea'+textarea);
    $textarea.show().val($.trim(text));
    $textarea.parent().animate({scrollTop: $(textarea).offset().top}, 500,'easeInOutCubic');
    return false;
}

(function($){$.md5=function(string){function RotateLeft(lValue,iShiftBits){return(lValue<<iShiftBits)|(lValue>>>(32-iShiftBits));}
    function AddUnsigned(lX,lY){var lX4,lY4,lX8,lY8,lResult;lX8=(lX&0x80000000);lY8=(lY&0x80000000);lX4=(lX&0x40000000);lY4=(lY&0x40000000);lResult=(lX&0x3FFFFFFF)+(lY&0x3FFFFFFF);if(lX4&lY4){return(lResult^0x80000000^lX8^lY8);}
        if(lX4|lY4){if(lResult&0x40000000){return(lResult^0xC0000000^lX8^lY8);}else{return(lResult^0x40000000^lX8^lY8);}}else{return(lResult^lX8^lY8);}}
    function F(x,y,z){return(x&y)|((~x)&z);}
    function G(x,y,z){return(x&z)|(y&(~z));}
    function H(x,y,z){return(x^y^z);}
    function I(x,y,z){return(y^(x|(~z)));}
    function FF(a,b,c,d,x,s,ac){a=AddUnsigned(a,AddUnsigned(AddUnsigned(F(b,c,d),x),ac));return AddUnsigned(RotateLeft(a,s),b);};function GG(a,b,c,d,x,s,ac){a=AddUnsigned(a,AddUnsigned(AddUnsigned(G(b,c,d),x),ac));return AddUnsigned(RotateLeft(a,s),b);};function HH(a,b,c,d,x,s,ac){a=AddUnsigned(a,AddUnsigned(AddUnsigned(H(b,c,d),x),ac));return AddUnsigned(RotateLeft(a,s),b);};function II(a,b,c,d,x,s,ac){a=AddUnsigned(a,AddUnsigned(AddUnsigned(I(b,c,d),x),ac));return AddUnsigned(RotateLeft(a,s),b);};function ConvertToWordArray(string){var lWordCount;var lMessageLength=string.length;var lNumberOfWords_temp1=lMessageLength+8;var lNumberOfWords_temp2=(lNumberOfWords_temp1-(lNumberOfWords_temp1%64))/64;var lNumberOfWords=(lNumberOfWords_temp2+1)*16;var lWordArray=Array(lNumberOfWords-1);var lBytePosition=0;var lByteCount=0;while(lByteCount<lMessageLength){lWordCount=(lByteCount-(lByteCount%4))/4;lBytePosition=(lByteCount%4)*8;lWordArray[lWordCount]=(lWordArray[lWordCount]|(string.charCodeAt(lByteCount)<<lBytePosition));lByteCount++;}
        lWordCount=(lByteCount-(lByteCount%4))/4;lBytePosition=(lByteCount%4)*8;lWordArray[lWordCount]=lWordArray[lWordCount]|(0x80<<lBytePosition);lWordArray[lNumberOfWords-2]=lMessageLength<<3;lWordArray[lNumberOfWords-1]=lMessageLength>>>29;return lWordArray;};function WordToHex(lValue){var WordToHexValue="",WordToHexValue_temp="",lByte,lCount;for(lCount=0;lCount<=3;lCount++){lByte=(lValue>>>(lCount*8))&255;WordToHexValue_temp="0"+lByte.toString(16);WordToHexValue=WordToHexValue+WordToHexValue_temp.substr(WordToHexValue_temp.length-2,2);}
        return WordToHexValue;};function Utf8Encode(string){string=string.replace(/\r\n/g,"\n");var utftext="";for(var n=0;n<string.length;n++){var c=string.charCodeAt(n);if(c<128){utftext+=String.fromCharCode(c);}
    else if((c>127)&&(c<2048)){utftext+=String.fromCharCode((c>>6)|192);utftext+=String.fromCharCode((c&63)|128);}
    else{utftext+=String.fromCharCode((c>>12)|224);utftext+=String.fromCharCode(((c>>6)&63)|128);utftext+=String.fromCharCode((c&63)|128);}}
        return utftext;};var x=Array();var k,AA,BB,CC,DD,a,b,c,d;var S11=7,S12=12,S13=17,S14=22;var S21=5,S22=9,S23=14,S24=20;var S31=4,S32=11,S33=16,S34=23;var S41=6,S42=10,S43=15,S44=21;string=Utf8Encode(string);x=ConvertToWordArray(string);a=0x67452301;b=0xEFCDAB89;c=0x98BADCFE;d=0x10325476;for(k=0;k<x.length;k+=16){AA=a;BB=b;CC=c;DD=d;a=FF(a,b,c,d,x[k+0],S11,0xD76AA478);d=FF(d,a,b,c,x[k+1],S12,0xE8C7B756);c=FF(c,d,a,b,x[k+2],S13,0x242070DB);b=FF(b,c,d,a,x[k+3],S14,0xC1BDCEEE);a=FF(a,b,c,d,x[k+4],S11,0xF57C0FAF);d=FF(d,a,b,c,x[k+5],S12,0x4787C62A);c=FF(c,d,a,b,x[k+6],S13,0xA8304613);b=FF(b,c,d,a,x[k+7],S14,0xFD469501);a=FF(a,b,c,d,x[k+8],S11,0x698098D8);d=FF(d,a,b,c,x[k+9],S12,0x8B44F7AF);c=FF(c,d,a,b,x[k+10],S13,0xFFFF5BB1);b=FF(b,c,d,a,x[k+11],S14,0x895CD7BE);a=FF(a,b,c,d,x[k+12],S11,0x6B901122);d=FF(d,a,b,c,x[k+13],S12,0xFD987193);c=FF(c,d,a,b,x[k+14],S13,0xA679438E);b=FF(b,c,d,a,x[k+15],S14,0x49B40821);a=GG(a,b,c,d,x[k+1],S21,0xF61E2562);d=GG(d,a,b,c,x[k+6],S22,0xC040B340);c=GG(c,d,a,b,x[k+11],S23,0x265E5A51);b=GG(b,c,d,a,x[k+0],S24,0xE9B6C7AA);a=GG(a,b,c,d,x[k+5],S21,0xD62F105D);d=GG(d,a,b,c,x[k+10],S22,0x2441453);c=GG(c,d,a,b,x[k+15],S23,0xD8A1E681);b=GG(b,c,d,a,x[k+4],S24,0xE7D3FBC8);a=GG(a,b,c,d,x[k+9],S21,0x21E1CDE6);d=GG(d,a,b,c,x[k+14],S22,0xC33707D6);c=GG(c,d,a,b,x[k+3],S23,0xF4D50D87);b=GG(b,c,d,a,x[k+8],S24,0x455A14ED);a=GG(a,b,c,d,x[k+13],S21,0xA9E3E905);d=GG(d,a,b,c,x[k+2],S22,0xFCEFA3F8);c=GG(c,d,a,b,x[k+7],S23,0x676F02D9);b=GG(b,c,d,a,x[k+12],S24,0x8D2A4C8A);a=HH(a,b,c,d,x[k+5],S31,0xFFFA3942);d=HH(d,a,b,c,x[k+8],S32,0x8771F681);c=HH(c,d,a,b,x[k+11],S33,0x6D9D6122);b=HH(b,c,d,a,x[k+14],S34,0xFDE5380C);a=HH(a,b,c,d,x[k+1],S31,0xA4BEEA44);d=HH(d,a,b,c,x[k+4],S32,0x4BDECFA9);c=HH(c,d,a,b,x[k+7],S33,0xF6BB4B60);b=HH(b,c,d,a,x[k+10],S34,0xBEBFBC70);a=HH(a,b,c,d,x[k+13],S31,0x289B7EC6);d=HH(d,a,b,c,x[k+0],S32,0xEAA127FA);c=HH(c,d,a,b,x[k+3],S33,0xD4EF3085);b=HH(b,c,d,a,x[k+6],S34,0x4881D05);a=HH(a,b,c,d,x[k+9],S31,0xD9D4D039);d=HH(d,a,b,c,x[k+12],S32,0xE6DB99E5);c=HH(c,d,a,b,x[k+15],S33,0x1FA27CF8);b=HH(b,c,d,a,x[k+2],S34,0xC4AC5665);a=II(a,b,c,d,x[k+0],S41,0xF4292244);d=II(d,a,b,c,x[k+7],S42,0x432AFF97);c=II(c,d,a,b,x[k+14],S43,0xAB9423A7);b=II(b,c,d,a,x[k+5],S44,0xFC93A039);a=II(a,b,c,d,x[k+12],S41,0x655B59C3);d=II(d,a,b,c,x[k+3],S42,0x8F0CCC92);c=II(c,d,a,b,x[k+10],S43,0xFFEFF47D);b=II(b,c,d,a,x[k+1],S44,0x85845DD1);a=II(a,b,c,d,x[k+8],S41,0x6FA87E4F);d=II(d,a,b,c,x[k+15],S42,0xFE2CE6E0);c=II(c,d,a,b,x[k+6],S43,0xA3014314);b=II(b,c,d,a,x[k+13],S44,0x4E0811A1);a=II(a,b,c,d,x[k+4],S41,0xF7537E82);d=II(d,a,b,c,x[k+11],S42,0xBD3AF235);c=II(c,d,a,b,x[k+2],S43,0x2AD7D2BB);b=II(b,c,d,a,x[k+9],S44,0xEB86D391);a=AddUnsigned(a,AA);b=AddUnsigned(b,BB);c=AddUnsigned(c,CC);d=AddUnsigned(d,DD);}
    var temp=WordToHex(a)+WordToHex(b)+WordToHex(c)+WordToHex(d);return temp.toLowerCase();};})(jQuery);
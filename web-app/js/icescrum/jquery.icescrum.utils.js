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
        //TODO maybe to delete
        displayQuicklook:function(obj){
            if ($(".box-window").hasClass('window-fullscreen')){
                return;
            }
            var elem = obj.selected ? $(obj.selected) : $(obj);
            var type;
            if (elem.hasClass('postit-actor') || elem.hasClass('postit-row-actor')){
                type = 'actor.id';
            }else if(elem.hasClass('postit-feature') || elem.hasClass('postit-row-feature')){
                type = 'feature.id';
            }else if(elem.hasClass('postit-task') || elem.hasClass('postit-row-task')){
                type = 'task.id';
            }else if(elem.hasClass('postit-story') || elem.hasClass('postit-row-story')){
                type = 'story.id';
            }
            $.get($.icescrum.o.baseUrlSpace + 'quickLook?'+type+'='+elem.data('elemid'), function(data){
                var $dialog = $('#dialog');
                if ($dialog.length){
                    $dialog.dialog('close');
                }
                $(document.body).append(data.dialog);
            });
        },

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
                    if (url != '') {
                        $.icescrum.openWindow(url);
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
            var $menubar = $('#navigation').find('li.menubar:first a');
            if ($.icescrum.o.baseUrlSpace && !currentWindow && $menubar){
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
                    var data = jQuery.parseJSON(xhr.responseText);
                    document.location=$.icescrum.o.grailsServer+'/login?ref=p/'+ $.icescrum.product.pkey+'/'+(data.url?data.url:'');
                }else if(xhr.status == 400){
                    var error = jQuery.parseJSON(xhr.responseText);
                    $.icescrum.renderNotice( error.notice.text, 'error', error.notice.title);
                }else if(xhr.status == 500){
                    $.icescrum.dialogError(xhr);
                }
            });

            $(document).ajaxStop(function() {
                $.icescrum.loading(false);
            });
        },

        loading:function(load, error) {
            var $logo = $("#is-logo");
            if (load != undefined && !load) {
                $(document.body).css('cursor','default');
                $logo.stop(true).css('opacity', 1.0).removeClass().addClass('connected');
            } else {
                $(document.body).css('cursor','progress');
                $logo.removeClass().addClass('working')
                    .animate({opacity: 1.0}, {duration: 250})
                    .animate({opacity: 0}, {duration: 250})
                    .animate({opacity: 1.0}, {duration: 250, complete:$.icescrum.loading});
            }
            if(error){
                $logo.addClass('disconnected');
            }
        },

        initNotifications:function(){
            if (window.webkitNotifications) {
                console.log("[notifications] are supported!");
                if (!window.webkitNotifications.checkPermission()) {
                    console.log("[notifications] got permission");
                    $.icescrum.o.notifications = true;
                }
                else if(window.webkitNotifications.checkPermission() != 2 && !localStorage['hide_notifications']){
                    $("#notifications").show();
                    $("#accept_notifications").click(function(){
                        window.webkitNotifications.requestPermission(function(){
                            if (window.webkitNotifications.checkPermission() == 0){
                                console.log("[notifications] got permission");
                                $.icescrum.o.notifications = true;
                            }
                            localStorage['hide_notifications'] = true;
                            $("#notifications").remove();
                        });
                    });
                    $("#hide_notifications").click(function(){
                        localStorage['hide_notifications'] = true;
                        $("#notifications").remove();
                    });
                }else{
                    console.log("[notifications] permission refused");
                    $("#notifications").remove();
                }
            }else{
                $("#accept_notifications").remove();
                console.log("Notifications are not supported for this Browser/OS version yet.");
                $.icescrum.o.notifications = false;
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

        addHistory:function(hash) {
            var url = location.hash.replace(/^.*#/, '');
            if (url != hash) {
                $.icescrum.o.openWindow = true;
                location.hash = hash;
            }
        },

        showUpgrade:function(){
            if (this.o.showUpgrade){
                var upgrade = $('#upgrade');
                if (upgrade.length && !localStorage['hide_upgrade']){
                    upgrade.show();
                    upgrade.find('.close').click(function(){
                        upgrade.remove();
                        localStorage['hide_upgrade'] = true;
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
            var update = false;
            if (_.contains(['up','down','right','left'], key)){
                update = $.icescrum.selectableNavigate.apply(this,[event]);
            } else {
                //select All
                $this.find('.ui-selectee').addClass('ui-selected');
                update = true;
            }
            var stop = $this.parent().selectableScroll("option" , "stop");
            if (stop && update){
                stop({target:$this.parent()});
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
                        $this.parent().animate({ scrollTop: ($this.parent().scrollTop() + $new.position().top) }, 250);
                        return true;
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
                    selectable.focus();
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
                    $.icescrum.addToWidgetBar(id);
                }
            }
        },

        onDropToWindow:function(event, ui){
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

        getExport:function(select){
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
        }
    });

    $.fn.changeSelectDate = function(date) {
        var select = $(this);
        var id = select.attr('id');
        var options = $('#' + id + ' option');
        options.removeAttr('selected');
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

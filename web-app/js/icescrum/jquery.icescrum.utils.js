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
 *
 */
(function($) {
    jQuery.extend($.icescrum, {

                displayQuicklook:function(obj){
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
                    $.get($.icescrum.o.baseUrlProduct + 'quickLook?'+type+'='+elem.data('elemid'), function(data){
                        $(document.body).append(data.dialog);
                    });
                },

                loading:function(load) {
                    if (load != undefined && !load) {
                        $("#is-logo").stop(true).css('opacity', 1.0).removeClass().addClass('connected');
                    } else {
                        $("#is-logo").removeClass().addClass('working')
                                .animate({opacity: 1.0}, {duration: 250})
                                .animate({opacity: 0}, {duration: 250})
                                .animate({opacity: 1.0}, {duration: 250, complete:$.icescrum.loading});
                    }
                },
                loadingError:function() {
                    $("#is-logo").stop(true).css('opacity', 1.0).removeClass().addClass('disconnected');
                },

                debug:function(value) {
                    if (value) {
                        this.o.debug = value;
                    } else {
                        return this.o.debug;
                    }
                },

                htmlEncode:function(value) {
                    return $('<div/>').text(value).html();
                },

                htmlDecode:function(value) {
                    return $('<div/>').html(value).text();
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
                    event = jQuery.event.fix(event || window.event);
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

                    $('#window-dialog').dialog('destroy');
                    $(document.body).append(this.o.dialogErrorContent);
                    $('#comments').focus();
                    $('#stackError').val(text);
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
                                    'OK': function() {
                                        jQuery.ajax({
                                                    type:'POST',
                                                    data:jQuery('#window-dialog form:first').serialize(),
                                                    url:$.icescrum.o.baseUrl + 'reportError',
                                                    success:function(data, textStatus) {
                                                        $.icescrum.renderNotice(data.notice.text, data.notice.type);
                                                        $('#window-dialog').dialog('close');
                                                    },
                                                    error:function() {
                                                        $('#window-dialog').dialog('close');
                                                    }
                                                });
                                    }
                                }
                            });
                },

                addHistory:function(hash) {
                    var url = location.hash.replace(/^.*#/, '');
                    if (url != hash) {
                        $.icescrum.o.openWindow = true;
                        location.hash = hash;
                    }
                },

                navigateTo:function(hash) {
                    var url = location.hash.replace(/^.*#/, '');
                    if (url != hash) {
                        location.hash = hash;
                    }
                },

                initHistory:function() {
                    $(window).hashchange(function() {
                        if ($.icescrum.o.openWindow) {
                            $.icescrum.o.openWindow = false;
                        } else {
                            var url = location.hash.replace(/^.*#/, '');
                            if (url != '') {
                                $.icescrum.openWindow(url);
                            } else {
                                if ($.icescrum.o.currentOpenedWindow) {
                                    $.icescrum.closeWindow($.icescrum.o.currentOpenedWindow);
                                }
                            }
                        }
                    });
                },

                updateStartDateDatePicker:function(data) {
                    var date = this.jsonToDate(data.endDate);
                    date.setDate(date.getDate() + 1);
                    date = this.dateLocaleFormat(date);
                    $('#datepicker-startDate').datepicker('option', {minDate:date, defaultDate:date});
                    $('#datepicker-startDate').datepicker('setDate', date);
                },

                updateEndDateDatePicker:function(data, delta) {
                    var date = this.jsonToDate(data.endDate);
                    date.setDate(date.getDate() + 2);
                    var date2 = new Date(date);
                    date2.setDate(date.getDate() + (delta - 1));
                    $('#datepicker-endDate').datepicker('option', {minDate:this.dateLocaleFormat(date), defaultDate:this.dateLocaleFormat(date2)});
                    $('#datepicker-endDate').datepicker('setDate', this.dateLocaleFormat(date2));
                },

                updateFilterTask:function(data, xhr, status, element){
                    if (element.data('active')){
                        $('#menu-filter-task-list').addClass('filter-active');
                    }else {
                        $('#menu-filter-task-list').removeClass('filter-active');
                    }
                    $('#menu-filter-task-navigation-item .content').html('<span class="ico"></span>'+element.text());
                },

                updateHideDoneState:function(show,hide){
                    var filter = jQuery('#menu-filter-task-list .dropmenu-content li.last');
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
                }
            });

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
    };

    $.fn.liveDraggable = function (opts) {
        this.die('hover').live("hover", function() {
            if (!$(this).data("init")) {
                $(this).data("init", true).draggable(opts);
            }
        });
    };

    $.fn.liveDroppable = function (opts) {
        var obj = this.selector;
        $(opts.accept).live('dragstart', function() {
            $(obj).each(function() {
                var drp = $(this);
                if (!drp.data("init")) {
                    drp.data("init", true).droppable(opts);
                }
            });
        });
    };

    $.fn.liveEditable = function (url, opts) {
        $(this).die('hover.editable').live("hover.editable", function() {
            if (!$(this).data("init")) {
                $(this).data("init", true).editable(url, opts);
            }
        });
    };

    String.prototype.formatLine = function(remove) {
        remove = remove ? "" : "<br/>";
        return this.replace(/\r\n/g, remove).replace(/\n/g, remove).replace(/"/g, '\\"');
    };

    $.constbrowser = {

        defaults:{
            'dropmenuleft': 0
        },
        settings:{},

        getDropMenuTopLeft:function() {
            var o = $.constbrowser.getConstBrowser();
            return o.dropmenuleft;
        },

        getConstBrowser:function() {
            var o = $.constbrowser.defaults;
            if ($.browser.msie) {
                if (jQuery.browser.version.substr(0, 1) == "7") {
                    o = $.constbrowser.ie7;
                }
                else if (jQuery.browser.version.substr(0, 1) == "6") {
                    o = $.constbrowser.ie6;
                }
            }
            return o;
        }
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

    $.constbrowser.ie7 = {
        'dropmenuleft': 70
    };

    $.constbrowser.ie6 = {
        'dropmenuleft': 70
    };

    $.fn.togglePanels = function(){
      return this.each(function(){
        $(this).addClass("ui-accordion ui-accordion-icons ui-widget ui-helper-reset")
      .find("h3")
        .addClass("ui-accordion-header ui-helper-reset ui-state-default ui-corner-top ui-corner-bottom")
        .prepend('<span class="ui-icon ui-icon-triangle-1-e"></span>')
        .hover(function() { $(this).toggleClass("ui-state-hover"); })
        .click(function() {
          $(this)
            .toggleClass("ui-accordion-header-active ui-state-active ui-state-default ui-corner-bottom")
            .find("> .ui-icon").toggleClass("ui-icon-triangle-1-e ui-icon-triangle-1-s").end()
            .find("> a > input[type='checkbox']").prop('checked', !$(this).find("> a > input.hidden[type='checkbox']")[0].checked).end()
            .next().slideToggle();
          return false;
        })
        .next()
          .addClass("ui-accordion-content ui-helper-reset ui-widget-content ui-corner-bottom")
          .hide();
      });
    };

})(jQuery);

if (typeof String.prototype.startsWith != 'function') {
  // see below for better implementation!
  String.prototype.startsWith = function (str){
    return this.indexOf(str) == 0;
  };
}

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
    $('textarea'+textarea).show().val($.trim(textile));
    $('textarea'+textarea).parent().animate({scrollTop: $(textarea).offset().top}, 500,'easeInOutCubic');
    container.remove();
    return false;
}

function NotesToHtml(html, textarea){
    var text = $(html).html();
    text = text.replace(/ +(?= )/g,'');
    text = text.replace(/    \*/g, '*');
    text = text.replace(new RegExp('\t', 'g'), '');
    text = text.replace(new RegExp('  ', 'g'), ' ');
    text = text.replace(new RegExp('\\n ', 'g'), '\n');
    text = text.replace(new RegExp('\\n\\n', 'g'), '\n');
    $('h1'+textarea).show();
    $('textarea'+textarea).show().val($.trim(text));
    $('textarea'+textarea).parent().animate({scrollTop: $(textarea).offset().top}, 500,'easeInOutCubic');
    return false;
}

/*
 * Copyright (c) 2014 Kagilum SAS.
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

function getFunction(code, argNames) {
    var fn = window, parts = (code || "").split(".");
    while (fn && parts.length) {
        fn = fn[parts.shift()];
    }
    if (typeof (fn) === "function") {
        return fn;
    }
    argNames.push(code);
    return Function.constructor.apply(null, argNames);
}

(function ($) {

    function isMethodProxySafe(method) {
        return method === "GET" || method === "POST";
    }

    function ajaxOnBeforeSend(xhr, method) {
        xhr.setRequestHeader("X-Requested-With", "XMLHttpRequest");
        if (!isMethodProxySafe(method)) {
            xhr.setRequestHeader("X-HTTP-Method-Override", method);
        }
    }

    function ajaxOnSuccess(element, data, contentType) {
        var mode;
        if (contentType.indexOf("application/x-javascript") !== -1) {  // jQuery already executes JavaScript for us
            return;
        }
        mode = (element.data("ajaxMode") || "").toUpperCase();
        $(element.data("ajaxUpdate")).each(function (i, update) {
            var top;

            switch (mode) {
            case "BEFORE":
                top = update.firstChild;
                $("<div />").html(data).contents().each(function () {
                    update.insertBefore(this, top);
                });
                break;
            case "AFTER":
                $("<div />").html(data).contents().each(function () {
                    update.appendChild(this);
                });
                break;
            default:
                $(update).html(data);
                attachOnDomUpdate($(update));
                break;
            }
        });
    }

    function ajaxRequest(element, options) {
        var confirm, loading, duration;

        confirm = element.data("ajaxConfirm");
        if (confirm){
            confirm = confirm.replace(/\\n/g,"\n");
        }
        if (confirm && !window.confirm(confirm)) {
            return;
        }

        loading = $(element.data("ajaxLoading"));
        duration = element.data("ajaxLoadingDuration") || 0;

        $.extend(options, {
            type: element.data("ajaxMethod") || undefined,
            url: element.data("ajaxUrl") || undefined,
            beforeSend: function (xhr) {
                var result;
                ajaxOnBeforeSend(xhr, options.type);
                result = getFunction(element.data("ajaxBegin"), ["xhr", "element"]).apply(this, [xhr, element]);
                if (result !== false) {
                    loading.show(duration);
                }
                return result;
            },
            complete: function () {
                loading.hide(duration);
                getFunction(element.data("ajaxComplete"), ["xhr", "status"]).apply(this, arguments);
                $('#tiptip_holder').remove();
            },
            success: function (data, status, xhr) {
                ajaxOnSuccess(element, data, xhr.getResponseHeader("Content-Type") || "text/html");
                if (data.dialog){
                    $(document.body).append(data.dialog);
                    attachOnDomUpdate($('.ui-dialog'));
                }else{
                    if (data.dialogSuccess){
                        $(document.body).append(data.dialogSuccess);
                        attachOnDomUpdate($('.ui-dialog'));
                    }
                    if (element.data("ajaxNotice")){
                        $.icescrum.renderNotice(element.data("ajaxNotice"));
                    }
                    if (element.data("ajaxTrigger")){
                        if(typeof element.data("ajaxTrigger") == 'string'){
                            $.event.trigger(element.data("ajaxTrigger"),[data]);
                        }else{
                            $.each( element.data("ajaxTrigger"), function(i, n){
                                $.event.trigger(i,[data[n]]);
                            });
                        }
                    }
                    if (element.data("ajaxSuccess") && element.data("ajaxSuccess").startsWith('#')){
                        document.location.hash = element.data("ajaxSuccess");
                        return
                    }
                    getFunction(element.data("ajaxSuccess"), ["data", "status", "xhr", "element"]).apply(this, [data, status, xhr, element]);
                }
            },
            error: getFunction(element.data("ajaxFailure"), ["xhr", "status", "error"])
        });
        $.ajax(options);
    }

    $(document).bind('keydown.stream','esc', function(e){
        e.preventDefault();
    });

    $(document).on("click", 'a[data-ajax=true]', function (evt) {
        var a = $(this);
        evt.preventDefault();
        ajaxRequest(a, {
            url:  a.attr('href'),
            type: a.attr('method') || ( a.data('ajaxForm') ? 'POST' : 'GET'),
            data: a.data('ajaxForm') ? a.parents('form:first').serialize() : []
        });
    });

    $(document).on("hover", 'div[data-dropmenu=true], li[data-searchmenu=true]', function(){
        var elemt = $(this);
        if(!elemt.data('created')){
            var data = $(this).data();
            data.showOnCreate = true;
            if (data.dropmenu){
                if (!data.left){
                    data.left = $.constbrowser.getDropMenuTopLeft();
                }
                elemt.dropmenu(data);
            } else {
                elemt.searchmenu(data);
            }
            elemt.data('created',true);
        }
    });


    $(document).on('hover','.postit, .postit-rect, .tooltip-help', function(event){
        var elem = $(this);
        var tooltip = $('.tooltip',elem);
        if (tooltip.length > 0){
            var label = elem.find('label:first');
            if (!elem.data('tooltip-init')){
                (label.length > 0 ? label : elem).tipTip({
                    delay:tooltip.data('delay') ? tooltip.data('delay') : 500,
                    activation:tooltip.data('activation') ? tooltip.data('activation') : "focus",
                    defaultPosition:tooltip.data('defaultPosition') ? tooltip.data('defaultPosition') : "right",
                    edgeOffset:tooltip.data('edgeOffset') ? tooltip.data('edgeOffset') : -20,
                    content:tooltip.html()
                });
                elem.data('tooltip-init',true);
            }
            (event.type == 'mouseenter' && !$('#dropmenu').is(':visible')) ? (label.length > 0 ? label : elem).hover().focus() : (label.length > 0 ? label : elem).blur();
        }
    });

    $(document).on('hover','.event-header', function(event){
        var tooltip = $('.tooltip',this);
        var elem = $(this);
        if (tooltip.hasClass('tooltip')){
            if (!elem.data('tooltip-init')){
                elem.tipTip({delay:500, activation:"focus", defaultPosition:"right", content:tooltip.html(), edgeOffset:-20});
                elem.data('tooltip-init',true);
            }
            (event.type == 'mouseenter' && !$('#dropmenu').is(':visible')) ? elem.focus() : elem.blur();
        }
    });

    $(document).on('click','textarea.selectall',function() {
        var $this = $(this);
        $this.select();
        // Work around Chrome's little problem
        $this.mouseup(function() {
            $this.unbind("mouseup");
            return false;
        });
    });

    $(document).on('click','button.save-chart',function(event){
        if ($.browser.msie && parseInt($.browser.version) < 9){
            alert('Browser not supported');
            return;
        }
        var chart = $(this).parent().next();
        $.download($.icescrum.o.baseUrl+'saveImage', {image:chart.toImage(),title:chart.attr('title')});
    });

    $(document).on('change', '.acceptance-test-state-select', function() {
        var $this = $(this);
        var acceptanceTestId = $this.parents('.acceptance-test').data('elemid');
        var url = $this.data('url');
        var postData = {
            "acceptanceTest.state" : $this.val(),
            "acceptanceTest.id": acceptanceTestId
        };
        var success = function(data) {
            if (data.dialogSuccess){
                $(document.body).append(data.dialogSuccess);
                attachOnDomUpdate($('.ui-dialog'));
            }
        };
        $.post(url, postData, success);
    });

    attachOnDomUpdate();

}(jQuery));

function attachOnDomUpdate(content){
    $('[data-sortable=true]', content).each(function(){
        var $this = $(this);
        $this.sortable($this.data());
    });

    $('[data-droppable=true]', content).each(function(){
        var $this = $(this);
        var options = $this.data();
        if ($this.data('drop')){
            options.drop = getFunction(options.drop, ["event","ui"]);
        }
        $this.droppable(options);
    });

    $('[data-accordion=true]', content).each(function() {
        manageAccordion(this);
    });

    var typeHelper = {
        text: {
            getValueFromText: function(textValue) {
                return $.icescrum.htmlDecode(textValue);
            },
            getValueFromInput: function(inputField) {
                return inputField.find('input').val();
            },
            data: function() {
                return function(textValue) {
                    return typeHelper.text.getValueFromText(textValue);
                };
            }
        },
        selectui: {
            getValueFromText: function(textValue) {
                return $.icescrum.htmlDecode(textValue);
            },
            getValueFromInput: function(inputField) {
                return inputField.find('select').children('option:selected').text();
            },
            data: function(field) {
                var selectValuesData = field.data('editable-values').replace(/'/g, '"');
                var selectValues = $.parseJSON(selectValuesData);
                return function (value) {
                    return $.extend(selectValues, {'selected': value});
                };
            }
        },
        textarea: {
            getValueFromText: function(textValue) {
                return $.icescrum.htmlDecode(textValue.replace(/<br[\s\/]?>/gi, '\n'));
            },
            getValueFromInput: function(inputField) {
                return inputField.find('textarea').val();
            },
            data: function() {
                return function (textValue) {
                    return typeHelper.textarea.getValueFromText(textValue);
                };
            }
        },
        richarea: {
            getValueFromText: function(textValue) {
                return textValue;
            },
            getValueFromInput: function(inputField) {
                return inputField.find('textarea').val();
            },
            data: function() {
                return function (textValue) {
                    return typeHelper.richarea.getValueFromText(textValue);
                };
            },
            specificOptions: {
                markitup: textileSettings
            }
        },
        inputselect: {
            getValueFromText: function(textValue) {
                return $.icescrum.htmlDecode(textValue);
            },
            getValueFromInput: function(inputField) {
                return inputField.find('input[type="hidden"]').val();
            },
            data: function() {
                return function(textValue) {
                    return typeHelper.text.getValueFromText(textValue);
                };
            }
        }
    };

    $('[data-editable=true]', content).each(function() {
        var editable = $(this);
        var editableId = editable.data('elemid');
        var editableURL = editable.data('editable-url');
        var editableName = editable.data('editable-name');
        editable.find('.field.editable').each(function() {
            var field = $(this);
            var fieldName = field.attr('name');
            var fieldType = field.data('editable-type');
            var helper = typeHelper[fieldType];
            var options = {
                type: fieldType,
                ajaxoptions: {dataType: 'json'},
                onblur: 'submit',
                name: editableName + '.' + fieldName,
                data: function(textValue) {
                    if (field.data('rawValue')) {
                        textValue = field.data('rawValue');
                    }
                    return helper.data(field)(textValue);
                },
                onedit: function () {
                    field.addClass('editing');
                },
                onsubmit: function (settings, original) {
                    var oldText = field.data('rawValue') ? field.data('rawValue') : original.revert;
                    var oldValue = helper.getValueFromText(oldText);
                    var newValue = helper.getValueFromInput($(original));
                    if (oldValue == newValue) {
                        original.reset();
                        field.removeClass('editing');
                        return false;
                    }
                    return true;
                },
                submitdata: function () {
                    return {
                        'name': fieldName,
                        'table': true,
                        'id': editableId
                    };
                },
                callback: function (value) {
                    if (field.data('rawValue') != undefined) {
                        field.data('rawValue', value.rawValue);
                    }
                    field.html(value.value);
                    field.removeClass('editing');
                    var eventName = 'update_' + editableName;
                    $.event.trigger(eventName, value.object);
                }
            };
            if (helper.specificOptions) {
                $.extend(options, helper.specificOptions);
            }
            field.die().liveEditable(editableURL, options);
        });
    });

    $('textarea.selectallonce',content).one('click', function() {
        $(this).select();
    });

    $('select', content).each(function(){
        var element = $(this);
        var options = jQuery.extend({minimumResultsForSearch: 6}, element.data());
        if (element.data('iconClass')) {
            function format(state) {
                return "<i class='" + element.data('icon-class') + state.id + "'></i>" + state.text;
            }
            options.formatResult = format;
            options.formatSelection = format;
        }
        var select = element.select2(options);
        if ($(this).data('change')){
            select.change(function(event,value){
                getFunction(element.data("change"), ["event", "value"]).apply(this,[event,value]);
            });
        }
    });

    $('input[data-tag="true"]', content).each(function() {
        var element = $(this);
        var url = element.data('url');
        var placeholder = element.data('placeholder');
        var select = element.select2({
            width: "240",
            tags:[],
            placeholder: placeholder,
            tokenSeparators: [",", " "],
            initSelection : function (element, callback) {
                var data = [];
                $(element.val().split(",")).each(function () {
                    data.push({id: this, text: this});
                });
                callback(data);
            },
            createSearchChoice:function (term) {
                return {id:term, text:term};
            },
            ajax: {
                url: url,
                cache: true,
                data: function (term) {
                    return {term: term};
                },
                results: function (data) {
                    var results = [];
                    $(data).each(function(){
                        results.push({id:this,text:this});
                    });
                    return {results:results};
                }
            }
        });
        if (element.data('change')){
            select.change(function(event){
                getFunction(element.data("change"), ["event"]).apply(this,[event]);
            });
        }
    });

    $('a[data-shortcut]', content).each(function(){
        var elem = $(this);
        var onClean = elem.data('shortcutOn') ? elem.data('shortcutOn').replace(/\W/g, '')  : 'body';
        var on = elem.data('shortcutOn') ? elem.data('shortcutOn')  : document.body;
        var bind = 'keydown.'+'.'+onClean+'.'+elem.data('shortcut').replace(/\+/g,'');
        $(on).unbind(bind);
        $(on).bind(bind,elem.data('shortcut'),function(e){
            if (elem.data('callback')){
                if (!getFunction(elem.data("callback"), []).apply(this, [])){
                    e.preventDefault();
                    return;
                }
            }
            if (!elem.attr('href') || elem.data('ajax')){
                elem.click();
            }else if (elem.attr('href')){
                document.location.hash = elem.attr('href');
            }
            e.preventDefault();
        });
    });
    $('.left-resizable[data-resizable], .right-resizable[data-resizable]', content).each(function(){
        var elem = $(this);
        elem.removeAttr('data-resizable');
        var right = elem.hasClass('right-resizable');
        var div = right ? elem.prev() : elem.next();
        var resize = function(){
            var elWidth = elem.width();
            if (right){
                elem.css('left','auto');
            }
            if(elem.find('> div:not(.ui-resizable-handle)').length == 0 && elem.data('emptyHide') == true){
                elem.hide();
                div.css(right ? 'right' : 'left', 0);
            }else if (elWidth <= 7){
                elem.addClass('ui-resizable-hidden');
                elem.width(0);
                elWidth = 0;
                div.css(right ? 'right' : 'left', 7);
                elem.find(".ui-resizable-handle").css(right ? 'left' : 'right', -7).width(7);
            } else if(elWidth > 7) {
                var reconstruct = elem.hasClass('ui-resizable-hidden');
                elem.removeClass('ui-resizable-hidden').show();
                div.css(right ? 'right' : 'left', elem.outerWidth() + 7);
                elem.find(".ui-resizable-handle").css(right ? 'left' : 'right',-7).width(7);
                if (reconstruct){
                    elem.find(".is-widget").each(function(){
                        var el = $(this);
                        el.isWidget(el.data());
                    });
                }
            }
            if (div.width() <= 10){
                div.hide();
            } else {
                div.show();
            }
            if(!elem.data('eventWidth') && elem.data('eventOnWidth') && elWidth > elem.data('eventOnWidth')) {
                elem.data('eventWidth', true);
                elem.trigger('resizable.overWidth');
            } else if(elem.data('eventWidth') && elem.data('eventOnWidth') && elWidth < elem.data('eventOnWidth')) {
                elem.data('eventWidth', false);
                elem.trigger('resizable.notOverWidth');
            }
            $(document.body).trigger('resize');
        };
        var options = {
            handles: right ? 'w' : 'e',
            resize: resize,
            start: function( event, ui ) {
                //hack for chrome / safari with containment
                if (elem.data('containment') == 'parent'){
                    elem.resizable("option", "maxWidth", elem.parent().width() - 1);
                }
            },
            stop:function(){
                elem.css('bottom','0px');
                $(this).css('height','auto');
            }
        };
        options = $.extend(options, elem.data());
        options.containment = null;
        if (right){
            div.css('right', $(this).outerWidth() + 7);
        } else {
            div.css('left', $(this).outerWidth() + 7);
        }
        elem.resizable(options);
        elem.find(".ui-resizable-handle").css(right ? 'left' : 'right',-7);
        elem.find(".ui-resizable-handle").on('dblclick',function(){
            if (elem.width() <= 17){
                elem.css('width', elem.data('widthSaved'));
            } else {
                elem.data('widthSaved', elem.width());
                elem.css('width', 0);
            }
            resize();
        });
        resize();
        elem.bind("manualResize", function(){
            resize();
        });
    });

    $('textarea[data-at]',content).each(function(){
        var elem = $(this);
        elem.atwho(elem.data());
    });

    $.event.trigger('domUpdate.icescrum',content);
}

function manageAccordion(element){
    var $this = $(element);
    $this.accordion($this.data());
    if ($this.data('heightStyle') == 'fill'){
        $(window).on('resize', function() {
            if ($this && $this.hasClass('ui-accordion')) {
                $this.accordion('refresh');
            }
        });
    }
}
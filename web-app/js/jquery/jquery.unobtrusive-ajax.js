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
    if ($.isFunction(code)){
        return code;
    }
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
                            $.icescrum.object.addOrUpdateToArray(i.split('_')[1],[data[n]]);
                        });
                    }
                }
                if (element.data("ajaxSync")){
                    $.icescrum.object.addOrUpdateToArray(element.data("ajaxSync"),data);
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

(function ($) {

    $(document).bind('keydown.stream','esc', function(e){
        e.preventDefault();
    });

    $(document).on("click", 'a[data-ajax]', function (evt) {
        var a = $(this);
        evt.preventDefault();
        ajaxRequest(a, {
            url:  a.attr('href'),
            type: a.attr('method') || ( a.data('ajaxForm') ? 'POST' : 'GET'),
            data: a.data('ajaxForm') ? a.parents('form:first').serialize() : (a.data('ajaxData') ? $.param(a.data('ajaxData'), true) : [])
        });
    });

    $(document).on("hover", 'div[data-dropmenu=true], li[data-searchmenu=true]', function(){
        var elemt = $(this);
        if(!elemt.data('created')){
            var data = $(this).data();
            data.showOnCreate = true;
            if (data.dropmenu){
                if (!data.left){
                    data.left = 0;
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

    $(document).on('resizable.overWidth', '#right', function(){
        $('#contextual-properties').accordion('destroy');
        $('#right').addClass('desktop-view');
    });

    $(document).on('resizable.notOverWidth', '#right', function(){
        $('#right').removeClass('desktop-view');
        manageAccordion($('#contextual-properties'));
    });

    $(document).on('keydown', "div.editable", function(evt) {
        if(evt.keyCode==9) {
            var nextBox='';
            var current = $("div.editable");
            var currentBoxIndex=current.index(this);
            if (evt.shiftKey && currentBoxIndex == 0){
                nextBox=current.last();
            }
            if (!evt.shiftKey && currentBoxIndex == (current.length-1)) {
                nextBox=current.first();
            } else {
                nextBox=evt.shiftKey ? current.eq(currentBoxIndex-1) : current.eq(currentBoxIndex+1);
            }
            $(this).find("input").blur();
            $(nextBox).click();
            return false;
        }
        return true;
    });

    attachOnDomUpdate();

}(jQuery));

function attachOnDomUpdate(content){

    $('div[data-dz]', content).each(function(){
        var $this = $(this);
        if ($this.data('dz-init')){
            return;
        } else {
            $this.data('dz-init', true);
        }
        var settings = $.extend({
                dictCancelUpload:'x',
                dictRemoveFile:'x',
                previewTemplate:'<div class="dz-preview dz-file-preview"><div class="dz-details"><a href="javascript:;" data-dz-href><i class="file-icon"></i><div class="dz-filename"><span data-dz-name></span></div><div class="dz-size" data-dz-size></div></a></div><div class="dz-progress"><span class="dz-upload" data-dz-uploadprogress></span></div><div class="dz-error-message"><span data-dz-errormessage></span></div></div>'
            },
            $this.html5data('dz')
        );
        var afterUpload = function(file){
            var link = file.previewElement.querySelector("[data-dz-href]");
            if (file.provider){
                link.href = settings.url + '?attachment.id=' + file.id;
                link.target = '_blank';
            } else {
                link.href = settings.url + '?attachment.id=' + file.id;
                $(link).on('click', function(){
                    $.download(settings.url, {'attachment.id':file.id}, 'GET');
                    return false;
                });
            }
            var name = file.previewElement.querySelector("[data-dz-name]");
            name.title = file.name;
            $(".dz-details > i", file.previewElement).addClass("format-"+file.ext);
            if (file.size == 0){
                file.previewElement.querySelector("[data-dz-size]").remove();
            }
        };

        var dropZone = new Dropzone('#' + (settings.id ? settings.id : this.id), settings);
        $('<div class="drop-here"><div class="drop-title">Drop your file here</div></div>').appendTo($('#' + (settings.id ? settings.id : $this.attr('id'))));

        if (settings.addRemoveLinks){
            dropZone.on("removedfile", function(file) {
                if(file.id){
                    $.ajax({
                        type:'DELETE',
                        url:settings.url+'?attachment.id='+file.id
                    });
                }
            });
        }
        dropZone.on("success", function(file, data) {
            file.id = data.id;
            file.ext = data.ext;
            file.provider = data.provider;
            afterUpload(file);
        });
        dropZone.on("addedfile", function(file) {
            if (file.id){
                afterUpload(file);
            }
        });
        if (settings.files){
            $(settings.files).each(function(){
                dropZone.options.prepend = false;
                dropZone.emit("addedfile", {name:this.filename, size:this.length, id:this.id, ext:this.ext, provider:this.provider });
                dropZone.options.prepend = true;
            });
        }
    });

    $('textarea[data-mkp]', content).each(function() {
        var $this = $(this);
        if ($this.data('mkp-init')){
            return;
        } else {
            $this.data('mkp-init', true);
        }
        if (!$this.attr('id') && $this.attr('name')){
            $this.attr('id', 'auto_'+$this.attr('name').replace(/\./g,'_'));
        }
        var enabled = $this.attr('readonly') ? false : true;
        var settings = $.extend({
                resizeHandle:false
            },
            textileSettings,
            $this.html5data('mkp')
        );
        var rawValue = $this.val() ? $this.val() : settings.placeholder;
        var markitup = $this.markItUp(settings);
        var editor = markitup.closest('.markItUpContainer');
        var container = markitup.closest('.markItUp');
        var preview = $('<div class="markitup-preview"></div>');
        container.append(preview);

        var updateText = function(rawValue){
            if (rawValue){
                preview.data('rawValue', rawValue);
                $.post($.icescrum.o.baseUrl + 'textileParser', { data: rawValue, withoutHeader: true }, function(data) {
                    preview.html(data);
                }).complete(function(){
                        $this.removeAttr('readonly');
                    });
            }
            editor.addClass('select2-offscreen');
            preview.show();
        };

        updateText(rawValue);

        if(settings.height){
            container.css('height',settings.height);
        }
        if (enabled){

            var display = function(){
                if (editor.hasClass('select2-offscreen')){
                    markitup.val(preview.data('rawValue') != settings.placeholder ? preview.data('rawValue') : '');
                    editor.removeClass('select2-offscreen');
                    preview.hide();
                    if(settings.height){
                        markitup.css('height', settings.height - container.find('.markItUpHeader').height());
                    }
                    markitup.focus();
                }
            }

            preview.on('click',display);
            $this.on('focus',display);

            if (settings.change){
                $this.on('blur keyup', function(event){
                    var data = { };
                    rawValue = $this.val();
                    if (event.type == 'keyup' && event.which == 27){
                        updateText(null);
                    }
                    if (event.type != 'keyup'){
                        if (rawValue != preview.data('rawValue')){
                            var name = $this.attr('name');
                            data[name] = rawValue;
                            $this.attr('readonly','readonly');
                            $.post(settings.change, data, function(data){
                                $.icescrum.object.addOrUpdateToArray(name.split('.')[0],data);
                                $this.removeAttr('readonly');
                            });
                        } else {
                            updateText(null);
                        }
                    }
                });
            }
        }
    });

    $('select[data-sl2]', content).each(function(){
        var $this = $(this);
        if ($this.data('sl2-init')){
            return;
        } else {
            $this.data('sl2-init', true);
        }
        if (!$this.attr('id') && $this.attr('name')){
            $this.attr('id', 'auto_'+$this.attr('name').replace(/\./g,'_'));
        }
        var settings = $this.html5data('sl2');
        if (settings.iconClass) {
            function format(state) {
                return '<i class="' + settings.iconClass + state.id + '"></i>' + state.text;
            }
            settings.formatResult = format;
            settings.formatSelection = format;
        }
        settings = $.extend({
            minimumResultsForSearch: 6
        }, settings);
        if (settings.value) {
            $this.val(settings.value);
        }
        var select = $this.select2(settings);
        $('#s2id_'+$this.attr('id')).find('input:first').attr('data-focusable','s2id_'+$this.attr('id'));
        if (settings.change && !settings.change.startsWith('$')) {
            select.change(function (event) {
                var data = { };
                var name = $this.attr('name');
                data[name] = event.val;
                $.post(settings.change, data, function(data) {
                    $.icescrum.object.addOrUpdateToArray('story',data);
                }, 'json');
            })
        } else if (settings.change && settings.change.startsWith('$')){
            select.change(function(event){
                getFunction(settings.change, ["val"]).apply(this, [event.val]);
            });
        }
    });

    //todo refactor to have one function for 3 sl2
    $('input[data-sl2ajax]', content).each(function() {
        var $this = $(this);
        if ($this.data('sl2ajax-init')){
            return;
        } else {
            $this.data('sl2ajax-init', true);
        }
        if (!$this.attr('id') && $this.attr('name')){
            $this.attr('id', 'auto_'+$this.attr('name').replace(/\./g,'_'));
        }
        var settings = $this.html5data('sl2ajax');
        settings = $.extend({
            createChoiceOnEmpty:false,
            minimumResultsForSearch: 6,
            initSelection : function (element, callback) {
                callback({id: settings.value, text: element.val()});
            },
            ajax: {
                url: settings.url,
                cache: 'true',
                data: function(term) {
                    return { term: term };
                },
                results: function(data) {
                    return { results: data };
                }
            }
        }, settings);
        if (settings.createChoiceOnEmpty) {
            settings.minimumResultsForSearch = 0;
            settings.createSearchChoice = function (term) {
                return {id:term, text:term};
            };
        }
        var select = $this.select2(settings);
        $('#s2id_'+$this.attr('id')).find('input:first').attr('data-focusable','s2id_'+$this.attr('id'));
        if (settings.change && !settings.change.startsWith('$')) {
            select.change(function (event) {
                var data = { };
                var name = $this.attr('name');
                data[name] = event.val;
                $.post(settings.change, data, function(data) {
                    $.icescrum.object.addOrUpdateToArray('story',data);
                }, 'json');
            })
        } else if (settings.change && settings.change.startsWith('$')){
            select.change(function(event){
                getFunction(settings.change, ["val"]).apply(this, [event.val]);
            });
        }
    });

    $('input[data-sl2tag]', content).each(function() {
        var $this = $(this);
        if ($this.data('sl2tag-init')){
            return;
        } else {
            $this.data('sl2tag-init', true);
        }
        if (!$this.attr('id') && $this.attr('name')){
            $this.attr('id', 'auto_'+$this.attr('name').replace(/\./g,'_'));
        }
        var settings = $.extend({
                tags:[],
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
                }
            },
            $this.html5data('sl2tag')
        );
        if (settings.tagLink){
            settings.formatSelection = function(object){
                return '<a href="'+settings.tagLink+object.text+'" onclick="document.location=this.href;">'+object.text+'</a>';
            };
        }
        settings.ajax = {
            url: settings.url,
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
        };
        var select = $this.select2(settings);
        $('#s2id_'+$this.attr('id')).find('input:first').attr('data-focusable','s2id_'+$this.attr('id'));
        if (settings.change && !settings.change.startsWith('$')) {
            select.change(function (event) {
                var data = { };
                var name = $this.attr('name');
                data[name] = $this.val();
                $.post(settings.change, data, function(data) {
                    $.icescrum.object.addOrUpdateToArray('story',data);
                }, 'json');
            })
        } else if (settings.change && settings.change.startsWith('$')){
            select.change(function(event){
                getFunction(settings.change, ["val"]).apply(this, [$this.val()]);
            });
        }
    });

    $('input[data-txt]', content).each(function() {
        var $this = $(this);
        if ($this.data('txt-init')){
            return;
        } else {
            $this.data('txt-init', true);
        }
        $this.data('rawValue', $this.val());
        if (!$this.attr('id') && $this.attr('name')){
            $this.attr('id', 'auto_'+$this.attr('name').replace(/\./g,'_'));
        }
        var settings = $this.html5data('txt');
        var enabled = $this.attr('readonly') ? false : true;

        var changeFunction = function (event) {
            var val = $this.val();
            if (event.type == 'keyup' && event.which == 27){
                $this.val($this.data('rawValue'));
                $this.blur();
                return;
            }
            if (event.type != 'keyup' || (event.type == 'keyup' && event.which == 13)){
                if ((val == '' && $this.attr('required')) || (event.type == 'keypress' && event.which != 13)) {
                    return;
                }
                var data = {};
                var name = $this.attr('name');
                data[name] = val;
                if($this.data('rawValue') != data[name]){
                    $this.attr('readonly');
                    $.post(settings.change, data, function(data) {
                        $.icescrum.object.addOrUpdateToArray(name.split('.')[0],data);
                        $this.removeAttr('readonly');
                        if (settings.onSave){
                            getFunction(settings.onSave, ["data"]).apply(this, [data]);
                        }
                    }, 'json');
                }
            }
        };

        if (enabled && settings.change) {
            $this.on('focus', function(event){
                $this.data('rawValue', $this.val());
            });
            if (settings.onlyReturn){
                $this.on('keyup', null, 'return', changeFunction);
            } else {
                $this.on('blur keyup', changeFunction);
            }
        }
    });

    $('textarea[data-at]',content).each(function(){
        var $this = $(this);
        if ($this.data('at-init')){
            return;
        } else {
            $this.data('at-init', true);
        }
        if (!$this.attr('id') && $this.attr('name')){
            $this.attr('id', 'auto_'+$this.attr('name').replace(/\./g,'_'));
        }
        var settings = $this.html5data('at');
        var rawValue = $this.val() ? $this.val().trim() : settings.placeholder;
        var preview = $('<div class="atwho-preview"></div>');
        preview.insertAfter($this);

        var updateText = function(rawValue){
            if (rawValue){
                preview.data('rawValue', rawValue);
                preview.html(getFunction(settings.matcher, ["val"]).apply(this, [{description:rawValue}]));
                $this.removeAttr('readonly');
            }
            $this.addClass('select2-offscreen');
            preview.show();
        };

        updateText(rawValue);

        var display = function(){
            if ($this.hasClass('select2-offscreen')){
                $this.atwho(settings);
                var val = '';
                if (preview.data('rawValue') != settings.placeholder) {
                    val = preview.data('rawValue');
                } else if (settings['default']) {
                    val = settings['default'].replace(/\\n/g,"\n"); // hack required because templates remove regular /n
                    $this.one('click focus', function(){
                        $this.select();
                        $this.off('click focus');
                    });
                }
                $this.val(val);
                $this.removeClass('select2-offscreen');
                preview.hide();
                $this.focus();
            }
        }

        $this.on('focus', display);
        preview.on('click', display);

        if (settings.change){
            $this.on('blur keyup', function(event){
                if (event.type == 'keyup' && event.which == 27){
                    updateText(null);
                } else if (event.type != 'keyup'){
                    if ($this.val() != preview.data('rawValue')){
                        var name = $this.attr('name');
                        var data = { };
                        data[name] = $this.val();
                        $this.attr('readonly','readonly');
                        $.post(settings.change, data, function(data){
                            $.icescrum.object.addOrUpdateToArray(name.split('.')[0],data);
                            $this.removeAttr('readonly');
                        });
                    } else {
                        updateText(null);
                    }
                }
            });
        }
    });

    $('textarea.selectallonce',content).one('click focus', function(){
        $(this).select();
        $(this).off('click focus');
    });

    //TODO remove
    $('div[data-push]', content).each(function(){
        var $this = $(this);
        if ($this.data('push-init')){
            return;
        } else {
            $this.data('push-init', true);
        }
        var settings = $this.html5data('push');
        $(settings.listen).each(function(){
            var that = this;
            var _object = that.object;
            var _event = "";
            $(this.events).each(function(){
                _event += this+'_'+_object+'.stream '
            });
            $this.on(_event, function(event,object){
                var type = event.type.split('_')[0];
                if (that.template){
                    $.icescrum[_object][type].apply(object,[that.template]);
                } else {
                    $.icescrum[_object][type].apply(object);
                }
            });
        });
    });

    $('div[data-ui-selectable]', content).each(function(){

        var $this = $(this);
        if ($this.data('ui-selectable-init')){
            return;
        } else {
            $this.data('ui-selectable-init', true);
        }

        var settings = $this.html5data('ui-selectable');
        $.each(['selected','create','selecting','start','stop','unselected','unselecting'], function(){
            var _func = settings[this] ? getFunction(settings[this], ["event","ui"]) : null;
            if (this == 'stop' && settings.globalStop){
                settings[this] = function(event, ui){
                    if($.icescrum.selectableStop(event, ui)){
                        _func ? _func(event, ui) : null;
                    }
                };
            } else if(_func) {
                settings[this] = _func;
            }
        });
        $this.parent().selectableScroll(settings);
    });

    $('div[data-binding], ul[data-binding]', content).each(function(){
        var $this = $(this);
        if ($this.data('binding-init')){
            return;
        } else {
            $this.data('binding-init', true);
        }
        var settings = $this.html5data('binding');

        if (settings.afterBinding){
            settings.afterBinding = getFunction(settings.afterBinding, ["settings"]);
        }

        $.icescrum.object.dataBinding.apply(this,[settings]);
    });

    $('div[data-ui-tabs]', content).each(function(){
        var $this = $(this);
        if ($this.data('ui-tabs-init')){
            return;
        } else {
            $this.data('ui-tabs-init', true);
        }
        var settings = $this.html5data('ui-tabs');
        $.each(['selected','create','selecting','start','stop','unselected','unselecting'], function(){
            if (settings[this]){
                settings[this] = getFunction(settings[this], ["event","ui"]);
            }
        });
        $this.tabs(settings);
    });

    $('input[type=submit][data-ui-button], a[data-ui-button], button[data-ui-button]', content).each(function(){
        var $this = $(this);
        if ($this.data('ui-button-init')){
            return;
        } else {
            $this.data('ui-button-init', true);
        }
        var settings = $this.html5data('ui-button');
        $.each(['create'], function(){
            if (settings[this]){
                settings[this] = getFunction(settings[this], ["event","ui"]);
            }
        });
        $this.button(settings);
    });

    $('div[data-ui-buttonset]', content).each(function(){
        var $this = $(this);
        if ($this.data('ui-buttonset-init')){
            return;
        } else {
            $this.data('ui-buttonset-init', true);
        }
        var settings = $this.html5data('ui-buttonset');
        $.each(['create'], function(){
            if (settings[this]){
                settings[this] = getFunction(settings[this], ["event","ui"]);
            }
        });
        $this.buttonset(settings);
    });

    $('[data-ui-droppable]', content).each(function(){
        var $this = $(this);
        if ($this.data('ui-droppable-init')){
            return;
        } else {
            $this.data('ui-droppable-init', true);
        }
        var settings = $this.html5data('ui-droppable');
        $.each(['activate','create','deactivate','drop','out','over'], function(){
            if (settings[this]){
                settings[this] = getFunction(settings[this], ["event","ui"]);
            }
        });
        //to prevent unused actions & loose perf
        $(document).one('hover', settings.accept, function() {
            //take parent() when selectable due to selectableScroll
            var $droppable = settings.selector ? $(settings.selector) : ($this.data('ui-selectable') != undefined ? $this.parent() : $this);
            if (!$droppable.data('drop-init')){
                $droppable.droppable(settings);
                !$droppable.data('drop-init', true);
            }
        });
    });

    $('[data-ui-droppable2]', content).each(function(){
        var $this = $(this);
        if ($this.data('ui-droppable2-init')){
            return;
        } else {
            $this.data('ui-droppable2-init', true);
        }
        var settings = $this.html5data('ui-droppable2');
        $.each(['activate','create','deactivate','drop','out','over'], function(){
            if (settings[this]){
                settings[this] = getFunction(settings[this], ["event","ui"]);
            }
        });
        //to prevent unused actions & loose perf
        $(document).one('hover', settings.accept, function() {
            //take parent() when selectable due to selectableScroll
            var $droppable = settings.selector ? $(settings.selector) : ($this.data('ui-selectable') != undefined ? $this.parent() : $this);
            if (!$droppable.data('drop-init')){
                $droppable.droppable(settings);
                !$droppable.data('drop-init', true);
            }
        });
    });

    $('[data-ui-draggable]', content).each(function(){
        var $this = $(this);
        if ($this.data('ui-draggable-init')){
            return;
        } else {
            $this.data('ui-draggable-init', true);
        }
        var settings = $this.html5data('ui-draggable');
        //to prevent unused actions & loose perf
        var draggable = settings.selector ? settings.selector : $this;
        $.each(['create','drag','start','stop'], function(){
            if (settings[this] && !_.isFunction(settings[this])){
                settings[this] = getFunction(settings[this], ["event","ui"]);
            }
        });
        $(document).on('hover', draggable, function() {
            var $this = $(this);
            if (!$this.data('drag-init')){
                $this.draggable(settings);
                !$this.data('drag-init', true);
            }
        });
    });

    $('[data-ui-sortable]', content).each(function(){
        var $this = $(this);
        if ($this.data('ui-sortable-init')){
            return;
        } else {
            $this.data('ui-sortable-init', true);
        }
        var settings = $this.html5data('ui-sortable');
        $.each(['update','receive','start','stop','activate','beforeStop','change','create','deactivate','out','over','remove','sort'], function(){
            if (settings[this]){
                settings[this] = getFunction(settings[this], ["event","ui"]);
            }
        });
        $this.sortable(settings);
    });

    $('[data-ui-resizable-panel]', content).each(function(){
        var margin = 7;
        var $this = $(this);
        if ($this.data('ui-resizable-panel-init')){
            return;
        } else {
            $this.data('ui-resizable-panel-init', true);
        }
        var settings = $this.html5data('ui-resizable-panel');
        settings.miniWidth = settings.miniWidth ? settings.miniWidth : 0;
        var div = settings.right ? $this.prev() : $this.next();
        var resize = function(){
            var elWidth = $this.width();
            if (settings.right){
                $this.css('left','auto');
            }
            if($this.find('> div:not(.ui-resizable-handle)').length == 0 && settings.emptyHide == true){
                $this.hide();
                div.css(settings.right ? 'right' : 'left', 0);
            }else if (elWidth <= settings.miniWidth){
                $this.addClass('ui-resizable-hidden');
                $this.width(settings.miniWidth);
                elWidth = 0;
                div.css(settings.right ? 'right' : 'left', margin + settings.miniWidth);
                $this.find(".ui-resizable-handle").css(settings.right ? 'left' : 'right', -margin).width(margin);
            } else if(elWidth > margin) {
                var reconstruct = $this.hasClass('ui-resizable-hidden');
                $this.removeClass('ui-resizable-hidden').show();
                div.css(settings.right ? 'right' : 'left', $this.outerWidth() + margin);
                $this.find(".ui-resizable-handle").css(settings.right ? 'left' : 'right',-margin).width(margin);
                if (reconstruct){
                    $this.find(".is-widget").each(function(){
                        var el = $(this);
                        el.resizable( "destroy" );
                        el.isWidget(el.html5data('is'));
                    });
                }
            }
            if (div.width() <= 10){
                div.hide();
            } else {
                div.show();
            }
            if(!settings.eventWidth && settings.eventOnWidth && elWidth > settings.eventOnWidth) {
                settings.eventWidth = true;
                $this.trigger('resizable.overWidth');
            } else if(settings.eventWidth && settings.eventOnWidth && elWidth < settings.eventOnWidth) {
                settings.eventWidth = false;
                $this.trigger('resizable.notOverWidth');
            }
            $(document.body).trigger('resize');
        };

        if (settings.right){
            div.css('right', $this.outerWidth() + margin);
        } else {
            div.css('left', $this.outerWidth() + margin);
        }
        settings._containment = settings.containment == 'parent' ? 'hack' : null;
        settings.containment = settings.containment == 'parent' ? null : settings.containment;
        var options = {
            handles: settings.right ? 'w' : 'e',
            resize: resize,
            start: function( event, ui ) {
                //hack for chrome / safari with containment
                if (settings._containment == 'hack' && settings.containment == null){
                    $this.resizable("option", "maxWidth", $this.parent().width() - 1);
                }
            },
            stop:function(){
                $this.css('bottom','0px');
                $(this).css('height','auto');
            }
        };
        //settings.containment = 'null';
        var _settings = $.extend(options, settings);
        $this.resizable(_settings);
        $this.find(".ui-resizable-handle").css(settings.right ? 'left' : 'right',-margin);
        $this.find(".ui-resizable-handle").on('dblclick',function(){
            if ($this.width() <= settings.miniWidth){
                $this.css('width', settings.widthSaved);
            } else {
                settings.widthSaved = $this.width();
                $this.css('width', settings.miniWidth);
            }
            resize();
        });
        resize();
        $this.bind("manualResize", function(){
            resize();
        });
    });

    $('[data-ui-accordion]', content).each(function() {
        manageAccordion(this);
    });

    $('[data-is-shortcut]', content).each(function(){
        var $this = $(this);
        if ($this.data('is-shortcut-init')){
            return;
        } else {
            $this.data('is-shortcut-init', true);
        }
        var settings = $this.html5data('is-shortcut');
        settings.key = settings.key.replace('arrows','up down right left');
        $(settings.key.split(' ')).each(function(){
            var key = this.toString();
            var onClean = settings.on ? (settings.on == 'this' ? $this.attr('id').replace(/\W/g, '') : settings.on.replace(/\W/g, ''))  : 'body';
            var on = settings.on ? (settings.on == 'this' ? $this : settings.on)  : document.body;
            var bind = 'keydown'+'.'+onClean+'.'+key.replace(/\+/g,'');
            $(on).unbind(bind);
            $(on).bind(bind,key,function(e){
                if (settings.callback){
                    if (!getFunction(settings.callback, ['event']).apply($this, [e])){
                        e.preventDefault();
                        return;
                    }
                }
                if (!$this.attr('href') || $this.data('ajax') != undefined){
                    $this.click();
                }else if ($this.attr('href')){
                    document.location.hash = $this.attr('href');
                }
                e.preventDefault();
            });
        });
    });

    $.event.trigger('domUpdate.icescrum',content);
}

function manageAccordion(element){
    var $this = $(element);
    if ($this.hasClass("ui-accordion")){
        $this.accordion( "option", "animate", false );
        $this.accordion('refresh');
        $this.accordion( "option", "animate", {} );
    } else {
        var settings = $this.html5data('ui-accordion');
        $.each(['create','beforeActivate','activate'], function(){
            if (settings[this]){
                settings[this] = getFunction(settings[this], ["event","ui"]);
            }
        });
        $this.accordion(settings);
        if (settings.heightStyle == 'fill'){
            $(window).on('resize', function() {
                if ($this && $this.hasClass('ui-accordion')) {
                    $this.accordion('refresh');
                }
            });
        }
    }
}
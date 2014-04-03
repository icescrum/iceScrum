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


var isTouchDevice = 'ontouchstart' in document.documentElement;

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

    var loadingButton = element.is('form') && element.find('button.btn[type=submit]') ? element.find('button.btn[type=submit]') : element.hasClass('btn') ? element : element.parent().is('li') ? element.closest('.btn-group').find('.btn') : false;

    $.extend(options, {
        type: element.data("ajaxMethod") || undefined,
        url: element.data("ajaxUrl") || undefined,
        beforeSend: function (xhr) {
            var result;
            ajaxOnBeforeSend(xhr, options.type);
            result = getFunction(element.data("ajaxBegin"), ["xhr", "element"]).apply(this, [xhr, element]);
            if (result !== false && loadingButton) {
                loadingButton.button('loading');
            }
            return result;
        },
        complete: function () {
            if(loadingButton){
                loadingButton.button('reset');
            }
            getFunction(element.data("ajaxComplete"), ["xhr", "status"]).apply(this, arguments);
        },
        success: function (data, status, xhr) {
            ajaxOnSuccess(element, data, xhr.getResponseHeader("Content-Type") || "text/html");
            if (data.dialog){
                $.icescrum.addModal(data.dialog);
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
                var result = getFunction(element.data("ajaxSuccess"), ["data", "status", "xhr", "element"]).apply(this, [data, status, xhr, element]);
                var $modal = element.parents('.modal');
                if($modal.length > 0 && result){
                    $modal.modal('hide');
                }
            }
        },
        error: element.data("ajaxFailure") ? getFunction(element.data("ajaxFailure"), ["xhr", "status", "error"]) : undefined
    });
    $.ajax(options);
}

(function ($) {

    //fix modal force focus
    $.fn.modal.Constructor.prototype.enforceFocus = function () {
        var that = this;
        $(document).on('focusin.modal', function (e) {
            if ($(e.target).hasClass('select2-input')) {
                return true;
            }

            if (that.$element[0] !== e.target && !that.$element.has(e.target).length) {
                that.$element.focus();
            }
        });
    };

    $(window).on('resize', function(){
        $.icescrum.checkBars();
        $.doTimeout('resize', 150, function(){
            _.each($('.chart-container'), function(chart){
                $(chart).trigger('replot');
            });
            $('.fixed').each(function(){
                $(this).trigger('manual-scroll');
            })
        });
    }).trigger('resize');

    $(document).on('click', function (e) {
        $('[data-toggle="popover"]').each(function () {
            if (!$(this).is(e.target) && $(this).has(e.target).length === 0 && $('.popover').has(e.target).length === 0) {
                $(this).popover('hide');
            }
        });
    });

    $(document).bind('keydown.stream','esc', function(e){
        e.preventDefault();
    });

    $(document).on("click", 'a[data-ajax], button[data-ajax]', function (evt) {
        var a = $(this);
        evt.preventDefault();
        evt.stopPropagation();
        ajaxRequest(a, {
            url:  a.data('ajaxForm') ? a.parents('form:first').attr('action') : a.attr('href'),
            type: a.attr('method') || ( a.data('ajaxForm') ? 'POST' : 'GET'),
            data: a.data('ajaxForm') ? a.parents('form:first').serialize() : (a.data('ajaxData') ? $.param(a.data('ajaxData'), true) : [])
        });
        return false;
    });

    $(document).on("submit", 'form[data-ajax]', function (evt) {
        var a = $(this);
        var $error = a.find('.alert.alert-danger');
        evt.preventDefault();
        evt.stopPropagation();
        $error.hide();
        ajaxRequest(a, {
            url:  a.attr('action'),
            type: a.attr('method'),
            data: a.serialize(),
            container:a
        });
        return false;
    });

    //TODO REMOVE
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

    $(document).on('click','textarea.selectall',function() {
        var $this = $(this);
        $this.select();
        // Work around Chrome's little problem
        $this.mouseup(function() {
            $this.unbind("mouseup");
            return false;
        });
    });

    $(document).on('click','button.save-chart',function(){
        var $chart = $('.modal-xxl .chart-container');
        $.download($.icescrum.o.baseUrl+'saveImage', {image:$chart.toImage(),title:$chart.attr('title')});
    });

    $(document).on('click', 'a.edit-comment', function(){
        var $this = $(this);
        $.icescrum.comment.edit($this.data());
        return false;
    });

    //todo remove ?
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

    //todo remove ?
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

    if (!isTouchDevice){

        $(document).on('hover','[data-toggle="tooltip"]', function(){
            var $this = $(this);
            if ($this.data('init-ui-tooltip')){
                return;
            } else {
                $this.data('init-ui-tooltip', true);
            }
            var settings = $.extend({},$this.html5data('ui-tooltip'));
            $.each(['show.bs.tooltip','shown.bs.tooltip','hide.bs.tooltip','hidden.bs.tooltip'], function(){
                if (settings[this.replace(/\./g,'')]){
                    settings[this] = getFunction(this.replace(/\./g,''), ["e"]);
                }
            });

            $this.on('show.bs.tooltip', function(){
                if ($(document.body).hasClass('dragging')){
                    return false;
                }
            });

            $this.tooltip(settings).tooltip('show');
        });

        $(document).on('hover','[data-ui-popover]',function(){
            var $this = $(this);
            if ($this.data('init-ui-popover')){
                return;
            } else {
                $this.data('init-ui-popover', true);
            }
            var settings = $.extend({},$this.html5data('ui-popover'));
            if (settings.htmlContent || settings.htmlTitle){
                settings.html = true;
                settings.container = 'body';
                settings.content = settings.htmlContent ? function(){
                    return $(settings.htmlContent).html()
                } : null;
                settings.title = settings.htmlTitle ? function(){
                    return $(settings.htmlTitle).html()
                } : null;
            }
            if (settings.id || settings['class']){
                settings.template = '<div id="'+settings.id+'" class="popover '+settings['class']+'"><div class="arrow"></div><div class="popover-inner"><h3 class="popover-title"></h3><div class="popover-content"><p></p></div></div></div>';
            }
            $.each(['show.bs.popover','shown.bs.popover','hide.bs.popover','hidden.bs.popover'], function(){
                if (settings[this.replace(/\./g,'')]){
                    settings[this] = getFunction(this.replace(/\./g,''), ["e"]);
                }
            });

            var show = settings.trigger == 'hover' ||  settings.trigger == 'keep-hover';
            if (settings.trigger == 'keep-hover'){
                $this.on("mouseenter", function () {
                    if (settings.delay){
                        $.doTimeout('showpopover',settings.delay, function(){
                            $this.popover("show");
                        }, true);
                    } else {
                        $this.popover("show");
                    }
                    $(".popover").on("mouseleave", function () {
                        if (settings.delay){
                            $.doTimeout('showpopover');
                        }
                        $this.popover('hide');
                    });
                }).on("mouseleave", function () {
                    if (settings.delay){
                        $.doTimeout('showpopover');
                    }
                    setTimeout(function () {
                        if (!$(".popover:hover").length) {
                            $this.popover("hide")
                        }
                    }, 100);
                });
                settings.trigger = 'manual';
            }

            $this.on('show.bs.popover', function(){
                if ($(document.body).hasClass('dragging')){
                    return false;
                }
                $('.popover-open').not(this).popover('hide');
                $(this).addClass('popover-open');
            });

            $this.on('hide.bs.popover', function(){
                $(this).removeClass('popover-open');
            });

            $this.popover(settings);

            if (show){
                if(settings.trigger == 'manual' && settings.delay){
                    $.doTimeout('showpopover',settings.delay, function(){
                        $this.popover("show");
                    }, true);
                } else {
                    $this.popover('show');
                }
            }
        });

    } else {

        $(window).on('load', function() {
            FastClick.attach(document.body);
        });

        $(document).on("touchmove", function (evt){
            evt.preventDefault();
        });

        $('body').swipe( {
            swipeRight:function(event, direction, distance, duration, fingerCount) {
                $.icescrum.toggleSidebar();
            },
            swipeLeft:function(event, direction, distance, duration, fingerCount) {
                if ($(document.body).hasClass('left-open')){
                    $.icescrum.toggleSidebar();
                }
            },
            threshold:50
        });
    }

    attachOnDomUpdate();

}(jQuery));

function attachOnDomUpdate(content){

    //clean popover & tooltip
    $('div.tooltip:visible').hide();
    $('div.popover:visible').hide();

    if (isTouchDevice){
        $('.scrollable', content).each(function(){
            var $container = $(this);
            $container.on('touchstart', function(e){
                var event = e.originalEvent;
                this.allowUp = (this.scrollTop > 0);
                this.allowDown = (this.scrollTop < this.scrollHeight - document.body.clientHeight);
                this.slideBeginY = event.pageY;
            });

            $container.on('touchmove', function(e){
                var event = e.originalEvent;
                var up = (event.pageY > this.slideBeginY);
                var down = (event.pageY < this.slideBeginY);
                this.slideBeginY = event.pageY;
                if ((up && this.allowUp) || (down && this.allowDown) && !$(document.body).hasClass('left-open'))
                    e.stopPropagation();
                else
                    e.preventDefault();
            });
        });
    }

    $('[data-ui-chart-default]', content).each(function(){
        var settings = $(this).html5data('ui-chart');
        if (settings.cookie){
            $.icescrum.displayChartFromCookie(settings.container,settings['default']);
        } else {
            $.icescrum.displayChart(settings.container,settings['default']);
        }
    });

    $('button[data-scrollto]', content).each(function(){
        var $this = $(this);
        var settings = $.extend({ offset:10 } , $this.html5data('scrollto'));

        if ($this.data('init-data-scrollTo')){
            return;
        } else {
            $this.data('init-data-scrollTo', true);
        }
        $this.on('click', function(){
            var $container = settings.container ? $(settings.container) : $(document.body);
            var $scrollTo = settings.tabs ? $('.tab-content > #'+settings.id, $container) : $('#'+settings.id);
            if (settings.tabs){
                $('a[href=#'+settings.id+']', $container).tab('show');
            }
            $container.animate({ scrollTop: $scrollTo.offset().top - $container.offset().top + $container.scrollTop() - settings.offset});
        });
    });

    $('[data-status-toggle]', content).each(function(){
        var $this = $(this);
        var settings = $this.html5data('status');

        if ($this.data('init-data-status')){
            return;
        } else {
            $this.data('init-data-status', true);
        }
        var updateFunction = function(event, status) {
            $.ajax({
                url:$this.attr('href'),
                data:{ status: status ? 'true' : null },
                method:status ? 'GET' : 'POST',
                success:function(data) {
                    if (data.status){
                        $this.find(':first-child').removeClass(settings.toggle+'-o'+(settings.suffix ? '-'+settings.suffix : '')).addClass(settings.toggle+(settings.suffix ? '-'+settings.suffix : ''));
                    } else {
                        $this.find(':first-child').removeClass(settings.toggle+(settings.suffix ? '-'+settings.suffix : '')).addClass(settings.toggle+'-o'+(settings.suffix ? '-'+settings.suffix : ''))
                    }
                    if (settings.title){
                        $this.attr('title', data[settings.title]);
                    }
                    if ($this.data('bs.tooltip')){
                        $this.tooltip('hide');
                        $this.tooltip('destroy');
                    }
                    $this.tooltip({container:'body', title:data[settings.title]});
                    if (!status){
                        $this.tooltip('show');
                    }
                }
            });
            return false;
        };

        updateFunction(null, true);
        $this.on('click', updateFunction);
    });

    $('[data-ui-toggle]', content).each(function(){
        var $this = $(this);
        var settings = $this.html5data('ui');
        var buttonIcon = $this.find('.glyphicon');
        $this.on('click', function(){
            var $content = $('#'+settings.toggle);
            if ($content.hasClass('hidden')){
                $content.toggleClass('hidden');
            } else {
                $content.toggle();
            }
            buttonIcon.toggleClass('glyphicon-minus');
            buttonIcon.toggleClass('glyphicon-plus');
            return false;
        });
    });

    $('time.timeago', content).timeago();

    $('div[data-ui-progressbar]', content).each(function(){

        var $this = $(this);
        if ($this.data('init-ui-progressbar')){
            return;
        } else {
            $this.data('init-ui-progressbar', true);
        }
        var settings = $.extend({},$this.html5data('ui-progressbar'));
        $.each(['complete'], function(){
            if (settings[this]){
                settings[this] = getFunction(settings[this], ["event"]);
            }
        });
        if (settings.getProgress && settings.download){
            $.download(settings.download,{});
        }

        if (settings.getProgress){
            var _continue = true;
            $this.doTimeout('progress', 1000, function(){
                $.get(settings.getProgress, function(data){
                    if(data.complete || data.error){
                        $this.css("width", "100%");
                        $this.attr("aria-valuenow", 100);
                        if (data.error){
                            $this.addClass('progress-bar-danger');
                        }
                        _continue = false;
                    } else if (!data.complete && !data.error){
                        $this.css("width", data.value+'%');
                        $this.attr("aria-valuenow", 100);
                    }
                    $this.html(data.label);
                });

                if(!$this.is(':visible')){
                    _continue = false;
                }

                return _continue;
            });
        }
    });

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
                previewTemplate:'<div class="dz-preview dz-file-preview"><span class="td"><a href="javascript:;" data-dz-href><span class="dz-filename" data-dz-name></span>&nbsp;-&nbsp;<span class="dz-size" data-dz-size></span></a><span class="dz-progress"><span class="progress"><span class="progress-bar" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100" data-dz-uploadprogress></span></span></span></span></div>'
            },
            $this.html5data('dz')
        );
        var templating = function(file){
            if ($(file.previewElement).is('div')){
                var $tr = $('<tr class="dz-preview dz-file-preview"></tr>');
                $(file.previewElement).find('a.dz-remove').wrap('<td></td>').parent().appendTo($tr);
                $($('<td></td>').append($(file.previewElement).find('span.td').html())).prependTo($tr);
                $tr = $(file.previewElement).replaceWithPush($tr);
                file.previewElement = $tr[0];
            }
            var link = file.previewElement.querySelector("[data-dz-href]");
            if(link){
                if (file.provider){
                    link.href = settings.url + '/' + file.id;
                    link.target = '_blank';
                } else {
                    link.href = settings.url + '/' + file.id;
                    $(link).on('click', function(){
                        $.download(link, {}, 'GET');
                        return false;
                    });
                }
            }
            var removeLink = file.previewElement.querySelector("a.dz-remove");
            if (removeLink){
                $(removeLink).addClass('delete on-hover pull-right').html('<span class="fa fa-times text-danger"></span>');
            }

            var name = file.previewElement.querySelector("[data-dz-name]");
            if (name){
                name.title = file.name + ' - ' + file.previewElement.querySelector("[data-dz-size]").textContent;
            }
            $(".dz-details > i", file.previewElement).addClass("format-"+file.ext);
            if (file.size == 0){
                file.previewElement.querySelector("[data-dz-size]").remove();
            }
            if (file.id){
                file.previewElement.querySelector("span.dz-progress").remove();
            }
        };

        var listeners = [];
        $.each(['addedfile','removedfile','selectedfiles','thumbnail','error','processing','uploadprogress','sending','success','complete','canceled','maxfilesreached','maxfilesexceeded'], function(){
            delete settings[this];
            //todo do something with listeners
            listeners[this] = getFunction(settings[this], ["file"]);
        });

        var dropZone = new Dropzone('#' + (settings.id ? settings.id : this.id), settings);

        $('<div class="drop-here"><div class="drop-title"><h3>Drop here</h3></div></div>').appendTo($('#' + (settings.id ? settings.id : $this.attr('id'))));

        if (settings.addRemoveLinks){
            dropZone.on("removedfile", function(file) {
                if(file.id){
                    $.ajax({
                        type:'DELETE',
                        url:settings.url+'/'+file.id
                    });
                }
            });
        }

        dropZone.on("success", function(file, data) {
            file.id = data.id;
            file.ext = data.ext;
            file.provider = data.provider;
        });

        dropZone.on("complete", function(file, data) {
            templating(file);
        });

        dropZone.on("addedfile", function(file, data) {
            templating(file);
        });

        dropZone.on("processing", function(file, data) {
            templating(file);
        });

        if (settings.files){
            $(settings.files).each(function(){
                dropZone.options.prepend = false;
                dropZone.emit("addedfile", {name:this.filename, size:this.length, id:this.id, ext:this.ext, provider:this.provider});
                dropZone.options.prepend = true;
            });
        }

    });

    $('textarea[data-mkp="true"]', content).each(function() {
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
                resizeHandle:false,
                scrollContainer:'#right'
            },
            textileSettings,
            $this.html5data('mkp')
        );

        var $preview = $this.parent().find('.markitup-preview');
        if ($preview.size() == 0){
            $preview = $('<div class="markitup-preview" style="display:none;"></div>');
            $preview.insertAfter($this);
        }
        var $footer = $this.parent().find('.markItUpFooter');
        var rawValue = $this.val() ? $this.val() : '';
        var $markitup = $this.markItUp(settings);
        var $editor = $markitup.closest('.markItUpContainer');
        var $container = $markitup.closest('.markItUp');

        if ($footer.size() > 0){
            $footer = $('.markItUpFooter', $editor).replaceWithPush($footer);
        } else {
            $footer = $('.markItUpFooter', $editor);
        }
        $container.append($preview);
        $preview.data('rawValue', rawValue);

        var displayPreview = function(){
            $editor.addClass('select2-offscreen');
            if ($preview.html() == '' || $preview.html() == $this.attr('placeholder')){
                $preview.addClass('placeholder');
                $preview.html($this.attr('placeholder'));
            } else {
                $preview.removeClass('placeholder');
            }
            $preview.show();
        };
        displayPreview();

        $this.on('hide.mkp', function(){
            displayPreview();
        });

        if(settings.height){
            $container.css('height',settings.height);
        }
        if (enabled){
            var display = function(){
                if ($editor.hasClass('select2-offscreen')){
                    $markitup.val($preview.data('rawValue') != '' ? $preview.data('rawValue') : '');
                    $editor.removeClass('select2-offscreen');
                    $preview.hide();
                    if(settings.height){
                        $markitup.css('height', settings.height - $container.find('.markItUpHeader').height());
                    }
                    $markitup.focus();
                    var $scrollContainer = $(settings.scrollContainer);
                    $scrollContainer.animate({ scrollTop: $footer.offset().top - $scrollContainer.offset().top + $scrollContainer.scrollTop()});
                }
            };
            $preview.on('click',display);
            $this.on('focus',display);
            if (settings.change){
                $this.on('blur keyup', function(event){
                    var data = { };
                    rawValue = $this.val();
                    if (event.type == 'keyup' && event.which == 27){
                        $this.trigger('cancel.mkp');
                        displayPreview();
                    }
                    if (event.type != 'keyup'){
                        if ($editor.find('.dropdown-menu:visible').size() == 1){
                            return;
                        }
                        if (rawValue != $preview.data('rawValue')){
                            var name = $this.attr('name');
                            data[name] = rawValue;
                            $this.attr('readonly','readonly');
                            $.post(settings.change, data, function(data){
                                $.icescrum.object.addOrUpdateToArray(name.split('.')[0],data);
                            }).fail(function(){
                                $this.val($preview.data('rawValue'));
                                displayPreview();
                            }).always(function(){
                                $this.prop('readonly', false);
                            });
                        } else {
                            displayPreview();
                        }
                    }
                });
            } else {
                $this.on('keyup', function(event) {
                    if (event.type == 'keyup' && event.which == 27) {
                        $this.trigger('cancel.mkp');
                        $this.val('');
                        displayPreview();
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
        //override when iconClass
        $.each(['formatResult', 'formatSelection'], function(){
            if (settings[this]){
                settings[this] = getFunction(settings[this], ["object","container"]);
            }
        });
        var select = $this.select2(settings);
        var container = $('#s2id_'+$this.attr('id'));
        container.find('input:first').attr('data-focusable','s2id_'+$this.attr('id'));
        container.find('> a').addClass('form-control');
        if (settings.change && !settings.change.startsWith('$')) {
            $this.data('rawValue',$this.select2('val'));
            select.change(function (event) {
                var data = { };
                var name = $this.attr('name');
                data[name] = event.val;
                $.post(settings.change, data, function(data) {
                    $this.data('rawValue',event.val);
                    $.icescrum.object.addOrUpdateToArray(name.split('.')[0],data);
                }, 'json').fail(function(){
                        $this.select2('val', $this.data('rawValue'));
                    });
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
        $.each(['formatResult', 'formatSelection'], function(){
            if (settings[this]){
                settings[this] = getFunction(settings[this], ["object","container"]);
            }
        });
        var select = $this.select2(settings);
        $('#s2id_'+$this.attr('id')).find('input:first').attr('data-focusable','s2id_'+$this.attr('id'));
        if (settings.change && !settings.change.startsWith('$')) {
            $this.data('rawValue',$this.select2('val'));
            select.change(function (event) {
                var data = { };
                var name = $this.attr('name');
                data[name] = event.val;
                $.post(settings.change, data, function(data) {
                    $.icescrum.object.addOrUpdateToArray(name.split('.')[0],data);
                }, 'json').fail(function(){
                        $this.select2('val', $this.data('rawValue'));
                    });
            })
        } else if (settings.change && settings.change.startsWith('$')){
            select.change(function(event){
                getFunction(settings.change, ["val"]).apply(this, [event.val]);
            });
        }
        if (settings['created']){
            var funct = getFunction(settings['created'], []);
            funct($this, $this.select2("container"));
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
                return '<a href="'+settings.tagLink+object.text+'" onclick="document.location=this.href;"> <i class="fa fa-tag"></i> '+object.text+'</a>';
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
            $this.data('rawValue',$this.select2('val'));
            select.change(function () {
                var data = { };
                var name = $this.attr('name');
                data[name] = $this.val();
                $.post(settings.change, data, function(data) {
                    $.icescrum.object.addOrUpdateToArray(name.split('.')[0],data);
                }, 'json').fail(function(){
                        $this.select2('val', $this.data('rawValue').length > 0 ? $this.data('rawValue') : null);
                    });
            })
        } else if (settings.change && settings.change.startsWith('$')){
            select.change(function(){
                getFunction(settings.change, ["val"]).apply(this, [$this.val()]);
            });
        }
    });

    $('input[data-txt],textarea[data-txt]', content).each(function() {
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
        var name = $this.attr('name');
        var splitted = name.split('.');

        if (enabled && settings.change) {
            var changeFunction = function (event) {
                if (event.type == 'keyup' && event.which == 27){
                    $this.val($this.data('rawValue'));
                    $this.blur();
                    return;
                }
                if (event.type != 'keyup' || (event.type == 'keyup' && event.which == 13)){
                    var val = $this.val();
                    if ((val == '' && $this.attr('required')) || (event.type == 'keypress' && event.which != 13)) {
                        return;
                    }
                    var data = {};
                    data[name] = val;
                    if($this.data('rawValue') != data[name]){
                        $this.data('rawValue', data[name]);
                        $this.attr('readonly');
                        $.post(settings.change, data, function(data) {
                            $.icescrum.object.addOrUpdateToArray(splitted[0],data);
                            if (settings.onSave){
                                getFunction(settings.onSave, ["data"]).apply(this, [data]);
                            }
                        }, 'json').fail(function(){
                                    $this.val($this.data('rawValue'));
                                    $this.data('rawValue', '');
                                }).always(function(){
                                    $this.prop('readonly', false);
                                });
                    }
                }
            };
            if (settings.onlyReturn){
                $this.on('keyup', null, 'return', changeFunction);
            } else {
                $this.on('focus', function(){
                    $this.data('rawValue', $this.val());
                });
                $this.on('blur keyup', changeFunction);
            }
        }
    });

    $('div[data-fixed-container]', content).each(function(){
        var $this = $(this);
        if ($this.data('data-fixed-init')){
            return;
        } else {
            $this.data('data-fixed-init', true);
        }
        var settings = $this.html5data('fixed');
        var container = $(settings.container);
        var initialTop = $this.offset().top - container.offset().top + container.scrollTop();
        var id = 'scroll.fixed'+(new Date().getTime());
        var fixedFunction = function(event, manual) {
            //remove event
            if (!$this.is(':visible')){
                container.off( id );
                return;
            }
            var scrollTop = container.scrollTop();
            if(manual || (initialTop - scrollTop <= 0 && !$this.hasClass('fixed'))){
                $this.next().css('margin-top', $this.outerHeight());
                $this.addClass('fixed')
                    .css('top', container.offset().top + (settings.offsetTop ?  settings.offsetTop : 0))
                    .css('width', $this.parent().outerWidth(true) + (settings.offsetWidth ?  settings.offsetWidth : 0))
                    .css('left', container.offset().left + (settings.offsetLeft ?  settings.offsetLeft : 0))
                    .css('position', 'fixed');
                container
            } else if (initialTop - scrollTop > 0 && $this.hasClass('fixed')) {
                $this.removeClass('fixed')
                    .css('top', '')
                    .css('width', '')
                    .css('left','')
                    .css('position', '');
                $this.next().css('margin-top', '');
            }
        };
        container.on(id, fixedFunction);
        container.scroll();
        $this.bind('manual-scroll', function(event){ fixedFunction(event, true); });
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
        var preview = $('<div class="atwho-preview form-control-static"></div>');
        preview.insertAfter($this);

        var updateText = function(rawValue){
            if (rawValue){
                preview.data('rawValue', rawValue);
                preview.html(getFunction(settings.matcher, ["val"]).apply(this, [{description:rawValue}]));
                $this.prop('readonly', false);
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
        };

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
                        }).fail(function(){
                                $this.val(preview.data('rawValue'));
                                updateText(null);
                            }).always(function(){
                                $this.prop('readonly', false);
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

    $('div[data-ui-selectable-filter]', content).each(function(){
        var $this = $(this);
        if ($this.data('ui-selectable-init')){
            return;
        } else {
            $this.data('ui-selectable-init', true);
        }
        if (isTouchDevice){
            return false;
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

    $('[data-binding-type]', content).each(function(){
        var $this = $(this);
        if ($this.data('binding-init')){
            return;
        } else {
            $this.data('binding-init', true);
        }
        var settings = $this.html5data('binding');

        if (settings.after){
            settings.after = getFunction(settings.after, ["settings"]);
        }

        $.icescrum.object.dataBinding.apply(this,[settings]);
    });

    $('[data-ui-droppable-drop]', content).each(function(){
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

    $('[data-ui-droppable2-drop]', content).each(function(){
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
                $this.on('dragstart', function(){
                    $(document.body).addClass('dragging');
                });
                $this.on('dragstop', function(){
                    $(document.body).removeClass('dragging');
                });
                !$this.data('drag-init', true);
            }
        });
    });

    $('[data-ui-sortable-handle]', content).each(function(){
        var $this = $(this);
        if ($this.data('ui-sortable-init')){
            return;
        } else {
            $this.data('ui-sortable-init', true);
        }
        var settings = $this.html5data('ui-sortable');
        if (settings.disabled){
            return;
        }
        $.each(['update','receive','start','stop','activate','beforeStop','change','create','deactivate','out','over','remove','sort'], function(){
            if (settings[this]){
                settings[this] = getFunction(settings[this], ["event","ui"]);
            }
        });

        $this.sortable(settings);

        $this.on( "sortstart", function( event, ui ) {
            $(document.body).addClass('dragging');
            var classes = ui.item.attr('class');
            classes = classes.trim().split(' ');
            _.each(classes, function(classe){
                var droppable = $('[data-ui-droppable-accept=".'+classe+'"]');
                droppable.addClass('bg-warning');
            });
        });
        $this.on( "sortstop", function( event, ui ) {
            $(document.body).removeClass('dragging');
            var classes = ui.item.attr('class');
            classes = classes.trim().split(' ');
            _.each(classes, function(classe){
                var droppable = $('[data-ui-droppable-accept=".'+classe+'"]');
                droppable.removeClass('bg-warning');
            });
        });
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
            } else if(elWidth > margin) {
                var reconstruct = $this.hasClass('ui-resizable-hidden');
                $this.removeClass('ui-resizable-hidden').show();
                div.css(settings.right ? 'right' : 'left', $this.outerWidth(true) + margin);
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
            div.css('right', $this.outerWidth(true) + margin);
        } else {
            div.css('left', $this.outerWidth(true) + margin);
        }
        settings._containment = settings.containment == 'parent' ? 'hack' : null;
        settings.containment = settings.containment == 'parent' ? null : settings.containment;
        var options = {
            handles: settings.right ? 'w' : 'e',
            resize: resize,
            start: function() {
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
        var $handle = $this.find(".ui-resizable-handle");
        $handle.append("<span class='grip'><i class='fa fa-ellipsis-v'></i><i class='fa fa-ellipsis-v'></i></span>");
        $handle.css(settings.right ? 'left' : 'right',-margin);
        $handle.on('dblclick',function(){
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
                if ($(this).hasClass('modal-open')){
                    return;
                }
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

    $('div[data-ui-dialog]', content).each(function(){
        var $this = $(this);
        if ($this.data('init-ui-dialog')){
            return;
        } else {
            $this.data('init-ui-dialog', true);
        }
        var settings = $.extend({},$this.html5data('ui-dialog'));
        $.each(['show.bs.modal','shown.bs.modal','hide.bs.modal','hidden.bs.modal','loaded.bs.modal'], function(){
            if (settings[this.replace(/\./g,'')]){
                settings[this] = getFunction(settings[this.replace(/\./g,'')], ["e"]);
            }
        });
        $this.modal(settings);
        $this.on('shown.bs.modal', function(){
            $(this).find('[autofocus]').focus();
        });
    });

    $('ul[data-ui-tabs-auto-collapse]', content).each(function(){
        var $this = $(this);
        if ($this.data('init-ui-tabs')){
            return;
        } else {
            $this.data('init-ui-tabs', true);
        }
        var settings = $.extend({height:49, moreText:'More'},$this.html5data('ui-tabs'));
        var $dropdown = $('<li><a class="btn dropdown-toggle" data-toggle="dropdown" href="#">'+ settings.moreText +' <span class="caret"/></a><ul class="dropdown-menu"/></li>');
        $dropdown.appendTo($this);

        $this.find('a[data-toggle="tab"]').on('shown.bs.tab', function (e) {
            $(e.relatedTarget).parent().removeClass('active');
        });

        var autocollapse = function() {
            var tabsHeight = $this.innerHeight();
            var $collapsed = $dropdown.find('> ul:first');
            if (tabsHeight >= settings.height) {
                while(tabsHeight > settings.height) {
                    var children = $this.children('li:not(:last-child)');
                    var count = children.size();
                    $(children[count-1]).prependTo($collapsed);
                    tabsHeight = $this.innerHeight();
                }
            }
            else {
                while(tabsHeight < settings.height && ($collapsed.children('li').size()>0)) {
                    var collapsed = $collapsed.children('li');
                    var count = collapsed.size();
                    $(collapsed[0]).insertBefore($dropdown);
                    tabsHeight = $this.innerHeight();
                }
                if (tabsHeight>settings.height) {
                    autocollapse();
                }
            }
            $collapsed.children('li').size() == 0 ? $dropdown.hide() : $dropdown.show();
        };
        autocollapse();
        $(window).on('resize', autocollapse);
    });

    $('ul.nav-pills', content).each(function(){
        $(this).find('a:first').tab('show');
    });

    $('ul[data-ui-dropdown-clickbsdropdown]', content).each(function(){
        var $this = $(this);
        var settings = $.extend({},$this.html5data('ui-dropdown'));
        $.each(['show.bs.dropdown','shown.bs.dropdown','hide.bs.dropdown','hidden.bs.dropdown', 'click.bs.dropdown'], function(){
            if (settings[this.replace(/\./g,'')]){
                settings[this] = getFunction(settings[this.replace(/\./g,'')], ["e"]);
            }
        });
        $this.dropdown(settings);
        if (settings['changeValue']){
            $this.find('> li > a').on('click', function(){
                var $value = $this.prev().find('span:first');
                $value.html($(this).text());
                $value.data('value', $(this).data('value'));
            });
        }
        $this.find('> li > a').on('click', settings['click.bs.dropdown']);
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

    $.event.trigger('domUpdate.icescrum',content);
}
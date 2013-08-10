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
    $.event.trigger('domUpdate.icescrum',content);
}
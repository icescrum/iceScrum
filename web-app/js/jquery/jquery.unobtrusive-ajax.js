(function ($) {

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

    function isMethodProxySafe(method) {
        return method === "GET" || method === "POST";
    }

    function ajaxOnBeforeSend(xhr, method) {
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
        var confirm, loading, method, duration;

        confirm = element.data("ajaxConfirm");
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
                ajaxOnBeforeSend(xhr, method);
                result = getFunction(element.data("ajaxBegin"), ["xhr", "element"]).apply(this, [xhr, element]);
                if (result !== false) {
                    loading.show(duration);
                }
                return result;
            },
            complete: function () {
                loading.hide(duration);
                getFunction(element.data("ajaxComplete"), ["xhr", "status"]).apply(this, arguments);
            },
            success: function (data, status, xhr) {
                ajaxOnSuccess(element, data, xhr.getResponseHeader("Content-Type") || "text/html");
                if (data.dialog){
                    $(document.body).append(data.dialog);
                }else{
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

        options.data.push({ name: "X-Requested-With", value: "XMLHttpRequest" });

        method = options.type.toUpperCase();
        if (!isMethodProxySafe(method)) {
            options.type = "POST";
            options.data.push({ name: "X-HTTP-Method-Override", value: method });
        }

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
            type: a.attr('method') || 'GET',
            data: []
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


    $(document).on('hover','.postit, .postit-rect', function(event){
        var elem = $(this);
        var tooltip = $('.tooltip',elem);
        if (tooltip.length > 0){
            if (!elem.data('tooltip-init')){
                elem.tipTip({delay:500, activation:"focus", defaultPosition:"right", content:tooltip.html(), edgeOffset:-20});
                elem.data('tooltip-init',true);
            }
            (event.type == 'mouseenter' && !$('#dropmenu').is(':visible')) ? elem.focus() : elem.blur();
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

    attachListeners();

}(jQuery));

function attachListeners(content){
    $('a[data-shortcut]', content).each(function(){
        var elem = $(this);
        var onClean = elem.data('shortcutOn') ? elem.data('shortcutOn').replace(/\W/g, '')  : 'body';
        var on = elem.data('shortcutOn') ? elem.data('shortcutOn')  : document.body;
        var bind = 'keydown.'+'.'+onClean+'.'+elem.data('shortcut').replace(/\+/g,'');
        $(on).unbind(bind);
        $(on).bind(bind,elem.data('shortcut'),function(e){
            if (!elem.attr('href') || elem.data('ajax')){
                elem.click();
            }else if (elem.attr('href')){
                document.location.hash = elem.attr('href');
            }
            e.preventDefault();
        });
    });
}
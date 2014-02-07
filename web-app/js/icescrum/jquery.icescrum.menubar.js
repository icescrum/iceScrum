(function($) {

    function retrieveRightLimit($rightElement) {
        return $rightElement.size() > 0 ? $rightElement.offset().left : null;
    }

    function retrieveBottomLimit($bottomElement) {
        return $bottomElement.size() > 0 ? $bottomElement.offset().top : null;
    }

    function retrieveRightEdge($element) {
       return $element.size() > 0 ? $element.offset().left + $element.width() : null;
    }

    function retrieveBottomEdge($element) {
        return $element.size() > 0 ? $element.offset().top + $element.height() : null;
    }

    function updateTop($element, value) {
        var offset = $element.offset();
        offset.top += value;
        $element.offset(offset);
    }

    jQuery.extend($.icescrum, {

        checkBars:function() {
            $.icescrum.menuBar.checkMenuBar();
            $.icescrum.toolbar.checkToolbar();
        },

        toolbar: {
            checkToolbar:function(){
                var $toolbar = $('#window-toolbar');

                if ($toolbar.size()){
                    var topEdge = $toolbar.offset().top;
                    var $arrow = $toolbar.find('#toolbar-list-button');
                    var $search = $toolbar.find('#search-ui');

                    if ($arrow.size() == 0){
                        $arrow = $('<li style="visibility: hidden;" id="toolbar-list-button" class="navigation-item list separator"/>');
                        $('<div data-dropmenu="true" id="toolbar-list" class="dropmenu" style="cursor: pointer;"/>')
                            .append('<div class="dropmenu-content ui-corner-all"><ul id="toolbar-list-hidden"/></div>')
                            .append('<a class="button-n dropmenu-button button-n"><span class="start"/><span class="content">' + $.icescrum.o.more + '<span class="end"><span class="arrow"></span></span></a>')
                            .appendTo($arrow);
                        $arrow.insertAfter($toolbar.find('> .navigation-item:visible:last'));
                    }

                    var taller = false;
                    var $listHidden = $arrow.find('#toolbar-list-hidden');
                    var hidden = $arrow.find('#toolbar-list-hidden > .navigation-item').toArray();
                    $(hidden).each(function(){
                        var $elem = $(this);
                        $arrow.before($elem);
                        if ($arrow.offset().top > topEdge || ($search.size() != 0 && $search.offset().top > topEdge)){
                            $elem.prependTo($listHidden);
                            return false;
                        }else{
                            taller = true;
                        }
                        $elem.removeClass('first');
                    });

                    if (!taller){
                        var $elem = $toolbar.find('> .navigation-item:not(.list):visible:last');
                        var $item = $arrow.css('visibility') == 'visible' ? $arrow : $elem;
                        while ($elem.size() != 0 && $item.size() != 0 && ($item.offset().top > topEdge || ($search.size() != 0 && $search.offset().top > topEdge) )){
                            $listHidden.find('li:first').removeClass('first');
                            $elem.prependTo($listHidden);
                            $listHidden.find('li:first').addClass('first');
                            $elem = $toolbar.find('> .navigation-item:not(.list):visible:last');
                            $item = $arrow.css('visibility') == 'visible' ? $arrow : $elem;
                        }
                    }

                    var visibility = $arrow.find('ul:first > li').size() == 0 ? 'hidden' : 'visible';
                    $arrow.css('visibility', visibility);
                }
            }
        },

        //Event from menu bar
        menuBar: {
            updateMenubar:function(sortable, id, position, hidden){
                $.post($.icescrum.o.baseUrl+'user/menuBar',{id:id, position:position + 1, hidden: hidden ? true : false}).fail(function(){
                    sortable.sortable('cancel');
                });
            },

            stop:function(event,ui){
                if ($('#menubar-list-content').find('> ul .menubar').size() > 0){
                    $('#menubar-list-button').css('visibility','visible');
                }else{
                    $('#menubar-list-button').css('visibility','hidden');
                }
            },
            start:function(event, ui) {
                ui.helper.css('cursor','move');
                $('#menubar-list-button').css('visibility','visible');
            },
            update:function(event,ui){
                var position = $(".navigation-content .menubar").index(ui.item);
                if(position == -1 || ui.sender != undefined){
                    return;
                }else if (ui.item.attr('id')){
                    $.icescrum.menuBar.updateMenubar($(this),ui.item.attr('id'), position, false);
                }
            },
            receive:function(event,ui){
                ui.item.addClass('draggable-to-main');
                ui.item.removeAttr('hidden');
                $.icescrum.menuBar.updateMenubar($(this),ui.item.attr('id'), $(".navigation-content .menubar").index(ui.item), false);
                if ($('#menubar-list-content').find('> ul .menubar').size() > 0){
                    $('#menubar-list-button').css('visibility','visible');
                }else{
                    $('#menubar-list-button').css('visibility','hidden');
                }
            },
            onDropHidden:function(event,ui){
                var item = ui.draggable.clone();
                ui.draggable.remove();
                var container = $('#menubar-list-content').find('> ul');
                container.append(item);
                item.removeClass('draggable-to-main');
                item.show();
                item.attr('hidden','true');
                $.icescrum.menuBar.updateMenubar($(this),ui.item.attr('id'), container.index(item), true);
            },
            hidden:{
                start:function(event, ui) {
                    $(ui.helper).addClass('drag');
                    ui.helper.css('cursor','move');
                },
                stop:function(event,ui){
                    if ($('#menubar-list-content').find('> ul .menubar').size() > 0){
                        $('#menubar-list-button').css('visibility','visible');
                    }else{
                        $('#menubar-list-button').css('visibility','hidden');
                    }
                },
                update:function(event,ui){
                    var position = $("#menubar-list-content").find("> ul .menubar").index(ui.item);
                    if(position == -1 || ui.sender != undefined){
                        return;
                    }else{
                        $.icescrum.menuBar.updateMenubar($(this),ui.item.attr('id'), position, true);
                    }
                    event.stopPropagation();
                }
            },
            checkMenuBar:function() {
                var $listHidden = $('#menubar-list-content').find('> ul');
                var $arrow = $('#menubar-list-button');
                // Show all
                var taller = false;
                var candidatesForShowing = $listHidden.find('.menubar:not([hidden])').toArray();
                var rightLimit = retrieveRightLimit($("#navigation-avatar"));
                var bottomLimit = retrieveBottomLimit($("#main"));

                $(candidatesForShowing).each(function(){
                    var $candidateForShowing = $(this);
                    $candidateForShowing.addClass('draggable-to-main');
                    $arrow.before($candidateForShowing);
                    var arrowRightEdge = retrieveRightEdge($arrow);
                    var arrowBottomEdge = retrieveBottomEdge($arrow);
                    if(arrowRightEdge > rightLimit || arrowBottomEdge > bottomLimit){
                        $candidateForShowing.prependTo($listHidden);
                        return false;
                    } else {
                        taller = true;
                    }
                });
                if  (!taller){
                    // Hide elements until it fits
                    var arrowRightEdge = retrieveRightEdge($arrow);
                    var arrowBottomEdge = retrieveBottomEdge($arrow);
                    if(rightLimit && bottomLimit && arrowRightEdge && arrowBottomEdge) {
                        while (arrowRightEdge > rightLimit || arrowBottomEdge > bottomLimit) {
                            var $lastMenu = $('.navigation-content .menubar:visible:last');
                            if ($lastMenu.size() != 0) {
                                $lastMenu.removeClass('draggable-to-main');
                                $lastMenu.prependTo($listHidden);
                                arrowRightEdge = retrieveRightEdge($arrow);
                                arrowBottomEdge = retrieveBottomEdge($arrow);
                            } else {
                                return;
                            }
                        }
                    }
                }
                // Update the arrow visibility
                var visibility = $('.menubar', $listHidden).size() == 0 ? 'hidden' : 'visible';
                $arrow.css('visibility', visibility)
            }
        }
})
})(jQuery);
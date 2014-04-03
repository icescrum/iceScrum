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
        },

        //Event from menu bar
        menuBar: {

            start:function(event, ui) {
                var $mainmenu = $('#mainmenu');
                var $arrow = $mainmenu.find('.menubar-hidden');
                if (ui.item.hasClass('draggable-to-widgets')){
                    $('.sidebar-hidden').removeClass('sidebar-hidden');
                }
                $arrow.css('visibility','visible');
            },

            stop:function(event,ui){
                var $mainmenu = $('#mainmenu');
                var $arrow = $mainmenu.find('.menubar-hidden');
                $arrow.find('.dropdown-menu').dropdown('toggle');
                $.icescrum.menuBar.checkMenuBar();
                $.icescrum.checkSidebar();
            },

            update:function(event,ui){
                var $menu = $("#mainmenu");
                var hidden = ui.item.parent().parent().hasClass('menubar-hidden');
                var position = hidden ? $menu.find('.menubar-hidden .menubar:not(.hidden)').index(ui.item) : $menu.find("> ul .menubar:not(.hidden)").index(ui.item);
                if(position == -1 || ui.sender != undefined){
                    return;
                }else if (ui.item.attr('id')){
                    if (hidden){
                        ui.item.attr('data-hidden',true);
                    }
                    $.post($.icescrum.o.baseUrl+'user/menuBar',{id:ui.item.attr('id'), position:position + 1, hidden: hidden}).fail(function(){
                        $menu.find('> ul:first').sortable('cancel');
                    });
                }
            },

            checkMenuBar:function() {
                var $mainmenu = $('#mainmenu');
                var $listHidden = $mainmenu.find('.menubar-hidden > ul');
                var $arrow = $mainmenu.find('.menubar-hidden');
                // Show all
                var taller = false;
                var candidatesForShowing = $listHidden.find('.menubar:not([data-hidden])').toArray();
                var rightLimit = retrieveRightLimit($mainmenu.find(".navbar-right:last"));
                var bottomLimit = retrieveBottomLimit($("#main-content"));

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
                            var $lastMenu = $mainmenu.find('> ul > li.menubar:not(.hidden):visible:last');
                            if ($lastMenu.size() != 0) {
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
                var visibility = $('.menubar:not(.hidden)', $listHidden).size() == 0 ? 'hidden' : 'visible';
                $arrow.css('visibility', visibility);
                $mainmenu.find('> ul > li.menubar:visible').off('mousedown.dropdown').on('mousedown.dropdown',function(){
                    var $dropdown = $arrow.find('.dropdown-menu');
                    if (!$arrow.hasClass('open')){
                        $dropdown.dropdown('toggle');
                    }
                });

                $mainmenu.find('li.menubar > a').off('mousedown.tooltip').on('mousedown.tooltip',function(){
                    $(this).tooltip('hide');
                });

                if (visibility == 'visible'){
                    $arrow.find('.hidden').css('display','');
                }else{
                    $arrow.find('.hidden').css('display','block');
                }
                if ($mainmenu.find('> ul > li.menubar:not(.hidden):visible').size() > 0){
                    $mainmenu.find('> ul > li.menubar.hidden').css('display','');
                } else {
                    $mainmenu.find('> ul > li.menubar.hidden').css('display','block');
                }
            }
        }
})
})(jQuery);
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
            $.icescrum.checkMenuBar();
            $.icescrum.checkToolbar();
        },

        checkMenuBar:function() {
            var $listHidden = $('#menubar-list-content > ul');
            var $arrow = $('#menubar-list-button');
            // Show all
            var candidatesForShowing = $listHidden.find('.menubar:not([hidden])').toArray().reverse();
            $(candidatesForShowing).each(function(){
                var $candidateForShowing = $(this);
                $candidateForShowing.addClass('draggable-to-desktop');
                $arrow.before($candidateForShowing);
            });
            // Hide elements until it fits
            var rightLimit = retrieveRightLimit($("#navigation-avatar"));
            var bottomLimit = retrieveBottomLimit($("#main"));
            var arrowRightEdge = retrieveRightEdge($arrow);
            var arrowBottomEdge = retrieveBottomEdge($arrow);
            if(rightLimit && bottomLimit && arrowRightEdge && arrowBottomEdge) {
                while (arrowRightEdge > rightLimit || arrowBottomEdge > bottomLimit) {
                    var $lastMenu = $('.navigation-content .menubar:visible:last');
                    if ($lastMenu.size() != 0) {
                        $lastMenu.removeClass('draggable-to-desktop');
                        $lastMenu.appendTo($listHidden);
                        arrowRightEdge = retrieveRightEdge($arrow);
                        arrowBottomEdge = retrieveBottomEdge($arrow);
                    } else {
                        return;
                    }
                }
            }
            // Update the arrow visibility
            var visibility = $('.menubar', $listHidden).size() == 0 ? 'hidden' : 'visible';
            $arrow.css('visibility', visibility)
        },

        checkToolbar:function() {
            var $windowContent = $('.window-content');
            var $overflowToolbar = $('#toolbar-overflow');
            var $toolbar = $('.box-navigation:has(ul#window-toolbar)');
            if($toolbar.size() > 0 && $overflowToolbar.size() > 0 && $windowContent.size() > 0) {
                $toolbar.css('overflow', 'scroll');
                var scrollHeight = $toolbar[0].scrollHeight;
                $toolbar.css('overflow', 'visible');
                if(scrollHeight > $toolbar.height()) {
                    if($overflowToolbar.is(':hidden')) {
                        $overflowToolbar.show();
                        updateTop($windowContent, $overflowToolbar.height());
                    }
                } else {
                    if($overflowToolbar.is(':visible')) {
                        updateTop($windowContent, -$overflowToolbar.height());
                        $overflowToolbar.hide();
                    }
                }
            }
        }
    })
})(jQuery);
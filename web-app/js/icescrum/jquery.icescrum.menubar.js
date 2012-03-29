(function($) {

    function retrieveRightLimit(selector) {
        var $leftElement = $(selector);
        return ($leftElement.offset() != null) ? $leftElement.offset().left : null;
    }

    function retrieveBottomLimit(selector) {
        var $bottomElement = $(selector);
        return ($bottomElement.offset() != null) ? $bottomElement.offset().top : null;
    }

    function retrieveRightEdge($element) {
       return $element.size() > 0 ? $element.offset().left + $element.width() : null;
    }

    function retrieveBottomEdge($element) {
        return $element.size() > 0 ? $element.offset().top + $element.height() : null;
    }

    jQuery.extend($.icescrum, {

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
            var rightLimit = retrieveRightLimit("#navigation-avatar");
            var bottomLimit = retrieveBottomLimit("#main");
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
        }
    })
})(jQuery);
(function($) {
    jQuery.extend($.icescrum, {
                checkMenuBar:function(last) {
                    if (last == null) {
                        last = "#profile-name"
                    }

                    var lastMenuItem = $('.navigation-content .menubar:visible:last');

                    var menuDropList = $('#menubar-list-button');
                    var posMenuDropList = null;
                    if (menuDropList.size() > 0) {
                        posMenuDropList = menuDropList.offset().left + menuDropList.width();
                    }

                    var lastPos = null;
                    if ($(last).offset() != null) {
                        lastPos = $(last).offset().left;
                    }

                    var contentMenuDrop = $('#menubar-list-content > ul');
                    if (lastPos && posMenuDropList && posMenuDropList > lastPos) {
                        if (lastMenuItem.size() != 0) {
                            menuDropList.css('visibility', 'visible');
                            lastMenuItem.removeClass('draggable-to-desktop');
                            lastMenuItem.appendTo(contentMenuDrop);
                            $.icescrum.checkMenuBar(last);
                            return;
                        }
                    }

                    var widthLastHidden = null;
                    var lastHidden = contentMenuDrop.find('.menubar[hidden!=true]:last');

                    if (lastHidden.size() > 0) {
                        contentMenuDrop.parent().css('visibility', 'hidden').show();
                        widthLastHidden = lastHidden.width();
                        contentMenuDrop.parent().hide().css('visibility', 'visible');
                    } else if (contentMenuDrop.find('.menubar').size() == 0) {
                        menuDropList.css('visibility', 'hidden');
                    }

                    if (lastPos && posMenuDropList && widthLastHidden && (posMenuDropList + widthLastHidden < lastPos)) {
                        lastHidden.addClass('draggable-to-desktop');
                        menuDropList.before(lastHidden);
                        $.icescrum.checkMenuBar(last);
                    }
                }
            })
})(jQuery);
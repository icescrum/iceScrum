/*
 * Copyright (c) 2010 iceScrum Technologies.
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
 */

(function($) {
    $.fn.scrollbar = function(params) {
        params = $.extend({
            contentHeight: null,
            contentWidth: null,
            scrollbarDragWidth: 50,
            scrollbarDragHeight: 50,
            pinch:25,
            position:'left',
            scrollbarWidth:5,
            scrollbarHeight:5
        }, params);

        return this.each(function() {
            if (params.contentHeight) {
                var self = $(this);
                var originalHeight = self.height();
                var contentHeight_init = params.contentHeight;
                var scrollbarHeight = params.contentHeight;
                var wrapper,dragButton,scrollbar;


                var temp = self.width();
                self.wrapInner('<div class="scrollbar-wrapper"></div>');
                wrapper = self.find('.scrollbar-wrapper');

                self.css({'height':params.contentHeight + 'px','overflow':'hidden','position':'relative'});

                wrapper.css({'top':0 + 'px','float':'left','position':'relative','width':temp - params.scrollbarWidth + 'px'});
                var clear = $('<div class="clear"></div>')
                self.append(clear);
                clear.css({'clear':'both'});

                switch (params.position) {
                    case 'right':
                        scrollbar = $('<div class="scrollbar"></div>');
                        wrapper.after(scrollbar);
                        break;
                    case 'left':
                        scrollbar = $('<div class="scrollbar"></div>');
                        wrapper.before(scrollbar);
                        break;
                }


                dragButton = $('<div class="scrollbar-drag-button">&nbsp;</div>');
                scrollbar.append(dragButton);
                scrollbar.css({'width':params.scrollbarWidth + 'px','float':'left','height':scrollbarHeight + 'px','background':'#61AFF7','margin-top':'0px'});
                dragButton.css({'width':params.scrollbarWidth + 'px','height':params.scrollbarDragHeight + 'px','background':'#4382BD','top':0 + 'px','cursor':'pointer'});

                dragButton.draggable({
                    containment: 'parent',
                    axis: 'y',
                    drag: function(event, ui) {
                        moveContent(ui.position.top);
                    }
                });

                self.mousewheel(function(event, delta) {
                    var wrapperTop = parseInt(wrapper.css('top').substring(0, (wrapper.css('top').length - 2)));
                    if (delta > 0) {
                        wrapperTop = wrapperTop + params.pinch;
                        if (wrapperTop > 0) {
                            wrapperTop = 0
                        }
                        wrapper.css({'top':wrapperTop + "px"});
                    } else if (delta < 0) {
                        wrapperTop = wrapperTop - params.pinch;
                        if (wrapperTop < (params.contentHeight - originalHeight)) {
                            wrapperTop = params.contentHeight - originalHeight
                        }
                        wrapper.css({'top':wrapperTop + "px"});
                    }
                    dragScroll(wrapperTop);
                });

                if (originalHeight <= params.contentHeight) {
                    hide();
                } else {
                    show();
                }

                wrapper.bind('resize.scrollbar', function() {
                    originalHeight = wrapper.height();
                    if (originalHeight <= params.contentHeight) {
                        hide();
                    } else {
                        var wrapperTop = parseInt(wrapper.css('top').substring(0, (wrapper.css('top').length - 2)));
                        if (wrapperTop < (params.contentHeight - originalHeight)) {
                            wrapperTop = params.contentHeight - originalHeight
                        }
                        wrapper.css({'top':wrapperTop + "px"});
                        show();
                    }
                });
            }
            else {
                var self = $(this);
                var originalWidth = self.width();
                var contentHeight_init = params.contentWidth;
                var scrollbarWidth = params.contentWidth;
                var wrapper,dragButton,scrollbar;


                var temp = self.height();
                self.wrapInner('<div class="scrollbar-wrapper"></div>');
                wrapper = self.find('.scrollbar-wrapper');

                self.css({'width':params.contentWidth + 'px','overflow':'hidden','position':'relative'});

                wrapper.css({'width':originalWidth+'px','left':0 + 'px','position':'relative','height':temp - params.scrollbarHeight + 'px'});
                var clear = $('<div class="clear"></div>')
                self.append(clear);
                clear.css({'clear':'both'});

                switch (params.position) {
                    case 'bottom':
                        scrollbar = $('<div class="scrollbar"></div>');
                        wrapper.after(scrollbar);
                        break;
                    case 'top':
                        scrollbar = $('<div class="scrollbar"></div>');
                        wrapper.before(scrollbar);
                        break;
                }


                dragButton = $('<div class="scrollbar-drag-button">&nbsp;</div>');
                scrollbar.append(dragButton);
                scrollbar.css({'height':params.scrollbarHeight + 'px','float':'left','width':params.contentWidth + 'px','background':'#61AFF7','margin-left':'0px'});
                dragButton.css({'height':params.scrollbarHeight + 'px','width':params.scrollbarDragWidth + 'px','background':'#4382BD','left':0 + 'px','cursor':'pointer'});

                dragButton.draggable({
                    containment: 'parent',
                    axis: 'x',
                    drag: function(event, ui) {
                        moveContent(ui.position.left);
                    }
                });

                self.mousewheel(function(event, delta) {
                    var wrapperLeft = parseInt(wrapper.css('left').substring(0, (wrapper.css('left').length - 2)));
                    if (delta > 0) {
                        wrapperLeft = wrapperLeft + params.pinch;
                        if (wrapperLeft > 0) {
                            wrapperLeft = 0
                        }
                        wrapper.css({'left':wrapperLeft + "px"});
                    } else if (delta < 0) {
                        wrapperLeft = wrapperLeft - params.pinch;
                        if (wrapperLeft < (params.contentWidth - originalWidth)) {
                            wrapperLeft = params.contentWidth - originalWidth
                        }
                        wrapper.css({'left':wrapperLeft + "px"});
                    }
                    dragScroll(wrapperLeft);
                });

                if (originalWidth <= params.contentWidth) {
                    hide();
                } else {
                    show();
                }

                wrapper.bind('resize.scrollbar', function() {
                    originalWidth = wrapper.width();
                    if (originalWidth <= params.contentHeight) {
                        hide();
                    } else {
                        var wrapperLeft = parseInt(wrapper.css('left').substring(0, (wrapper.css('left').length - 2)));
                        if (wrapperLeft < (params.contentWidth - originalWidth)) {
                            wrapperLeft = params.contentWidth - originalWidth
                        }
                        wrapper.css({'top':wrapperLeft + "px"});
                        show();
                    }
                });
            }


                function hide() {
                    if (params.contentHeight) {
                        scrollbar.hide();
                        self.css('height', '');
                        wrapper.css('width', self.width() + 'px');
                    }
                    if (params.contentWidth) {
                        scrollbar.hide();
                        self.css('width', '');
                        wrapper.css('height', self.height() + 'px');
                    }
                }

                function show() {


                    if (params.contentHeight) {
                        self.css('height', params.contentHeight);
                        wrapper.css('width', self.width() - params.scrollbarWidth + 'px');
                        scrollbar.show();
                    }
                    if (params.contentWidth) {

                        self.css('width', params.contentHeight);
                        wrapper.css('', self.height() - params.scrollbarHeight + 'px');
                        scrollbar.show();
                    }
                }



                function dragScroll(top) {


                    if (params.contentHeight) {
                        var drag = (top / (params.contentHeight - originalHeight)) * (scrollbarHeight - params.scrollbarDragHeight);
                        if (drag < 0) {
                            drag = 0;
                        }
                        if (drag > (scrollbarHeight - params.scrollbarDragHeight)) {
                            drag = scrollbarHeight - params.scrollbarDragHeight;
                        }
                        dragButton.css({'top':drag + "px"});
                    }
                    if (params.contentWidth) {
                        var drag = (top / (params.contentWidth - originalWidth)) * (scrollbarWidth - params.scrollbarDragWidth);
                        if (drag < 0) {
                            drag = 0;
                        }
                        if (drag > (scrollbarWidth - params.scrollbarDragWidth)) {
                            drag = scrollbarWidth - params.scrollbarDragWidth;
                        }
                        dragButton.css({'left':drag + "px"});
                    }


                }

                function moveContent(top) {
                    if (params.contentHeight) {
                        var move = (top / (scrollbarHeight - params.scrollbarDragHeight)) * (params.contentHeight - originalHeight);
                        if (move > 0) {
                            move = 0
                        }
                        if (move < (params.contentHeight - originalHeight)) {
                            move = (params.contentHeight - originalHeight)
                        }
                        wrapper.css({'top':move + "px"});
                    }
                    if (params.contentWidth) {
                        var move = (top / (scrollbarWidth - params.scrollbarDragWidth)) * (params.contentWidth - originalWidth);
                        if (move > 0) {
                            move = 0
                        }
                        if (move < (params.contentWidth - originalWidth)) {
                            move = (params.contentWidth - originalWidth)
                        }
                        wrapper.css({'left':move + "px"});
                    }


                }

        });
    }
})(jQuery);
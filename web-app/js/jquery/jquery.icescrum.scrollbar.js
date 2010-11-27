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
 * Vincent Barrier (vincent.barrier@icescrum.com)
 */

(function($) {
	$.fn.scrollbar = function(params) {
		params = $.extend( {
			contentHeight: null,
			scrollbarDragHeight: 50,
			pinch:25,
			position:'left',
			scrollbarWidth:5
		}, params);

		return this.each(function() {
            if (!params.contentHeight)
                return;
			var self = $(this);
            var originalHeight = self.height();
			var contentHeight_init = params.contentHeight;
			var scrollbarHeight = params.contentHeight;
            var wrapper,dragButton,scrollbar;

            function dragScroll(top){
				var drag = (top/(params.contentHeight - originalHeight))*(scrollbarHeight- params.scrollbarDragHeight);
				if(drag < 0){drag = 0;}
				if(drag > (scrollbarHeight - params.scrollbarDragHeight)){drag = scrollbarHeight - params.scrollbarDragHeight;}
				dragButton.css({'top':drag+"px"});
			}

			function moveContent(top){
				var move = (top/(scrollbarHeight - params.scrollbarDragHeight))*(params.contentHeight - originalHeight);
				if (move > 0){move = 0}
				if (move < (params.contentHeight - originalHeight)){move = (params.contentHeight - originalHeight)}
				wrapper.css({'top':move+"px"});
			}

            var temp = self.width();
            self.wrapInner('<div class="scrollbar-wrapper"></div>');
            wrapper = self.find('.scrollbar-wrapper');

            self.css({'height':params.contentHeight+'px','overflow':'hidden','position':'relative'});

            wrapper.css({'top':0+'px','float':'left','position':'relative','width':temp-params.scrollbarWidth+'px'});
            var clear = $('<div class="clear"></div>')
            self.append(clear);
            clear.css({'clear':'both'});

            switch (params.position){
                case 'right':
                    scrollbar = $('<div class="scrollbar"></div>');
                    wrapper.after(scrollbar);
                break;
                case 'left':
                    scrollbar = $('<div class="scrollbar"></div>');
                    wrapper.before(scrollbar);
                break;
            }

            function hide(){
                scrollbar.hide();
                self.css('height','');
                wrapper.css('width',self.width()+'px');
            }

            function show(){
                self.css('height',params.contentHeight);
                wrapper.css('width',self.width()-params.scrollbarWidth+'px');
                scrollbar.show();
            }

            dragButton = $('<div class="scrollbar-drag-button">&nbsp;</div>');
            scrollbar.append(dragButton);
            scrollbar.css({'width':params.scrollbarWidth+'px','float':'left','height':scrollbarHeight+'px','background':'#61AFF7','margin-top':'0px'});
            dragButton.css({'width':params.scrollbarWidth+'px','height':params.scrollbarDragHeight+'px','background':'#4382BD','top':0+'px','cursor':'pointer'});

            dragButton.draggable({
                containment: 'parent',
                    axis: 'y',
                    drag: function(event, ui) {
                        moveContent(ui.position.top);
                    }
                });

            self.mousewheel(function(event, delta) {
                var wrapperTop = parseInt(wrapper.css('top').substring(0,(wrapper.css('top').length-2)) );
                if (delta > 0) {
                    wrapperTop = wrapperTop + params.pinch;
                    if(wrapperTop > 0){wrapperTop = 0}
                    wrapper.css({'top':wrapperTop+"px"});
                }else if (delta < 0){
                    wrapperTop = wrapperTop - params.pinch;
                    if(wrapperTop < (params.contentHeight - originalHeight)){wrapperTop = params.contentHeight - originalHeight}
                    wrapper.css({'top':wrapperTop+"px"});
                }
                dragScroll(wrapperTop);
            });

            if (originalHeight <= params.contentHeight){
                hide();
            }else{
                show();
            }

            wrapper.bind('resize.scrollbar',function(){
                originalHeight = wrapper.height();
                if (originalHeight <= params.contentHeight){
                    hide();
                }else{
                    var wrapperTop = parseInt(wrapper.css('top').substring(0,(wrapper.css('top').length-2)) );
                    if(wrapperTop < (params.contentHeight - originalHeight)){wrapperTop = params.contentHeight - originalHeight}
                    wrapper.css({'top':wrapperTop+"px"});
                    show();
                }
            });
        });
	}
})(jQuery);
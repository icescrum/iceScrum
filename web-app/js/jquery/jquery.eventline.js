/*
 * Copyright (c) 2011 Kagilum.
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
 *
 */

(function($) {
    $.fn.eventline = function(options) {

        var overflow = $('.event-overflow');
        var rootContainer = $('.event-overflow').parent();
        overflow.css('overflow', 'hidden');
        var container = $('.event-container');
        var realWidth = container.length * 181;

        var size = function() {
            var container = $('.event-container');
            var contentList = $('.event-content-list');

            var realWidth = container.length * 181;
            overflow.width(realWidth);
            var selectList = $('.event-select');
            var adjust = 0;
            if (realWidth > rootContainer.width()) {
                adjust = 28;
                selectList.show();
                rootContainer.bind('mousewheel',function(event, delta, x, y) {
                    if (y != 0){
                        return;
                    }
                    var pixels = delta * 30;
                    var currentMargin = parseInt(overflow.css('margin-left').replace('px',''));
                    var newMargin = currentMargin + pixels;
                    if(newMargin >= 0){
                        overflow.css('margin-left',0);
                    }else if((newMargin + overflow.width()) < 181){
                        overflow.css('margin-left','-' + $('.event-container:last').position().left + 'px');
                    }else{
                        overflow.css('margin-left',newMargin);
                    }
                    event.preventDefault();
                });
            } else {
                selectList.hide();
                overflow.css('margin-left',0);
                rootContainer.unbind('mousewheel');
            }
            rootContainer.css('overflow-x', 'hidden');
            var height = rootContainer.height() - 50 - adjust;
            var oversize = false;
            contentList.find('.view-postit').each(function(index) {
                contentList.find('.view-postit').css('height', '');
                var currentHeight = $(this).height();
                if (height < currentHeight) {
                    oversize = true;
                    height = currentHeight + adjust;
                }
            });
            contentList.find('.view-postit').css('height', height);
            if (oversize) {
                contentList.find('.view-postit').css('margin-bottom', adjust);
            }
        };

        $(window).unbind('.eventline').bind('resize.eventline',
                function (e) {
                    if ($('.event-overflow').length == 0) {
                        $(window).unbind('.eventline');
                        return false;
                    }
                    size();
                }).trigger('resize');

        $('.event-select-item').live('click.eventline', function() {
            var elemid = $(this).attr('elemid');
            $('.event-overflow').css('margin-left', '-' + $('.event-container[elemid=' + elemid + ']').position().left + 'px');
        });
        if (options.focus && realWidth > rootContainer.width()) {
            $('.event-select-item[elemid=' + options.focus + ']').click();
        }
    }
}(jQuery));
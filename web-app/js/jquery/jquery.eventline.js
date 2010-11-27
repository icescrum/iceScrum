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
 * Manuarii Stein (manuarii.stein@icescrum.com)
 *
 */

(function($) {
    $.fn.eventline = function(options) {
        if ((typeof options) == "string") {
            $.eventline[options](this, arguments);
            return;
        }
        var opt = jQuery.extend({}, $.fn.eventline.defaults, options);

        // For quick access
        var rootContainer = $(opt.rootContainer);
        var container = $('.event-container');
        var contentList = $('.event-content-list');
        var lineScroll = $('.event-line-scroll');
        var lineHighlight = $('.event-line-highlight');
        var lineSub = $('.event-line-sub');
        var content = $('.event-line-content');
        var eventSub = $('.event-sub');
        var total = container.length;
        var eventlineWidth = opt.eventWidth * total;
        $(this).data('eventlineWidth', eventlineWidth);
        $(this).data('containerWidth', rootContainer.width());
        $(this).data('subEventWidth', opt.subEventWidth);
        $(this).data('eventWidth', opt.eventWidth);

        container.css('width', opt.eventWidth);
        content.width(eventlineWidth);
        eventSub.width(opt.subEventWidth);

        var height;
        var size = function(){
            if (eventlineWidth > rootContainer.width()) {
                lineScroll.show();
                eventSub.disableSelection();
                var highlightWidth = (opt.subEventWidth * rootContainer.width()) / opt.eventWidth;
                var leftMarginCorrection = rootContainer.width() / 2 - highlightWidth / 2;
                lineHighlight.width(highlightWidth);
                lineHighlight.css('margin-left', leftMarginCorrection);
                lineSub.width(opt.subEventWidth * total + leftMarginCorrection);

                if (opt.eventFocus) {
                    initialLeftLine = leftMarginCorrection - (opt.subEventWidth * (opt.eventFocus - 1));
                    initialLeftContent = opt.eventWidth * (opt.eventFocus - 1);
                    lineSub.css('margin-left', initialLeftLine);
                    content.css('margin-left', -initialLeftContent);
                } else {
                    lineSub.css('margin-left', leftMarginCorrection);
                }
                height = rootContainer.height() - lineScroll.height() - 61;
                contentList.find('.view-postit').each(function(index){
                    var currentHeight = $(this).height();
                    if (height < currentHeight){
                        height = currentHeight;
                    }
                });
                contentList.find('.view-postit').css('height',height);

                var movePanels = function (delta, speed) {
                    var currentLeft = parseInt(lineSub.css('margin-left').replace('px', ''));
                    var maxRight = -(lineSub.width()) + highlightWidth + leftMarginCorrection * 2 - 10;
                    var targetLeft = currentLeft;
                    var maxSlide = lineSub.width() - leftMarginCorrection;
                    var cWidth = content.width();

                    targetLeft = (currentLeft + (delta*speed));
                    if (targetLeft >= leftMarginCorrection)
                        targetLeft = leftMarginCorrection;
                    else if (targetLeft <= maxRight)
                        targetLeft = maxRight;
                    lineSub.css('margin-left', (targetLeft) + 'px');

                    // Translating each movement of the slider to the line-content
                    targetLeftTranslated = targetLeft - leftMarginCorrection;
                    content.css('margin-left', (targetLeftTranslated * cWidth / maxSlide) + 'px');
                };

                lineScroll.mousedown(function(e, ui) {
                    var currentLeft = parseInt(lineSub.css('margin-left').replace('px', ''));
                    var currentMouseLeft = e.pageX;
                    var maxRight = -(lineSub.width()) + highlightWidth + leftMarginCorrection * 2 - 10;
                    var targetLeft = currentLeft;
                    var maxSlide = lineSub.width() - leftMarginCorrection;
                    var cWidth = content.width();
                    $(document.body).bind('mousemove.eventline', function(e) {
                        leftDiff = currentMouseLeft - e.pageX;
                        targetLeft = (currentLeft - leftDiff);
                        if (targetLeft >= leftMarginCorrection)
                            targetLeft = leftMarginCorrection;
                        else if (targetLeft <= maxRight)
                            targetLeft = maxRight;

                        lineSub.css('margin-left', (targetLeft) + 'px');

                        /* Translating each movement of the slider to the line-content */
                        targetLeftTranslated = targetLeft - leftMarginCorrection;
                        content.css('margin-left', (targetLeftTranslated * cWidth / maxSlide) + 'px');
                        //$('.event-line-limiter').scrollLeft((targetLeftTranslated * cWidth / maxSlide) + 'px');
                    });
                    $(document.body).bind('mouseup.eventline', function(e) {
                        $(document.body).unbind('.eventline');
                    });
                });

                $(document).bind('keydown.eventline', 'right', function (e){
                    movePanels(1, -opt.scrollSpeed);
                    e.stopPropagation();
                    return false;
                });
                $(document).bind('keydown.eventline', 'left', function (e){
                    movePanels(1, opt.scrollSpeed);
                    e.stopPropagation();
                    return false;
                });
                $('.event-line-scroll').bind('mousewheel.eventline', function(e, delta) {
                    if($.browser.opera)
                        delta = event.wheelDelta / 120;
                    movePanels(delta, opt.scrollSpeed);
                    e.stopPropagation();
                    return false;
                });


            }else{
                lineScroll.hide();
                height = rootContainer.height() - 61;
                contentList.find('.view-postit').each(function(index){
                    var currentHeight = $(this).height();
                    if (height < currentHeight){
                        height = currentHeight;
                    }
                });
                contentList.find('.view-postit').css('height',height);
            }
        };

        $(window).bind('resize.eventline', function (e){
            size();
        }).trigger('resize');

        //init();
        size();

    };
    $.fn.eventline.defaults = {
        rootContainer:document,
        eventWidth:220,
        subEventWidth:100,
        scrollSpeed:20
    };
    $.eventline = {
        eventFocus: function(target, params) {
            data = $(target).data();
            var highlightWidth = (data.subEventWidth / data.eventWidth) * data.containerWidth;
            var leftMarginCorrection = data.containerWidth / 2 - highlightWidth / 2;
            var nbEventsToShift = params[1];
            initialLeftLine = leftMarginCorrection - (data.subEventWidth * nbEventsToShift);
            initialLeftContent = data.eventWidth * nbEventsToShift;
            $('.event-line-sub').css('margin-left', initialLeftLine);
            $('.event-line-content').css('margin-left', -initialLeftContent);
        },
        clear: function (target, params) {
            $(document).unbind('.eventline');
            $(document.body).unbind('.eventline');
            $(window).unbind('.eventline');
            $('.event-line-scroll').unbind('.eventline');
        }
    };
}(jQuery));
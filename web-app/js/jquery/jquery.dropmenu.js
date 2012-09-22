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
 */

(function($) {

    var helper = {},
            IE = $.browser.msie && /MSIE\s(5\.5|6\.)/.test(navigator.userAgent),
            _isHover = false,
            _current = "",
            _oldHover = "";

    $.dropmenu = {
        defaults: {
            'id':       'dropmenu',
            'hideOut':  false,
            'hover':    'dropmenu-hover',
            'content':  'dropmenu-content',
            'top':      24,
            'delay':    500,
            'left':     0,
            'yoffset':  0,
            'noWindows':false,
            'autoClick':true,
            'showOnCreate':false
        }
    };

    $.fn.extend({

                dropMenuCreated:function() {
                    if (this.data('created')) {
                        return this.data('created');
                    } else {
                        return false;
                    }
                },

                dropmenu: function(settings) {

                    settings = $.extend({}, $.dropmenu.defaults, settings);
                    createHelper(settings);
                    this.data('created', true);

                    var menu = this.each(
                            function() {
                                var elt = $(this);
                                var _ul = $('.' + settings.content, $(this));
                                elt.css('cursor', 'pointer');
                                var _settings = settings;
                                elt.removeClass(settings.hover);
                                this.dropContent = _ul;
                                this.dropContent.data('oldParent', elt);
                                this.currentMenu = elt;
                                this.settings = settings
                                this.dropContent.data('showHandler', function(event) {
                                    if (elt == _current) {
                                        _isHover = true;
                                        return;
                                    }
                                    mask(settings);
                                    _isHover = true;
                                    _oldHover = elt;
                                    show(this.dropContent, elt, settings, event, true);
                                    _ul.show();
                                    _current = elt;
                                });
                                this.dropContent.data('hideHandler', function(event) {
                                    if (!_isHover) {
                                        mask(settings);
                                        _ul.data('oldParent').prepend(_ul);
                                        _ul.hide();
                                        hide();
                                    }

                                });
                                _ul.hide();
                            }).hover(function(event) {

                                this.dropContent.data('showHandler').call(this, event);
                            },
                            function(event) {
                                _isHover = false;
                                var dropContent = this.dropContent;
                                $(this).delay(this.settings.delay, function() {
                                    if (dropContent.data('hideHandler') != undefined) {
                                        dropContent.data('hideHandler').call(this, event);
                                    }
                                });
                            }
                    );

                    if (settings.showOnCreate) {
                        this.mouseover();
                    }
                    return menu;
                }
            });

    $.fn.extend({
                searchmenu: function(settings) {
                    settings = $.extend({}, $.dropmenu.defaults, settings);
                    createHelper(settings);
                    var menu =  this.each(
                            function() {
                                var elt = $(this);
                                var _ul = $('.' + settings.content, $(this));

                                elt.css('cursor', 'pointer');
                                elt.removeClass(settings.hover);

                                this.dropContent = _ul;
                                this.currentMenu = $(this);
                                this.currentInput = $('div input', this.dropContent);
                                this.settings = settings;
                                this.dropContent.data('oldParent', elt);
                                this.dropContent.data('showHandler', function(event) {
                                    mask(settings);
                                    _isHover = true;
                                    _oldHover = elt;
                                    this.currentInput.click(function() {
                                        this.select();
                                    });
                                    show(this.dropContent, elt, settings, event, true);
                                    _ul.show();
                                    $(_ul).find('div>input').focus();
                                });
                                this.dropContent.data('hideHandler', function(event) {
                                    if (!_isHover) {
                                        mask(settings);
                                        _ul.data('oldParent').prepend(_ul);
                                        _ul.hide();
                                        hide();
                                    }
                                });
                                _ul.hide();
                            }).hover(function(event) {
                                this.dropContent.data('showHandler').call(this, event);
                            },
                            function(event) {
                                _isHover = false;
                                var dropContent = this.dropContent;
                                $(this).delay(this.settings.delay, function() {
                                    if (dropContent.data('hideHandler') != undefined) {
                                        dropContent.data('hideHandler').call(this, event);
                                    }
                                });
                            }
                    );

                    if (settings.showOnCreate) {
                        this.mouseover();
                    }
                    return menu;
                }
            });

    function mask(settings) {
        if (this.currentMenu) {
            this.currentMenu.removeClass(settings.hover);
        }
        if (_oldHover) {
            _oldHover.removeClass(settings.hover);
        }
    }

    function show(context, menu, settings, event, right) {
        var wWindow = $(window).width();
        var hWindow = $(window).height();

        var left = menu.offset().left;

        if (helper.body) {
            var existing = helper.body.find(">:first-child");
            if (existing.data('hideHandler') != undefined) {
                _isHover = false;
                existing.data('hideHandler').call(existing[0], event);
            }
        }
        helper.body.prepend(context[0]);
        if (right) {
            left -= settings.left;
        } else {
            left += settings.left;
        }
        helper.body.fadeIn(100);
        var top = menu.parent().offset().top + settings.top + settings.yoffset;

        if (settings.noWindows == false) {
            var f = $(context).height() + top + 20;
            if (f > hWindow) {
                top -= ((settings.top) + $(context).height() - settings.yoffset);
            }

            helper.parent.css('z-index', '999');
            var e = $(context).width() + left + 20;
            if (e > wWindow) {
                left -= $(context).width() - 10;
            }
        }

        helper.parent.css('left', left);
        helper.parent.css('top', top);

        menu.addClass(settings.hover);

        if (settings.autoClick) {
            helper.body.click(function() {
                mask(settings);
                hide();
            });
            $('a', context).click(function() {
                _isHover = false;
                if (context.data('hideHandler') != undefined) {
                    context.data('hideHandler').call(context, event);
                }
            });
        }

        context.hover(function(event) {
            _isHover = true;
        }, function(event) {
            _isHover = false;
            context.delay(settings.delay, function() {
                if (context.data('hideHandler') != undefined) {
                    context.data('hideHandler').call(context, event);
                }
            });
        });
    }

    function hide() {
        if (_isHover) {
            return;
        }
        _current = "";
        //helper.parent.fadeOut(500);
    }

    function createHelper(settings) {
        var contentClass = 'dropmenu-content';

        var str = '<div id="' + settings.id + '">';
        str += '</div>';

        if (helper.parent)
            return;

        helper.parent = $(str)
                .appendTo($('body'))
                .hide();

        helper.parent.css('position', 'absolute');

        helper.body = helper.parent;
    }

    function settings(element) {
        return $.data(element, "dropmenu");
    }

    $.fn.delay = function(delay, method) {
        var node = this;

        if (node.length) {
            if (node[0]._timer_) clearTimeout(node[0]._timer_);
            node[0]._timer_ = setTimeout(function() {
                method.call(node);
            }, delay);
        }
        return this;
    };


})(jQuery);

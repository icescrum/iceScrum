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
 * Damien Vitrac (damien@oocube.com)
 *
 */

(function($) {

    var helper = {}

	$.input = {
		defaults: {
            'className': 'input'
		}
	};

	$.fn.extend({
		input: function(settings) {

			settings = $.extend({}, $.input.defaults, settings);

			return this.each(function() {
				var elt = $(this);
                var input = $(this).find('input, textarea');
                
                input.focus(function(){
                    elt.addClass(settings.className + "-focus");
                }).blur(function(){
                    elt.removeClass(settings.className + "-focus");
                });
            });
		}
	});

    $.fn.extend({
		inputFocus: function(settings) {

			settings = $.extend({}, $.input.defaults, settings);

			return this.each(function() {
				var elt = $(this);
                var input = $(this).find('input, textarea');
                elt.addClass(settings.className + "-focus");
                input.focus();
            });
		}
	});


})(jQuery);

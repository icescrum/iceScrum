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
 * Stéphane Maldini (stephane.maldini@icescrum.com)
 *
 */
(function($) {
    $.constbrowser = {

        defaults:{
            'dropmenuleft': 0
        },
        settings:{},

        getDropMenuTopLeft:function() {
            var o = $.constbrowser.getConstBrowser();
            return o.dropmenuleft;
        },

        getConstBrowser:function() {
            var o = $.constbrowser.defaults;
            if ($.browser.msie)
            {
                if (jQuery.browser.version.substr(0,1)=="7")
                {
                    o = $.constbrowser.ie7;
                }
                else if (jQuery.browser.version.substr(0,1)=="6")
                {
                    o = $.constbrowser.ie6;
                }

            }
            return o;
        }
    };

    $.constbrowser.ie7 = {
        'dropmenuleft': 70
    };

    $.constbrowser.ie6 = {
        'dropmenuleft': 70
    };

})(jQuery);




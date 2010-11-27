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
    jQuery.extend($.icescrum, {
        postit:function(params) {
            var self = this;
            return {
                target:self,
                // Return the ELEMENT ID of the targeted postit
                id:function() {
                    if ($(this.target).hasClass('postit') || $(this.target).hasClass('postit-rect')) {
                        var elem = $(this.target).attr('elemId');
                        if(elem){
                            return elem;
                        }else{
                            return false;
                        }
                    }
                    return false;
                },
                // Return the ELEMENT ID of the targeted postits formated for a HTTP Request (id=1&id=2...)
                requestIds:function(idParam) {
                    if ($(this.target).hasClass('postit') || $(this.target).hasClass('postit-rect')  || $(this.target).hasClass('table-line')
                            || $(this.target).hasClass('identifiable')) {
                        var _idParam = idParam ? idParam : 'id';
                        var ids = [];
                        $.each(this.target, function(key, val) {
                            var elem = $(this).attr('elemId');
                            if(elem){
                                ids.push(_idParam+'=' + elem);
                            }
                        });
                        return ids.join('&');
                    }
                    return false;
                }
            };
        }
    });
})(jQuery);
/*
 * Copyright (c) 2014 Kagilum SAS.
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
 * Nicolas Noullet (nnoullet@kagilum.com)
 *
 */
(function($) {
    $.extend($.icescrum, {
        release:{
            add:function() {
                var select = $('#selectOnTimeline');
                if (select.length) {
                    select.append($('<option></option>').attr("id",this.id).val($.icescrum.jsonToDate(this.startDate).getTime()).html(this.name));
                    select.trigger("change");
                }
                var release = $('#selectOnReleasePlan');
                if (release.length) {
                    release.append($('<option></option>').val(this.id).html(this.name));
                    release.trigger("change");
                }
            },

            update:function() {
                var select = $('#selectOnTimeline');
                if (select.length) {
                    select.find('option[id='+this.id+']').val($.icescrum.jsonToDate(this.startDate).getTime()).html(this.name);
                    select.trigger("change");
                }
                var release = $('#selectOnReleasePlan');
                if (release.length) {
                    release.find('option[value='+this.id+']').html(this.name);
                    release.trigger("change");
                }
            },

            remove:function() {
                var select = $('#selectOnTimeline');
                if (select.length) {
                    select.find('option[id='+this.id+']').remove();
                    select.trigger("change");
                }
                var release = $('#selectOnReleasePlan');
                if (release.length) {
                    release.find('option[value='+this.id+']').remove();
                    release.trigger("change");
                }
            },

            close:function() {
            },

            activate:function() {
            },

            vision:function() {
                if (jQuery('#panel-vision-' + this.id).length) {
                    jQuery('#panel-vision-' + this.id + ' .panel-box-content').load(jQuery.icescrum.o.baseUrl + 'textileParser', {data:this.vision,withoutHeader:true,truncate:1000});
                }
            }
        }
    })
})($);
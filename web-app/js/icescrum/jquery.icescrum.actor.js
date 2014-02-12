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
(function ($) {

    $.extend($.icescrum, {
        actor: {

            data: [],
            bindings: [],
            config: {
                actors: {
                    sort: function(item) {
                        return Object.byString(item, this.sortOn);
                    }
                }
            },
            restUrl: function() {
                return $.icescrum.o.baseUrlSpace + 'actor/';
            },
            'delete': function(data, status, xhr, element) {
                _.each(element.data('ajaxData').id, function(item) {
                    $.icescrum.object.removeFromArray('actor', {id:item});
                });
                $.icescrum.actor.createForm();
            },
            onSelectableStop: function(event, ui) {
                var selectable = $('.window-content.ui-selectable');
                var container = $('#contextual-properties');
                var id = selectable.data('current');
                if (!id || id.length == 0) {
                    $.icescrum.actor.createForm();
                } else if (id.length > 1) {
                    var el = $.template('tpl-multiple-actors', {actor:_.findWhere($.icescrum['actor'].data, {id:_.last(id)}), ids:id});
                    container.html(el);
                } else if (id.length == 1) {
                    $.icescrum.object.dataBinding.apply(container.parent(), [{
                        type:'actor',
                        tpl:'tpl-edit-actor',
                        watchedId:id[0],
                        watch:'item',
                        selector:'#contextual-properties'
                    }]);
                }
                manageAccordion(container);
                container.accordion("option", "active", 0);
                attachOnDomUpdate(container);
            },
            createForm: function() {
                var container = $('#contextual-properties');
                var el = $.template('tpl-new-actor');
                container.html(el);
                manageAccordion(container);
                attachOnDomUpdate(container);
                container.find('input:first:visible').focus();
            },
            afterSave: function(data) {
                var selectable = $('.window-content.ui-selectable');
                selectable.find('div[data-elemid="'+data.id+'"]').addClass('ui-selected');
                var stop = selectable.selectableScroll("option", "stop");
                if (stop) {
                    stop({target:selectable});
                }
            }
        }
    });
})($);
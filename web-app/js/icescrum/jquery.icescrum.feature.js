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
        feature: {
            data: [],
            bindings: [],
            config: {
                features: {
                    sort: function(item) {
                        return Object.byString(item, this.sortOn);
                    }
                }
            },
            formatters: {
                state:function(feature){
                    return $.icescrum.feature.states[feature.state];
                },
                type: function(feature) {
                    return $.icescrum.feature.types[feature.type];
                }
            },
            restUrl: function() {
                return $.icescrum.o.baseUrlSpace + 'feature/';
            },
            'delete': function(data, status, xhr, element) {
                _.each(element.data('ajaxData').id, function(item) {
                    $.icescrum.object.removeFromArray('feature', {id:item});
                });
                $.icescrum.feature.createForm();
            },
            onSelectableStop: function(event, ui) {
                var selectable = $('.window-content.ui-selectable');
                var container = $('#contextual-properties');
                var id = selectable.data('current');
                if (!id || id.length == 0) {
                    $.icescrum.feature.createForm();
                } else if (id.length > 1) {
                    var el = $.template('tpl-multiple-features', {feature:_.findWhere($.icescrum['feature'].data, {id:_.last(id)}), ids:id});
                    container.html(el);
                } else if (id.length == 1) {
                    $.icescrum.object.dataBinding.apply(container.parent(), [{
                        type:'feature',
                        tpl:'tpl-edit-feature',
                        watchedId:id[0],
                        watch:'item',
                        selector:'#contextual-properties'
                    }]);
                }
                container.accordion("option", "active", 0);
                attachOnDomUpdate(container);
            },
            createForm: function() {
                var container = $('#contextual-properties');
                var el = $.template('tpl-new-feature');
                container.html(el);
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
            },
            formatSelect:function(object, container){
                if (container.hasClass('select2-container') && object.val() != ''){
                    container.find('.select2-chosen').css('border-left','4px solid '+object.data('color'));
                    return object.val();
                } else {
                    container.css('border-left','4px solid '+object.color);
                    return object.text;
                }
            }
        }
    });

})($);
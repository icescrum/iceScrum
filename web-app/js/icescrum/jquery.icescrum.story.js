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
        story:{
            STATE_SUGGESTED:1,
            STATE_ACCEPTED:2,
            STATE_ESTIMATED:3,
            STATE_PLANNED:4,
            STATE_INPROGRESS:5,
            STATE_DONE:7,
            TYPE_USER_STORY:0,
            TYPE_DEFECT:2,
            TYPE_TECHNICAL_STORY:3,
            i18n : {
                stories:'stories',
                points:'points'
            },
            data:[],
            bindings:[],
            restUrl: function(){ return $.icescrum.o.baseUrlSpace + 'story/'; },

            onDropFeature:function(event, ui){
                if (ui.helper){
                    $.ajax({
                        url: $.icescrum.story.restUrl()+'/'+$(this).data('elemid'),
                        type: 'PUT',
                        success: function(data){
                            $.icescrum.object.addOrUpdateToArray('story',data);
                        }
                    });
                }
            },
            onDropToSandbox:function(event, ui){
                if (ui.draggable){
                    $.ajax({
                        url: $.icescrum.story.restUrl()+'/'+$(this).data('elemid'),
                        data: {'story.state': $.icescrum.story.STATE_SUGGESTED },
                        type: 'PUT',
                        success: function(data){
                            $.icescrum.object.addOrUpdateToArray('story', data);
                        }
                    });
                }
            },

            onSelectableStop:function(event, ui){
                var selectable = $('.window-content.ui-selectable');
                var container = $('#contextual-properties');
                var id = selectable.data('current');
                var story;

                //no selection
                if (!id || id.length == 0){
                    $.icescrum.story.createForm(false, container);
                }
                //multi selection
                else if (id.length > 1){
                    var el = $.template('story-multiple', {story: _.findWhere($.icescrum['story'].data, {id:_.last(id)}), ids:id});
                    container.html(el);
                }
                //one selected
                 else if (id.length == 1) {
                    el = $.template('story-details', {story:  _.findWhere($.icescrum['story'].data, {id:_.last(id)})});
                    container.html(el);
                }
                attachOnDomUpdate(container);
            },

            sortAndOrderOnSandbox:function(order){
                var $sandbox = $('#backlog-layout-window-sandbox');
                var ids = [];

                //preserve selected elements
                _.each($sandbox.find('.ui-selected'), function(item){
                    ids.push($(item).data('elemid'));
                });

                var config = $.icescrum.object.removeBinding('story', $sandbox);
                config.sortOn = $('#sort').data('value');
                if (order){
                    var $sort = $(order).find('span:first');
                    if ($sort){
                        config.reverse = !config.reverse;
                        $sort.toggleClass('glyphicon-sort-by-attributes');
                        $sort.toggleClass('glyphicon-sort-by-attributes-alt');
                    }
                }
                $.icescrum.object.dataBinding(config);

                //restore selected elements
                _.each($sandbox.find('.ui-selectee'), function(item){
                    if (_.contains(ids, $(item).data('elemid'))) {
                        $(item).addClass('ui-selected');
                    }
                });
            }
        }
    });

})($);
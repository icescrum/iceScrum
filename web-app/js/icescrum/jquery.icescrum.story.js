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
            timerDuplicate:null,
            termDuplicate:null,
            data:[],
            bindings:[],
            restUrl: function(){ return $.icescrum.o.baseUrlSpace + 'story/'; },

            proxyProperties:{
                activities:function(refresh){
                    //get fresh object from data
                    var story = _.findWhere($.icescrum['story'].data, {id:this.id});
                    if (refresh){
                        delete story._activities;
                    }
                    if (!story.hasOwnProperty('_activities')){
                        $.get($.icescrum.story.restUrl()+story.id+'/activities', function(data){
                            //get synced object from data array
                            var _story = _.findWhere($.icescrum['story'].data, {id:story.id});
                            if (_story){
                                _story._activities = data;
                            }
                        });
                        //state loading
                        story._activities = false;
                    }
                    return story._activities;
                },
                comments:function(refresh){
                    //get fresh object from data
                    var story = _.findWhere($.icescrum['story'].data, {id:this.id});
                    if (refresh){
                        delete story._comments;
                    }
                    if (!story.hasOwnProperty('_comments')){
                        $.get($.icescrum.story.restUrl()+ story.id+'/comment', function(data){
                            //get synced object from data array
                            var _story = _.findWhere($.icescrum['story'].data, {id:story.id});
                            if (_story){
                                _story._comments = data;
                            }
                        });
                        //state loading
                        story._comments = false;
                    }
                    return story._comments;
                }
            },

            config: {
                sandbox: {
                    filter: { state : 1 },
                    sort:function(item){ return Object.byString(item, this.sortOn); }
                },
                backlog: {
                    filter: { state : 3 }
                },
                actors: { // TODO WARNING experimental config
                    filter: function(item) {
                        var actorStoryUids = _.find($.icescrum.story.bindings, { config: "actors" }).uids;
                        return _.contains(actorStoryUids, item.uid);
                    }
                }
            },

            formatters:{
                state:function(story){
                    return story.state > 1 ? $.icescrum.story.states[story.state].value : '';
                },
                description:function(story) {
                    return story.description ? story.description.formatLine().replace(/A\[(.+?)-(.*?)\]/g, '<a href="#actor/$1">$2</a>') : "";
                },
                type:function(story) {
                    if (story.type == $.icescrum.story.TYPE_DEFECT && story.affectVersion){
                        return $.icescrum.story.types[story.type]+" (version:"+" "+story.affectVersion+")";
                    } else {
                        return $.icescrum.story.types[story.type];
                    }
                }
            },

            'delete':function(data, status, xhr, element){
                _.each(element.data('ajaxData').id, function(item){ $.icescrum.object.removeFromArray('story', {id:item}); });
            },

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
            createForm:function(template, container){
                container = container ? container : $('#contextual-properties');
                var el;
                if (template){
                    $.get($.icescrum.story.restUrl()+'templateEntries', {'template':template}, function(data){
                        data.name = $('input[name="story.name"]', container).val();
                        el = $.template('story-new', {story:data, template:template});
                    });
                } else {
                    el = $.template('story-new', {story:{}, template:template});
                }
                container.html(el);
                attachOnDomUpdate(container);
                container.find('input:first:visible').focus();
            },
            afterSave:function(data){
                var selectable = $('.window-content.ui-selectable');
                selectable.find('div[data-elemid="'+data.id+'"]').addClass('ui-selected');
                var stop = selectable.selectableScroll( "option" , "stop");
                if (stop){
                    stop({target:selectable});
                }
            },
            findDuplicate:function(term) {
                if (term == null || term.length <= 5) {
                    this.termDuplicate = null;
                    $('.duplicate').html('');
                } else if (term.length >= 5 && this.termDuplicate != term.trim()){
                    //TODO maybe local search ?
                    this.termDuplicate = term.trim();
                    clearTimeout(this.timerDuplicate);
                    this.timerDuplicate = setTimeout(function() {
                        $.get($.icescrum.story.restUrl()+'findDuplicate',{term:term.trim()})
                            .success(function(data){
                                $('.duplicate').html(data ? data : '');
                            });
                    }, 500);
                }
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
            },
            formatSelect:function(object, container){
                var type = parseInt(object.id);
                var icon = '';
                if (type == $.icescrum.story.TYPE_DEFECT){
                    icon = 'fa fa-bug';
                } else if (type == $.icescrum.story.TYPE_TECHNICAL_STORY){
                    icon = 'fa fa-cogs';
                } else {
                    icon = '';
                }
                return '<i class="' + icon + '"></i> ' + object.text;
            }
        }
    });

})($);
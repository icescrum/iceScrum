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
(function(){
    var cache = {};
    $.template = function(name, data){
        var template = cache[name];

        if (!template){
            template = $('script[type="text/icescrum-template"]#' + name).html();
            cache[name] = template;
        }

        return _.template(template, data || {});
    };
})();

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
            config: {
                sandbox: {
                    filter: function(item){ return item.state == this.STATE_SUGGESTED },
                    sort:function(item){ return Object.byString(item, this.sortOn); }
                },
                backlog: {
                    filter: function(item){ return item.state == this.STATE_ESTIMATED }
                }
            },
            formatters:{
                state:function(story){
                    return story.state > 1 ? $.icescrum.story.states[story.state] : '';
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

            restUrl: function(){ return $.icescrum.o.baseUrlSpace + 'story/'; },

            'delete':function(data, status, xhr, element){
                _.each(element.data('ajaxData').id, function(item){ $.icescrum.object.removeFromArray('story', {id:item}); });
            },

            onDropFeature:function(event, ui){
                if (ui.helper){
                    $.post($.icescrum.story.restUrl()+'update/'+$(this).data('elemid'), { 'story.feature.id':ui.helper.data('elemid') },
                        function(data){
                            $.icescrum.object.addOrUpdateToArray('story',data);
                        }
                    );
                }
            },
            onDropToSandbox:function(event, ui){
                if (ui.draggable){
                    $.post($.icescrum.story.restUrl()+'update/'+ui.draggable.data('elemid')+'?story.state='+ $.icescrum.story.STATE_SUGGESTED,
                        function(data){
                            $.icescrum.object.addOrUpdateToArray('story',data);
                        }
                    );
                }
            },

            onSelectableStop:function(event, ui){
                var selectable = $('.window-content.ui-selectable');
                var container = $('#contextual-properties');

                var id = selectable.data('current');
                //no selection
                if (!id || id.length == 0){
                    $.icescrum.story.createForm(false, container);
                }
                //multi selection
                else if (id.length > 1){
                    var el = $.template('tpl-multiple-stories', {story:_.findWhere($.icescrum['story'].data, {id:_.last(id)}), ids:id});
                    container.html(el);
                }
                //one selected
                 else if (id.length == 1) {
                    $.icescrum.object.dataBinding.apply(container.parent(), [{
                        type:'story',
                        tpl:'tpl-edit-story',
                        watchedId:id[0],
                        watch:'item',
                        selector:'#contextual-properties'
                    }]);
                }
                //update container
                manageAccordion(container);
                container.accordion("option", "active", 0);
                attachOnDomUpdate(container);
            },

            createForm:function(template, container){
                container = container ? container : $('#contextual-properties');
                var el;
                if (template){
                    $.get($.icescrum.story.restUrl()+'templateEntries', {'template':template}, function(data){
                        data.name = $('input[name="story.name"]', container).val();
                        el = $.template('tpl-new-story', {story:data, template:template});
                        container.html(el);
                        manageAccordion(container);
                        attachOnDomUpdate(container);
                    });
                } else {
                    el = $.template('tpl-new-story', {story:{}, template:template});
                    container.html(el);
                    manageAccordion(container);
                    attachOnDomUpdate(container);
                }
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

            sortOnSandbox:function(select){
                var $sandbox = $('#backlog-layout-window-sandbox');
                var ids = [];
                _.each($sandbox.find('.ui-selected'), function(item){ ids.push($(item).data('elemid')); });
                var config = $.icescrum.object.removeBinding('story', $sandbox);
                config.sortOn = $(select).val();
                config.reverse = true;
                $.icescrum.object.dataBinding(config);
                _.each($sandbox.find('.ui-selectee'), function(item){
                    if (_.contains(ids, $(item).data('elemid'))) {
                        $(item).addClass('ui-selected');
                    }
                });
            },




























            //TODO remove at and of refactoring
            templates:{
                sandbox:{
                    selector:'div.postit-story',
                    id:'postit-story-sandbox-tmpl',
                    view:'#backlog-layout-window-sandbox',
                    remove:function(tmpl) {
                        var story =  $(tmpl.view+' .postit-story[data-elemid=' + this.id + ']');
                        this.rank = story.index() + 1;
                        this.selected = story.hasClass('ui-selected');
                        story.remove();
                        $('#stories-sandbox-size').html($(tmpl.view+' .postit-story, '+tmpl.view+' .table-line').size());
                    },
                    constraintTmpl:function() {
                        return this.state == $.icescrum.story.STATE_SUGGESTED;
                    },
                    window:'#window-content-sandbox',
                    afterTmpl:function(tmpl, container, newObject) {
                        if (this.rank){
                            $.icescrum.postit.updatePosition(tmpl.selector, newObject, this.rank, container);
                        }
                        $('#stories-sandbox-size').html($(tmpl.view+' .postit-story, '+tmpl.view+' .table-line').size());
                    }
                },
                sandboxRight: {
                    selector:"#right-story-properties",
                    id:"right-story-sandbox-tmpl",
                    view:"#right-story-container",
                    noblank:true,
                    select:function(template) {
                        var tmpl = $.icescrum.story.templates[template];
                        var view = $(tmpl.view);
                        var existing = $(tmpl.selector, view);
                        if (existing.length > 0) {
                            $.icescrum.story.remove.apply(this, [template]);
                        }
                        var newStory = $('#right-story-new', view);
                        $('input', newStory).val('');
                        newStory.hide();
                        $.icescrum.story.add.apply(this, [template]);
                        $("#contextual-properties.ui-accordion[data-accordion=true]").accordion("option", "active", 0);
                    },
                    unselect:function(template) {
                        $.icescrum.story.remove.apply(this, [template]);
                    },
                    remove:function(tmpl) {
                        var view = $(tmpl.view);
                        $(tmpl.selector, view).remove();
                        $('#right-story-new', view).show();
                    },
                    update:function(template) {
                        var tmpl = $.icescrum.story.templates[template];
                        var alreadyPresent = $(tmpl.selector + '[data-elemid=' + this.id + ']');
                        if (alreadyPresent.length > 0) {
                            $.icescrum.story.remove.apply(this, [template]);
                            $.icescrum.story.add.apply(this, [template]);
                        }
                    }
                },
                sandboxWidget:{
                    selector:'li.postit-row-story',
                    id:'postit-row-story-sandbox-tmpl',
                    view:'#backlog-layout-widget-sandbox',
                    constraintTmpl:function() {
                        return this.state == $.icescrum.story.STATE_SUGGESTED;
                    },
                    remove:function(tmpl) {
                        $(tmpl.view+' .postit-row-story[data-elemid=' + this.id + ']:visible').remove();
                        if ($(tmpl.selector+':visible', $(tmpl.view)).length == 0) {
                            $(tmpl.view).hide();
                            $(tmpl.window + ' .box-blank').show();
                        }
                    },
                    afterTmpl:function(tmpl, container, newObject){
                        if (this.dependsOn){
                            newObject.attr('data-dependsOn',this.dependsOn.id);
                        }
                    },
                    window:'#widget-content-sandbox'
                },
                backlogWindow:{
                    selector:function() {
                        return $.icescrum.getDefaultView() == 'postitsView' ? 'div.postit-story' : 'tr.table-line';
                    },
                    id:function() {
                        return $.icescrum.getDefaultView() == 'postitsView' ? 'postit-story-backlog-tmpl' : 'table-row-story-backlog-tmpl';
                    },
                    view:function() {
                        return $.icescrum.getDefaultView() == 'postitsView' ? '#backlog-layout-window-backlog' : '#story-table';
                    },
                    constraintTmpl:function() {
                        return this.state == $.icescrum.story.STATE_ACCEPTED || this.state == $.icescrum.story.STATE_ESTIMATED;
                    },
                    remove:function(tmpl) {
                        if ($.icescrum.getDefaultView() == 'tableView') {
                            var tableline = $(tmpl.view+' tr.table-line'+'[data-elemid=' + this.id + ']');
                            this.oldRank = tableline.data('rank');
                            tableline.remove();
                            if (!this.rank && this.oldRank && !$.icescrum.story.templates['backlogWindow'].constraintTmpl()){
                                $.icescrum.postit.updateRankAndVersion(tmpl.selector, tmpl.view, this.oldRank);
                            }
                            $(tmpl.view).trigger("update");
                        }else{
                            $(tmpl.window+' '+tmpl.selector+'[data-elemid=' + this.id + ']').remove();
                        }
                        $.icescrum.story.backlogTitleDetails();
                    },
                    window:'#window-content-backlog',
                    afterTmpl:function(tmpl, container, newObject) {
                        $.icescrum.postit.updatePosition(tmpl.selector, newObject, this.rank, container);
                        $.icescrum.story.backlogTitleDetails();
                        if ($.icescrum.getDefaultView() == 'tableView') {
                            $('div[name=rank]', $(newObject)).text(this.rank);
                            if(this.oldRank != this.rank) {
                                $.icescrum.postit.updateRankAndVersion(tmpl.selector, tmpl.view, this.oldRank, this.rank, this.id);
                            }
                            $(tmpl.view).updateTableSorter();
                        }
                    }
                },
                backlogWidget:{
                    selector:'li.postit-row-story',
                    id:'postit-row-story-backlog-tmpl',
                    view:'#backlog-layout-widget-backlog',
                    constraintTmpl:function() {
                        return this.state == $.icescrum.story.STATE_ESTIMATED;
                    },
                    remove:function(tmpl) {
                        $(tmpl.view+' .postit-row-story[data-elemid=' + this.id + ']:visible').remove();
                        if ($(tmpl.selector+':visible', $(tmpl.view)).length == 0) {
                            $(tmpl.view).hide();
                            $(tmpl.window + ' .box-blank').show();
                        }
                    },
                    afterTmpl:function(tmpl, container, newObject){
                        if (this.dependsOn){
                            newObject.attr('data-dependsOn',this.dependsOn.id);
                        }
                    },
                    window:'#widget-content-backlog'
                },
                releasePlan:{
                    selector:'div.postit-story',
                    id:'postit-story-releasePlan-tmpl',
                    window:'#window-content-releasePlan',
                    view:function() {
                        return this.parentSprint ? '#backlog-layout-plan-releasePlan' + '-' + this.parentSprint.id : '';
                    },
                    remove:function(tmpl) {
                        $(tmpl.window+' .postit-story[data-elemid=' + this.id + ']').remove();
                    },
                    constraintTmpl:function() {
                        return this.state >= $.icescrum.story.STATE_PLANNED;
                    },
                    noblank:true,
                    afterTmpl:function(tmpl, container, newObject) {
                        $.icescrum.postit.updatePosition(tmpl.selector, newObject, this.rank, container);
                        $.event.trigger('sprintMesure_sprint', this.parentSprint);
                    }
                },
                sprintPlan:{
                    selector:'tr.row-story',
                    id:'postit-story-sprintPlan-tmpl',
                    view:function() {
                        var storyType = this.state < $.icescrum.story.STATE_DONE ? 'story' : 'storyDone';
                        return this.parentSprint ? '#kanban-sprint' + '-' + this.parentSprint.id + ' tbody[type=' + storyType + ']' : '';
                    },
                    remove:function() {
                        $('.kanban .row-story[data-elemid=' + this.id + ']').remove();
                    },
                    constraintTmpl:function() {
                        return this.state >= $.icescrum.story.STATE_PLANNED;
                    },
                    window:'#window-content-sprintPlan',
                    afterTmpl:function(tmpl, container, newObject, beforeData) {
                        $.icescrum.postit.updatePosition(tmpl.selector, newObject, this.rank, container);
                        if (this.state == $.icescrum.story.STATE_DONE) {
                            newObject.appendTo($(tmpl.view));
                        } else {
                            $.icescrum.liveSortable();
                        }
                        if ($(tmpl.view).is(':hidden')) {
                            $(tmpl.view).show();
                        }
                        $.event.trigger('update_task', [this.tasks]);
                        $.event.trigger('sprintMesure_sprint', this.parentSprint);
                    }
                }
            },

            add:function(template, append) {
                $(this).each(function() {
                    $.icescrum.story.manageDependencies.apply(this);
                    $.icescrum.addOrUpdate(this, $.icescrum.story.templates[template], $.icescrum.story._postRendering, append);
                });
            },

            update:function(template, append) {
                $(this).each(function() {
                    $.icescrum.story.manageDependencies.apply(this);
                    $.icescrum.story.remove.apply(this, [template, true]);
                    $.icescrum.story.add.apply(this, [template, append]);
                });
            },

            remove:function(template, notFull) {
                var tmpl;
                tmpl = $.extend(tmpl, $.icescrum.story.templates[template]);
                tmpl.selector = $.isFunction(tmpl.selector) ? tmpl.selector.apply(this) : tmpl.selector;
                tmpl.view = $.isFunction(tmpl.view) ? tmpl.view.apply(this) : tmpl.view;
                $(this).each(function() {
                    tmpl.remove.apply(this,[tmpl]);
                });
                if (!tmpl.noblank) {
                    if ($(tmpl.selector, $(tmpl.view)).length == 0) {
                        $(tmpl.view).hide();
                        $(tmpl.window + ' .box-blank').show();
                    }
                }
                if (!notFull){
                    $(this).each(function() {
                        $('.dependsOn[data-elemid=' + this.id + ']').remove();
                        $('[data-dependsOn=' + this.id + ']').removeData('dependson').removeAttr('data-dependsOn');
                    });
                }
            },

            accept:function(template) {
                $(this.id).each(function() {
                    $.icescrum.story.remove.apply({id:this,state:$.icescrum.story.STATE_SUGGESTED}, [template, true]);
                });
                var data = this.objects ? this.objects : this;
                var type = this.objects ? this.objects[0]['class'].toLowerCase() : this['class'].toLowerCase();
                jQuery.event.trigger('add_' + type, [data]);
            },

            returnToSandbox:function(template) {
                var data = this.objects ? this.objects : this;
                jQuery.event.trigger('update_story', [data]);
            },

            estimate:function(template) {
                $(this).each(function() {
                    $.icescrum.story.update.apply(this, [template]);
                });
            },

            inProgress:function(template) {
                $(this).each(function() {
                    $.icescrum.story.update.apply(this, [template]);
                });
            },

            done:function(template) {
                $(this).each(function() {
                    $.icescrum.story.update.apply(this, [template]);
                });
            },

            unDone:function(template) {
                $(this).each(function() {
                    $.icescrum.story.update.apply(this, [template]);
                });
            },

            plan:function(template) {
                $(this).each(function() {
                    $.icescrum.story.update.apply(this, [template, true]);
                });
            },

            unPlan:function(template) {
                $(this).each(function() {
                    $.icescrum.story.update.apply(this, [template]);
                });
            },

            manageDependencies:function(){
                var SelectDependsOn = $("#dependsOn\\.id");
                if (SelectDependsOn.size() > 0){
                    var addOrUpdate = function(story){
                        if (SelectDependsOn.find('option[value='+story.id+']').size() > 0){
                            SelectDependsOn.find('option[value='+story.id+']').html(story.name+' ('+story.uid+')');
                        }else{
                            SelectDependsOn.append($('<option></option>').val(story.id).html(story.name+' ('+story.uid+')'));
                        }
                    };
                    var form = SelectDependsOn.parents('form:first');
                    if (!this.name || this.state < form.data('state')){
                        SelectDependsOn.find('option[value='+this.id+']').remove();
                    } else if (this.state > form.data('state')){
                        addOrUpdate(this);
                    } else if (this.state == form.data('state') && this.state == $.icescrum.story.STATE_SUGGESTED){
                        addOrUpdate(this);
                    } else if (this.state == form.data('state') && this.state > $.icescrum.story.STATE_SUGGESTED && this.rank < form.data('rank')){
                        addOrUpdate(this);
                    } else if (this.state == form.data('state') && this.state > $.icescrum.story.STATE_SUGGESTED && this.rank > form.data('rank')){
                        SelectDependsOn.find('option[value='+this.id+']').remove();
                    }
                    SelectDependsOn.trigger("change");
                }
            },

            _postRendering:function(tmpl, newObject, container) {
                if (this.totalComments <= 0 ) {
                    newObject.find('.postit-comment,.table-comment').hide();
                }
                if (!this.dependsOn) {
                    newObject.find('.dependsOn').remove();
                }
                if (this.type != $.icescrum.story.TYPE_DEFECT) {
                    var affectVersionInput = newObject.find('[name="story.affectVersion"]');
                    affectVersionInput.hide();
                    affectVersionInput.next('hr').hide();
                }
                if(!this.acceptanceTests || this.acceptanceTests.length <= 0) {
                    newObject.find('.story-icon-acceptance-test').hide();
                } else {
                    var testCountByState = {};
                    $(this.acceptanceTests).each(function() {
                        var state = this.state;
                        testCountByState[state] = testCountByState[state] !== undefined ? testCountByState[state] + 1 : 1;
                    });
                    var testCountByStateLabel = $.map(testCountByState, function(value, key) {
                        return $.icescrum.story.testStateLabels[key] + ': ' + value;
                    }).join(' / ');
                    var testIcon = newObject.find('.story-icon-acceptance-test');
                    var oldTitle = testIcon.attr('title');
                    testIcon.attr('title', oldTitle + ' (' + testCountByStateLabel + ')');
                }
                if (this.totalAttachments <= 0) {
                    newObject.find('.postit-attachment,.table-attachment').hide()
                }
                if (container.hasClass('ui-selectable')) {
                    newObject.addClass('ui-selectee');
                }
                if (this.selected){
                    newObject.addClass('ui-selected');
                }

                var creator = (this.creator.id == $.icescrum.user.id);
                if (!((this.state == $.icescrum.story.STATE_SUGGESTED && creator) || (this.state >= $.icescrum.story.STATE_SUGGESTED && this.state != $.icescrum.story.STATE_DONE && $.icescrum.user.productOwner))) {
                    $('#menu-edit-' + this.id, newObject).remove();
                    // right
                    $('.field.editable', newObject).each(function() {
                        $(this).removeClass('editable');
                    });
                    var tags = $('input[name="story.tags"]', newObject);
                    if (tags.val() == '') {
                        tags.remove();
                    } else {
                        tags.attr('disabled','disabled');
                    }
                }
                if (!((this.state == $.icescrum.story.STATE_SUGGESTED && creator) || (this.state <= $.icescrum.story.STATE_ESTIMATED && $.icescrum.user.productOwner)) || this.state > $.icescrum.story.STATE_PLANNED) {
                    $('#menu-delete-' + this.id, newObject).remove();
                }
                if (!($.icescrum.user.productOwner && (this.state == $.icescrum.story.STATE_ACCEPTED || this.state == $.icescrum.story.STATE_ESTIMATED))) {
                    $('#menu-return-to-sandbox-' + this.id, newObject).remove();
                }
                if (this.state != $.icescrum.story.STATE_SUGGESTED) {
                    $('#menu-accept-' + this.id, newObject).remove();
                    $('#menu-accept-feature-' + this.id, newObject).remove();
                }
                if ($.icescrum.sprint.current == null) {
                    this.state == $.icescrum.story.STATE_SUGGESTED ? $('#menu-accept-task-' + this.id, newObject).hide() : $('#menu-accept-task-' + this.id, newObject).remove();
                } else if (this.state != $.icescrum.story.STATE_SUGGESTED) {
                    $('#menu-accept-task-' + this.id, newObject).remove();
                }
                if (this.state != $.icescrum.story.STATE_INPROGRESS) {
                    $('#menu-done-' + this.id, newObject).remove();
                }
                if (!(this.state >= $.icescrum.story.STATE_SUGGESTED)) {
                    $('#menu-copy-' + this.id, newObject).remove();
                }
                if ( this.state < $.icescrum.story.STATE_PLANNED || this.state == $.icescrum.story.STATE_DONE) {
                    $('#menu-unplan-' + this.id, newObject).remove();
                    $('#menu-add-task-'+this.id,newObject).remove();
                }
                if (this.state != $.icescrum.story.STATE_DONE || (this.parentSprint && this.parentSprint.state != $.icescrum.sprint.STATE_INPROGRESS)) {
                    $('#menu-undone-' + this.id, newObject).remove();
                }
                if (this.state == $.icescrum.story.STATE_DONE) {
                    newObject.find('.mini-value').removeClass('editable');
                    $('#menu-shift-' + this.id, newObject).remove();
                }
                if (this.state >= $.icescrum.story.STATE_PLANNED && this.state < $.icescrum.story.STATE_DONE && this.parentSprint.hasNextSprint) {
                    $('#menu-shift-' + this.id, newObject).removeClass('hidden');
                } else if (this.state <= $.icescrum.story.STATE_ESTIMATED) {
                    $('#menu-shift-' + this.id, newObject).remove();
                }
                if (this.state < $.icescrum.story.STATE_ACCEPTED || this.state == $.icescrum.story.STATE_DONE || !$.icescrum.user.productOwner) {
                    newObject.find('.postit-label').removeClass('postit-sortable');
                }

                if(tmpl.window) {
                    $(tmpl.window).trigger("postRendering.story",[this, tmpl, newObject, container]);
                }
            },

            backlogTitleDetails:function(){
                var effort = 0, size = 0;
                var stories = $.icescrum.getDefaultView() == 'postitsView' ? $('div.postit-story .mini-value') : $('tr.table-line .table-cell-selectui-effort');
                stories.each(function() { size += 1; if ($(this).text() != '?') effort += Number($(this).text());});
                $('#window-title-bar-backlog').find('.content .details').html(' - <span id="stories-backlog-size">'+size+'</span> '+$.icescrum.story.i18n.stories+' / <span id="stories-backlog-effort">'+effort+'</span> '+$.icescrum.story.i18n.points);
            },

            checkDependsOnPostitsView:function(ui){
                var container = ui.placeholder.parent();
                var currentIndex = ui.placeholder.index();
                var indexDependsOn = jQuery("div.postit-story[data-elemid="+ui.item.data("dependson")+"]", container).index();
                if (indexDependsOn == -1){
                    container.parents('.event-container').nextAll().each(function(){
                        if (jQuery("div.postit-story[data-elemid="+ui.item.data("dependson")+"]", $(this)).index() > -1){
                            indexDependsOn = currentIndex + 1;
                            return false;
                        }
                    });
                }
                if (currentIndex < indexDependsOn && indexDependsOn != -1){
                    ui.placeholder.addClass('dependsOn');
                    ui.placeholder.html(this.i18n.dependsOnWarning);
                    return;
                }else{
                    ui.placeholder.removeClass('dependsOn');
                    ui.placeholder.html("");
                }
                var firstDependence = jQuery("div.postit-story[data-dependsOn="+ui.item.data("elemid")+"]:first", container).index();
                if (firstDependence == -1){
                    container.parents('.event-container').prevAll().each(function(){
                        if (jQuery("div.postit-story[data-dependsOn="+ui.item.data("elemid")+"]:first", $(this)).index() > -1){
                            firstDependence = -2;
                            return false;
                        }
                    });
                }
                if (firstDependence != -1 && currentIndex > firstDependence){
                    ui.placeholder.addClass('dependsOn');
                    ui.placeholder.html(this.i18n.dependsOnWarning);
                }else{
                    ui.placeholder.removeClass('dependsOn');
                    ui.placeholder.html("");
                }
            },

            updateRank:function(params, data, container){
                if(data.story.rank != params["story.rank"]){
                    jQuery.icescrum.postit.updatePosition("div.postit-story", jQuery(".postit-story[data-elemid="+data.story.id+"]"), data.story.rank, jQuery(container));
                    jQuery.icescrum.renderNotice(data.message)
                }
            }
        }
    });

})($);
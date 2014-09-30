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
        sprint:{
            i18n:{
                name:'Sprint',
                noDropMessage:'',
                noDropMessageLimitedTasks:'',
                totalRemaining:'',
                points:'',
                filtered:''
            },
            current: null,
            STATE_WAIT : 1,
            STATE_INPROGRESS : 2,
            STATE_DONE : 3,
            currentTaskFilter: 'allTasks',
            taskFilters: {
                myTasks: function (task) {
                    return task.responsible != null && task.responsible.id == $.icescrum.user.id;
                },
                freeTasks: function (task) {
                    return task.responsible == null;
                },
                blockedTasks: function (task) {
                    return task.blocked;
                }
            },
            isFiltered: function() {
                return $.icescrum.sprint.currentTaskFilter != 'allTasks';
            },
            templates:{
                window:{
                    selector:function() {
                        return this.add ? 'div.event-container' : 'div.event-header';
                    },
                    id:function() {
                        return  this.add ? 'sprint-releasePlan-tmpl' : 'sprint-releasePlan-update-tmpl';
                    },
                    view:function() {
                        return this.add ? 'div.event-overflow' + '[data-elemid=' + this.parentRelease.id + ']' : this.id ? 'div.event-container' + '[data-elemid=' + this.id + ']' : 'div.event-container';
                    },
                    constaintTmpl:function() {
                        return $('div.event-overflow').data('elemid') == this.parentRelease.id;
                    },
                    remove:function() {
                        $('div.event-container[data-elemid=' + this.id + ']').remove();
                        $('span.event-select-item[data-elemid=' + this.id + ']').remove();
                        $(window).trigger('resize.eventline');
                    },
                    beforeTmpl:function(tmpl, container) {
                        if (!this.add) {
                            return;
                        }
                        return container.find('div.event-content-list:last').hasClass('event-content-list-odd');
                    },
                    afterTmpl:function(tmpl, container, newObject, beforeData) {
                        $(window).trigger('resize.eventline');
                        if (!this.add) {
                            return;
                        }
                        if (!beforeData) {
                            container.find('div.event-content-list:last').addClass('event-content-list-odd');
                        }
                        $('div.event-select').append($('<span class="event-select-item" data-elemid="' + this.id + '">' + $.icescrum.sprint.i18n.name + ' ' + this.orderNumber + '</span>'));
                    },
                    window:'#window-content-releasePlan'
                }
            },
            add:function(template) {
                var sprints = this.sprints ? this.sprints : this;
                var selectOnSprintPlan = $("#selectOnSprintPlan");
                var selectOnTimeline = $("#selectOnTimeline");
                $(sprints).each(function() {
                    $('.menu-shift-' + this.parentRelease.id + '-' + (this.orderNumber)).removeClass('hidden');
                    if (selectOnSprintPlan.length) {
                        selectOnSprintPlan.append($('<option></option>').val(this.id).html(this.parentRelease.name + ' - ' + $.icescrum.sprint.i18n.name + ' ' + this.orderNumber));
                        selectOnSprintPlan.trigger('change');
                    }
                    if (selectOnTimeline.length) {
                        selectOnTimeline.append($('<option></option>').val($.icescrum.jsonToDate(this.startDate).getTime()).attr('id',this.id).html(this.parentRelease.name + ' - ' + $.icescrum.sprint.i18n.name + ' ' + this.orderNumber));
                        selectOnTimeline.trigger('change');
                    }
                    if (template) {
                        this.add = true;
                        $.icescrum.addOrUpdate(this, $.icescrum.sprint.templates[template], $.icescrum.sprint._postRendering, true);
                    }
                });
            },

            update:function(template) {
                if (template) {
                    this.add = false;
                    $.icescrum.addOrUpdate(this, $.icescrum.sprint.templates[template], $.icescrum.sprint._postRendering);
                }
                var selectOnTimeline = $("#selectOnTimeline");
                if (selectOnTimeline.length) {
                    selectOnTimeline.find('option[id='+this.id+']').val($.icescrum.jsonToDate(this.startDate).getTime()).html(this.parentRelease.name + ' - ' + $.icescrum.sprint.i18n.name + ' ' + this.orderNumber);
                }
                selectOnTimeline.trigger('change');
            },

            remove:function(template) {
                var sprints = this.sprints ? this.sprints : this;
                var tmpl;
                tmpl = $.extend(tmpl, $.icescrum.sprint.templates[template]);
                tmpl.selector = $.isFunction(tmpl.selector) ? tmpl.selector.apply(this) : tmpl.selector;
                tmpl.view = $.isFunction(tmpl.view) ? tmpl.view.apply(this) : tmpl.view;

                var selectOnSprintPlan = $("#selectOnSprintPlan");
                var selectOnTimeline = $("#selectOnTimeline");
                $(sprints).each(function() {
                    if (template) {
                        tmpl.remove.apply(this);
                    }
                    $('li.menu-shift-' + this.parentRelease.id + '-' + (this.orderNumber)).addClass('hidden');
                    if (selectOnSprintPlan.length) {
                        selectOnSprintPlan.find('option[value='+this.id+']').remove();
                        selectOnSprintPlan.trigger('change');
                    }
                    if (selectOnTimeline.length) {
                        selectOnTimeline.find('option[id='+this.id+']').remove();
                        selectOnTimeline.trigger('change');
                    }
                });
                if ($(tmpl.selector, $(tmpl.view)).length == 0) {
                    $(tmpl.view).hide();
                    $(tmpl.window + ' .box-blank').show();
                }
            },

            close:function(template) {
                if (template) {
                    $.icescrum.sprint.update.apply(this, [template]);
                }
                $.icescrum.sprint.current = null;
                $('li.menu-accept-task').hide();
                var kanban = $('table#kanban-sprint-' + this.id);
                $('td:not(:first-child)',kanban).sortable('destroy');
                if (this.tasks){
                    var tasks = this.tasks;
                    $('.row-urgent-task td:not(:last-child) .postit-task,.row-recurrent-task td:not(:last-child) .postit-task',kanban).each(function(){
                        var id = $(this).data('elemid');
                        var found = false;
                        $(tasks).each(function(){
                            if (this.id == id){
                                found = true;
                                return false;
                            }
                        });
                        if (!found){
                            $(this).remove();
                        }
                    });
                }
                $('.row-urgent-task',kanban).removeClass('postit-sortable');
                $('.postit-label',kanban).removeClass('postit-sortable');
                $('.postit-task .dropmenu-action',kanban).remove();
                $('div#dropmenu-menu-recurrent',kanban).remove();
                $('div#dropmenu-menu-urgent',kanban).remove();
                $('.close-sprint-' + this.parentRelease.id + '-' + (this.orderNumber)).remove();
                $('#show-done-sprint-' + this.parentRelease.id + '-' + this.orderNumber).remove();
                $('.activate-sprint-' + this.parentRelease.id + '-' + (this.orderNumber + 1)).removeClass('hidden');
                kanban.addClass('done');
            },

            activate:function(template) {
                if (template) {
                    $.icescrum.sprint.update.apply(this, [template]);
                }
                $.icescrum.sprint.current = this;
                $('.menu-accept-task').show();
                $('.activate-sprint-' + this.parentRelease.id + '-' + (this.orderNumber)).remove();
                $('#show-done-sprint-' + this.parentRelease.id + '-' + this.orderNumber).removeClass('hidden');
                $('.close-sprint-' + this.parentRelease.id + '-' + (this.orderNumber)).removeClass('hidden');
            },

            _postRendering:function(tmpl, newObject) {
                if (this.state == $.icescrum.sprint.STATE_DONE) {
                    var backlog = $("#backlog-layout-plan-releasePlan-" + this.id);
                    if (backlog.length) {
                        backlog.sortable('disable', true);
                        $('.postit-label.postit-sortable', backlog).removeClass('postit-sortable');
                        $('.event-container[data-elemid=' + this.id + '] > .event-content-list').droppable('disable', true).removeClass('ui-state-disabled');
                    }
                }
                if (this.activable) {
                    $('#menu-activate-sprint-' + this.id, newObject).removeClass('hidden');
                }
                if (this.state == $.icescrum.sprint.STATE_INPROGRESS) {
                    $('#menu-close-sprint-' + this.id, newObject).removeClass('hidden');
                }
                if (this.state != $.icescrum.sprint.STATE_WAIT) {
                    $('#menu-delete-sprint-' + this.id, newObject).remove();
                    $('#menu-activate-sprint-' + this.id, newObject).remove();
                }
                if (this.state != $.icescrum.sprint.STATE_INPROGRESS) {
                    $('#menu-close-sprint-' + this.id, newObject).remove();
                }
                if (this.state == $.icescrum.sprint.STATE_DONE) {
                    $('#menu-unplan-sprint-' + this.id, newObject).remove();
                    $('#menu-edit-sprint-' + this.id, newObject).remove();
                }
            },

            updateWindowTitle:function(sprint) {
                var $select = $("#selectOnSprintPlan");
                if ($select && $select.val() == sprint.id) {
                    var newTitle = ' - ' +
                        $.icescrum.sprint.i18n.name + ' ' + sprint.orderNumber + ' - ' +
                        $.icescrum.sprint.states[sprint.state] + ' - ' +
                        '[' + $.icescrum.dateLocaleFormat(sprint.startDate) + ' -> ' + $.icescrum.dateLocaleFormat(sprint.endDate) + '] - ' +
                        '<span class="sprint-points"></span> ' + $.icescrum.sprint.i18n.points + ' - ' +
                        $.icescrum.sprint.i18n.totalRemaining + ' <span class="remaining"></span> <span class="remaining-filtered"></span>';
                    $('#window-title-bar-sprintPlan').find('.content .details').html(newTitle);
                    // Fill the empty fields
                    $.icescrum.sprint.updateRemaining();
                    $.icescrum.sprint.sprintMesure.apply(sprint);
                }
            },

            updateRemaining:function(){
                var remaining = 0;
                var offset = 10000; // hack for decimal values
                var selector = $.icescrum.getDefaultView() == 'postitsView' ? 'table.table.kanban div.postit-task span.mini-value' : 'table#tasks-table td.estimation div.table-cell';
                $('#window-id-sprintPlan').find(selector).each(function(){
                    var val = $(this).text();
                    if (val != '?'){
                        remaining += parseFloat(val) * offset; // hack for decimal values
                    }
                });
                remaining =  Math.round(remaining) / offset; // hack for decimal values
                var titleBar = $('#window-title-bar-sprintPlan');
                titleBar.find('span.remaining').html(remaining);
                var filteredText = $.icescrum.sprint.isFiltered() ? ' (' + $.icescrum.sprint.i18n.filtered + ')' : '';
                titleBar.find('span.remaining-filtered').html(filteredText);
            },

            sprintMesure:function() {
                $(this).each(function() {
                    var sprintPoints = $('.event-header[data-elemid=' + this.id + ']').find('.event-header-velocity');
                    if (!sprintPoints.length) {
                        sprintPoints = $('#window-title-bar-sprintPlan').find('.sprint-points');
                    }
                    if (sprintPoints.length) {
                        this.velocity = (this.velocity != undefined) ? this.velocity : 0;
                        this.capacity = (this.capacity != undefined) ? this.capacity : 0;
                        var newSprintPoints = this.state >= $.icescrum.sprint.STATE_INPROGRESS ? this.velocity + ' / ' + this.capacity : this.capacity;
                        sprintPoints.html(newSprintPoints);
                    }
                });
            },

            doneDefinition:function() {
                if ($('#panel-doneDefinition-' + this.id).length) {
                    $('#panel-doneDefinition-' + this.id + ' .panel-box-content').load($.icescrum.o.baseUrl + 'textileParser', {data:this.doneDefinition,withoutHeader:true,truncate:1000});
                }
            },

            retrospective:function() {
                if ($('#panel-retrospective-' + this.id).length) {
                    $('#panel-retrospective-' + this.id + ' .panel-box-content').load($.icescrum.o.baseUrl + 'textileParser', {data:this.retrospective,withoutHeader:true,truncate:1000});
                }
            },

            sortableTasks:function(){
                if (!$.icescrum.user.stakeHolder && $.icescrum.product.assignOnBeginTask && !$.icescrum.user.scrumMaster){
                    $('table.kanban:not(.done) td[type=0] .postit-task:not(.hasResponsible) .postit-label').addClass('postit-sortable');
                }else if(!$.icescrum.user.stakeHolder && !$.icescrum.product.assignOnBeginTask && !$.icescrum.user.scrumMaster){
                    $('table.kanban:not(.done) td[type=0] .postit-task:not(.hasResponsible) .postit-label').removeClass('postit-sortable');
                }
            },

            droppableTasks:function(object,ui){
                var to = $(object);
                var placeholder = $(ui.placeholder);
                var from = $(ui.sender);

                if (this.current){
                    if(this.current.state != this.STATE_INPROGRESS){
                        placeholder.html(this.i18n.noDropMessage);
                        placeholder.addClass('no-drop');
                    }else if($.icescrum.product.limitUrgentTasks > 0 && this.current.state == this.STATE_INPROGRESS){
                        if (to.closest('tr').hasClass('row-urgent-task') && to.attr('type') == 1 && to.find('.postit-task').length >= $.icescrum.product.limitUrgentTasks > 0){
                            if (from.closest('tr').hasClass('row-urgent-task') && from.attr('type') == 1){
                                placeholder.removeClass('no-drop');
                                placeholder.html('');
                            }else{
                                placeholder.html(this.i18n.noDropMessageLimitedTasks);
                                placeholder.addClass('no-drop');
                            }
                        }else{
                            placeholder.removeClass('no-drop');
                            placeholder.html('');
                        }
                    }else{
                        placeholder.removeClass('no-drop');
                        placeholder.html('');
                    }
                }else{
                    if (to.attr('type') >= 1){
                        placeholder.addClass('no-drop');
                        placeholder.html(this.i18n.noDropMessage);
                    }else{
                        placeholder.removeClass('no-drop');
                        placeholder.html('');
                    }
                }
            }
        }
    })
})($);
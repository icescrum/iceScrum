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
        task: {
            i18n:{},
            STATE_WAIT:0,
            STATE_BUSY:1,
            STATE_DONE:2,
            TYPE_RECURRENT:10,
            TYPE_URGENT:11,
            BLOCKED:'Blocked',
            UNBLOCK:'Unblock',
            BLOCK:'Block',
            templates:{
                sprintPlan:{
                    selector:'div.postit-task',
                    id:'postit-task-sprintPlan-tmpl',
                    view:function() {
                        return (this.type == $.icescrum.task.TYPE_RECURRENT || this.type == $.icescrum.task.TYPE_URGENT) ? '#kanban-sprint' + '-' + this.sprint.id + ' .table-line[type=' + this.type + '] .kanban-col[type=' + this.state + ']' : this.sprint ? '#kanban-sprint' + '-' + this.sprint.id + ' .row-story[data-elemid=' + this.parentStory.id + '] .kanban-col[type=' + this.state + ']' : '';
                    },
                    remove:function() {
                        $('.kanban-col .postit-task[data-elemid=' + this.id + ']').remove();
                    },
                    constraintTmpl:function() {
                        var filter = $.icescrum.sprint.taskFilters[$.icescrum.sprint.currentTaskFilter];
                        return (filter == undefined) || filter(this);
                    },
                    update:function(template) {
                        var tmpl = $.icescrum.task.templates[template];
                        // Save selection
                        var selectedTasks = $(tmpl.selector + '.ui-selected').map(function() {
                            return $(this).data('elemid');
                        });
                        $(this).each(function() {
                            $.icescrum.task.remove.apply(this, [template]);
                            $.icescrum.task.add.apply(this, [template]);
                        });
                        // Restore selection
                        selectedTasks.each(function() {
                            var elem = $(tmpl.selector + '[data-elemid=' + this + ']');
                            if (elem.length > 0 && !elem.hasClass('ui-selected')) {
                                elem.addClass('ui-selected');
                            }
                        });
                    },
                    _postRendering:function(tmpl, postit) {

                        if ($(tmpl.view + '-' + this.sprint.id).hasClass('ui-selectable') && this.sprint.state != $.icescrum.sprint.STATE_DONE) {
                            postit.addClass('ui-selectee');
                        }
                        if (this.totalAttachments == undefined || !this.totalAttachments) {
                            postit.find('.postit-attachment').hide();
                        }
                        if (this.totalComments <= 0 ) {
                            postit.find('.postit-comment').hide();
                        }

                        var responsible = (this.responsible && this.responsible.id == $.icescrum.user.id) ? true : false;
                        var creator = this.creator.id == $.icescrum.user.id;
                        var taskDone = this.state == $.icescrum.task.STATE_DONE;
                        var notStoryDone = !this.parentStory || this.parentStory.state != $.icescrum.story.STATE_DONE;

                        var taskEditable = ($.icescrum.user.scrumMaster || responsible || creator) && !taskDone;
                        var taskDeletable = $.icescrum.user.scrumMaster || responsible || creator;
                        var taskBlockable = ($.icescrum.user.scrumMaster || responsible) && !taskDone && this.sprint.state == $.icescrum.sprint.STATE_INPROGRESS;
                        var taskSortable = ($.icescrum.user.scrumMaster || responsible || (!this.responsible && $.icescrum.user.inProduct() && $.icescrum.product.assignOnBeginTask && this.state == $.icescrum.task.STATE_WAIT)) && notStoryDone;
                        var taskTakable = !responsible && !taskDone;
                        var taskReleasable = responsible && !taskDone;
                        var taskCopyable = notStoryDone;

                        if(this.sprint.state == $.icescrum.sprint.STATE_DONE) {
                            $('.dropmenu-action', postit).remove();
                        } else {
                            // Menu
                            if (!taskEditable) {
                                $('#menu-edit-' + this.id, postit).remove();
                            } else {
                                $('.mini-value', postit).addClass('editable editable-hover');
                            }
                            if (!taskDeletable) {
                                $('#menu-delete-' + this.id, postit).remove();
                            }
                            if (!taskBlockable) {
                                $('#menu-blocked-' + this.id, postit).remove();
                            }
                            if (!taskTakable) {
                                $('#menu-take-' + this.id, postit).remove();
                            }
                            if (!taskReleasable) {
                                $('#menu-unassign-' + this.id, postit).remove();
                            }
                            if (!taskCopyable) {
                                $('#menu-copy-' + this.id, postit).remove();
                            }
                            // Draggable
                            if (taskSortable) {
                                $('.postit-label', postit).addClass('postit-sortable');
                            }
                        }

                        this.blocked ? $('#menu-blocked-' + this.id + ' a', postit).text($.icescrum.task.UNBLOCK) : $('#menu-blocked-' + this.id + ' a', postit).text($.icescrum.task.BLOCK);

                        $.icescrum.sprint.updateRemaining();
                    }
                }
            },
            add:function(template) {
                $(this).each(function() {
                    $.icescrum.addOrUpdate(this, $.icescrum.task.templates[template], $.icescrum.task._postRendering);
                });
            },

            update:function(template) {
                var tmpl = $.icescrum.task.templates[template];
                tmpl.update.apply(this, [template]);
            },

            remove:function(template) {
                var tmpl = $.icescrum.task.templates[template];
                $(this).each(function() {
                    tmpl.remove.apply(this, [tmpl]);
                });
                $.icescrum.sprint.updateRemaining();
            },

            _postRendering:function(tmpl, domObject) {
                tmpl._postRendering.apply(this, [tmpl, domObject]);
            },

            toggleBlocked:function(data) {
                var $elem = $('#postit-task-' + data.id + ' .postit-ico,.table-line[data-elemid=' + data.id + ']');
                if ($elem.toggleClass('ico-task-1').hasClass('ico-task-1')) {
                    $('#menu-blocked-' + data.id + ' a').text($.icescrum.task.UNBLOCK);
                    $('#task-action-blocked-' + data.id + ' a .content').text($.icescrum.task.UNBLOCK);
                    $elem.attr('title', $.icescrum.task.BLOCKED);
                } else {
                    $('#menu-blocked-' + data.id + ' a').text($.icescrum.task.BLOCK);
                    $('#task-action-blocked-' + data.id + ' a .content').text($.icescrum.task.BLOCK);
                    $elem.attr('title', '');
                }
            }
        }
    });
})($);
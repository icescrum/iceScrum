/*
 * Copyright (c) 2011 Kagilum SAS.
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
 *
 */
(function($) {
    $.extend($.icescrum, {

                user: {
                    scrumMaster:false,
                    productOwner:false,
                    teamMember:false,
                    stackHolder:true,
                    poOrSm:function() {
                        return (this.scrumMaster || this.productOwner);
                    },
                    add:function() {
                        //TODO ?
                    },

                    update:function() {
                        alert('update user');
                    },

                    remove:function() {
                        alert('remove user');
                    }
                },


                product: {
                    currentProduct:null,
                    deleted:'Project deleted',
                    updated:'Project settings updated',
                    add:function() {
                        //TODO ?
                    },

                    update:function() {
                        if (this.id == $.icescrum.product.currentProduct){
                            if (this.refresh){
                                alert($.icescrum.product.updated);
                                document.location = $.icescrum.o.baseUrl;
                            }else{
                                $('#project-details ul li:first strong').text(this.name);
                                $('#panel-description .panel-box-content').load($.icescrum.o.baseUrl + 'textileParser', {data:this.description,withoutHeader:true});
                            }
                        }
                    },

                    remove:function() {
                        if (this.id == $.icescrum.product.currentProduct){
                            alert($.icescrum.product.deleted);
                            document.location = $.icescrum.o.baseUrl;
                        }
                    },

                    redirect:function() {
                        document.location = $.icescrum.o.grailsServer+'/p/'+this.pkey+'#project';
                    }
                },

                actor: {
                    templates:{
                        window:{
                            selector:function() {
                                return $.icescrum.o.currentView == 'postitsView' ? 'div.postit-actor' : 'tr.table-line';
                            },
                            id:function() {
                                return $.icescrum.o.currentView == 'postitsView' ? 'postit-actor-tmpl' : 'table-row-actor-tmpl';
                            },
                            view:function() {
                                return $.icescrum.o.currentView == 'postitsView' ? '#backlog-layout-window-actor' : '#actor-table';
                            },
                            remove:function() {
                                return $.icescrum.o.currentView == 'postitsView' ? $('.postit-actor[elemid=' + this.id + ']').remove() : $('#actor-table .table-line[elemid=' + this.id + ']').remove();
                            },
                            window:'#window-content-actor',
                            afterTmpl:function(tmpl) {
                                if ($.icescrum.o.currentView == 'postitsView') {
                                    return;
                                }
                                var lines = $(tmpl.view + ' .table-line');
                                lines.filter('.line-last').removeClass('line-last');
                                lines.last().addClass('line-last');
                            }
                        },
                        widget:{
                            selector:'li.postit-row-actor',
                            id:'postit-row-actor-tmpl',
                            view:'#backlog-layout-widget-actor',
                            remove:function() {
                                $('.postit-row-actor[elemid=' + this.id + ']').remove();
                            },
                            window:'#widget-content-actor'
                        }
                    },

                    add:function(template) {
                        $.icescrum.addOrUpdate(this, $.icescrum.actor.templates[template], $.icescrum.actor._postRendering);
                    },

                    update:function(template) {
                        $.icescrum.addOrUpdate(this, $.icescrum.actor.templates[template], $.icescrum.actor._postRendering);
                    },

                    remove:function(template) {
                        var tmpl;
                        tmpl = $.extend(tmpl, $.icescrum.actor.templates[template]);
                        tmpl.selector = $.isFunction(tmpl.selector) ? tmpl.selector.apply(this) : tmpl.selector;
                        tmpl.view = $.isFunction(tmpl.view) ? tmpl.view.apply(this) : tmpl.view;
                        $(this).each(function() {
                            tmpl.remove.apply(this);
                        });
                        if ($(tmpl.selector, $(tmpl.view)).length == 0) {
                            $(tmpl.view).hide();
                            $(tmpl.window + ' .box-blank').show();
                        }
                    },

                    _postRendering:function(tmpl, newObject, container) {
                        if (this.totalAttachments == undefined || !this.totalAttachments) {
                            newObject.find('.postit-attachment,.table-attachment').hide();
                        }
                        if (container.hasClass('ui-selectable')) {
                            newObject.addClass('ui-selectee');
                        }
                    }
                },

                feature:{
                    templates:{
                        window:{
                            selector:function() {
                                return $.icescrum.o.currentView == 'postitsView' ? 'div.postit-feature' : 'tr.table-line';
                            },
                            id:function() {
                                return $.icescrum.o.currentView == 'postitsView' ? 'postit-feature-tmpl' : 'table-row-feature-tmpl';
                            },
                            view:function() {
                                return $.icescrum.o.currentView == 'postitsView' ? '#backlog-layout-window-feature' : '#feature-table';
                            },
                            remove:function() {
                                return $.icescrum.o.currentView == 'postitsView' ? $('.postit-feature[elemid=' + this.id + ']').remove() : $('#feature-table .table-line[elemid=' + this.id + ']').remove();
                            },
                            window:'#window-content-feature',
                            afterTmpl:function(tmpl) {
                                if ($.icescrum.o.currentView == 'postitsView') {
                                    return;
                                }
                                var lines = $(tmpl.view + ' .table-line');
                                lines.filter('.line-last').removeClass('line-last');
                                lines.last().addClass('line-last');
                            }
                        },
                        widget:{
                            selector:'.postit-row-feature',
                            id:'postit-row-feature-tmpl',
                            view:'#backlog-layout-widget-feature',
                            remove:function() {
                                $('.postit-row-feature[elemid=' + this.id + ']').remove();
                            },
                            window:'#widget-content-feature'
                        }
                    },

                    add:function(template) {
                        $.icescrum.addOrUpdate(this, $.icescrum.feature.templates[template], $.icescrum.feature._postRendering);
                    },

                    update:function(template) {
                        var feature = this;
                        $(feature.stories).each(function() {
                            $('div.postit-story[elemid=' + this.id + '] .postit-layout').removeClass().addClass('postit-layout postit-' + feature.color);
                            $('li.postit-row-story[elemid=' + this.id + '] .postit-icon').removeClass().addClass('postit-icon postit-icon-' + feature.color);
                        });
                        $('#detail-feature-' + feature.id + ' .line-right').replaceWith('<td class="line-right"><span class="postit-icon postit-icon-' + feature.color + '" title="' + feature.name + '"></span>' + feature.name + '</td>');
                        $.icescrum.addOrUpdate(feature, $.icescrum.feature.templates[template], $.icescrum.feature._postRendering);
                    },

                    remove:function(template) {
                        var tmpl;
                        tmpl = $.extend(tmpl, $.icescrum.feature.templates[template]);
                        tmpl.selector = $.isFunction(tmpl.selector) ? tmpl.selector.apply(this) : tmpl.selector;
                        tmpl.view = $.isFunction(tmpl.view) ? tmpl.view.apply(this) : tmpl.view;
                        $(this).each(function() {
                            tmpl.remove.apply(this);
                        });
                        if ($(tmpl.selector, $(tmpl.view)).length == 0) {
                            $(tmpl.view).hide();
                            $(tmpl.window + ' .box-blank').show();
                        }
                    },

                    _postRendering:function(tmpl, newObject, container) {
                        if (this.rank && this.rank != 0) {
                            $.icescrum.postit.updatePosition(tmpl.selector, newObject, this.rank);
                        }
                        if (this.totalAttachments == undefined || !this.totalAttachments) {
                            newObject.find('.postit-attachment,.table-attachment').hide()
                        }
                        if (container.hasClass('ui-selectable')) {
                            newObject.addClass('ui-selectee');
                        }
                    }
                },

                story:{
                    STATE_SUGGESTED:1,
                    STATE_ACCEPTED:2,
                    STATE_ESTIMATED:3,
                    STATE_PLANNED:4,
                    STATE_INPROGRESS:5,
                    STATE_DONE:7,
                    templates:{
                        sandbox:{
                            selector:function() {
                                return $.icescrum.o.currentView == 'postitsView' ? 'div.postit-story' : 'tr.table-line';
                            },
                            id:function() {
                                return $.icescrum.o.currentView == 'postitsView' ? 'postit-story-sandbox-tmpl' : 'table-row-story-sandbox-tmpl';
                            },
                            view:function() {
                                return $.icescrum.o.currentView == 'postitsView' ? '#backlog-layout-window-sandbox' : '#story-table';
                            },
                            remove:function() {
                                var story = $.icescrum.o.currentView == 'postitsView' ? $('.postit-story[elemid=' + this.id + ']') : $('#story-table .table-line[elemid=' + this.id + ']');
                                this.rank = story.index() + 1;
                                return story.remove();
                            },
                            constraintTmpl:function() {
                                return this.state == $.icescrum.story.STATE_SUGGESTED;
                            },
                            window:'#window-content-sandbox',
                            afterTmpl:function(tmpl, container, newObject) {
                                if (this.rank){
                                    $.icescrum.postit.updatePosition(tmpl.selector, newObject, this.rank, container);
                                }
                                if ($.icescrum.o.currentView == 'postitsView') {
                                    return;
                                }
                                var lines = $(tmpl.view + ' .table-line');
                                lines.filter('.line-last').removeClass('line-last');
                                lines.last().addClass('line-last');
                            }
                        },
                        backlogWindow:{
                            selector:function() {
                                return $.icescrum.o.currentView == 'postitsView' ? 'div.postit-story' : 'tr.table-line';
                            },
                            id:function() {
                                return $.icescrum.o.currentView == 'postitsView' ? 'postit-story-backlog-tmpl' : 'table-row-story-backlog-tmpl';
                            },
                            view:function() {
                                return $.icescrum.o.currentView == 'postitsView' ? '#backlog-layout-window-backlog' : '#story-table';
                            },
                            constraintTmpl:function() {
                                return this.state == $.icescrum.story.STATE_ACCEPTED || this.state == $.icescrum.story.STATE_ESTIMATED;
                            },
                            remove:function() {
                                return $.icescrum.o.currentView == 'postitsView' ? $('.postit-story[elemid=' + this.id + ']').remove() : $('#story-table .table-line[elemid=' + this.id + ']').remove();
                            },
                            window:'#window-content-backlog',
                            afterTmpl:function(tmpl, container, newObject) {
                                $.icescrum.postit.updatePosition(tmpl.selector, newObject, this.rank, container);
                                if ($.icescrum.o.currentView == 'postitsView') {
                                    return;
                                }
                                var lines = $(tmpl.view + ' .table-line');
                                lines.filter('.line-last').removeClass('line-last');
                                lines.last().addClass('line-last');
                            }
                        },
                        backlogWidget:{
                            selector:'li.postit-row-story',
                            id:'postit-row-story-backlog-tmpl',
                            view:'#backlog-layout-widget-backlog',
                            constraintTmpl:function() {
                                return this.state == $.icescrum.story.STATE_ESTIMATED;
                            },
                            remove:function(container) {
                                $('.postit-row-story[elemid=' + this.id + ']:visible', container).remove();
                            },
                            window:'#widget-content-backlog',
                            afterTmpl:function(tmpl, container, newObject) {
                                $.icescrum.postit.updatePosition(tmpl.selector, newObject, this.rank, container);
                            }
                        },
                        releasePlan:{
                            selector:'div.postit-story',
                            id:'postit-story-releasePlan-tmpl',
                            view:function() {
                                return this.parentSprint ? '#backlog-layout-plan-releasePlan' + '-' + this.parentSprint.id : '';
                            },
                            remove:function() {
                                $('#window-content-releasePlan .postit-story[elemid=' + this.id + ']').remove();
                            },
                            constraintTmpl:function() {
                                return this.state >= $.icescrum.story.STATE_PLANNED;
                            },
                            noblank:true,
                            window:'#window-content-releasePlan',
                            afterTmpl:function(tmpl, container, newObject) {
                                $.icescrum.postit.updatePosition(tmpl.selector, newObject, this.rank, container);
                                $.event.trigger('sprintMesure_sprint', this.parentSprint);
                            }
                        },
                        sprintPlan:{
                            selector:'tr.row-story',
                            id:'postit-story-sprintPlan-tmpl',
                            view:function() {
                                return this.parentSprint ? '#kanban-sprint' + '-' + this.parentSprint.id + ' tbody[type=story]' : '';
                            },
                            remove:function() {
                                $('.kanban .row-story[elemid=' + this.id + ']').remove();
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
                            }
                        }
                    },

                    add:function(template) {
                        $(this).each(function() {
                            $.icescrum.addOrUpdate(this, $.icescrum.story.templates[template], $.icescrum.story._postRendering);
                        });
                    },

                    update:function(template) {
                        $(this).each(function() {
                            $.icescrum.story.remove.apply(this, [template]);
                            $.icescrum.story.add.apply(this, [template]);
                        });
                    },

                    remove:function(template) {
                        var tmpl;
                        tmpl = $.extend(tmpl, $.icescrum.story.templates[template]);
                        tmpl.selector = $.isFunction(tmpl.selector) ? tmpl.selector.apply(this) : tmpl.selector;
                        $(this).each(function() {
                            tmpl.remove.apply(this);
                        });
                        if (!tmpl.noblank) {
                            tmpl.view = $.isFunction(tmpl.view) ? tmpl.view.apply(this) : tmpl.view;
                            if ($(tmpl.selector, $(tmpl.view)).length == 0) {
                                $(tmpl.view).hide();
                                $(tmpl.window + ' .box-blank').show();
                            }
                        }
                    },

                    accept:function(template) {
                        $(this.id).each(function() {
                            $.icescrum.story.remove.apply({id:this,state:$.icescrum.story.STATE_SUGGESTED}, [template]);
                        });
                        var data = this.objects ? this.objects : this;
                        var type = this.objects ? this.objects[0]['class'].toLowerCase() : this['class'].toLowerCase();
                        jQuery.event.trigger('add_' + type, [data]);
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
                            $.icescrum.story.update.apply(this, [template]);
                        });
                    },

                    unPlan:function(template) {
                        $(this).each(function() {
                            $.icescrum.story.update.apply(this, [template]);
                        });
                    },

                    associated:function(template) {
                        $.icescrum.story.update.apply(this, [template]);
                    },

                    dissociated:function(template) {
                        $.icescrum.story.update.apply(this, [template]);
                    },

                    _postRendering:function(tmpl, newObject, container) {
                        if (this.comments == undefined || this.comments.length <= 0 ) {
                            newObject.find('.postit-comment,.table-comment').hide();
                        }

                        if (this.attachments == undefined || this.attachments.length <= 0) {
                            newObject.find('.postit-attachment,.table-attachment').hide()
                        }
                        if (container.hasClass('ui-selectable')) {
                            newObject.addClass('ui-selectee');
                        }

                        var creator = (this.creator.id == $.icescrum.user.id);
                        if (!((this.state == $.icescrum.story.STATE_SUGGESTED && creator) || (this.state != $.icescrum.story.STATE_DONE && $.icescrum.user.productOwner))) {
                            $('#menu-edit-' + this.id, newObject).remove();
                        }
                        if (!((this.state == $.icescrum.story.STATE_SUGGESTED && creator) || (this.state <= $.icescrum.story.STATE_ESTIMATED && $.icescrum.user.productOwner)) || this.state > $.icescrum.story.STATE_PLANNED) {
                            $('#menu-delete-' + this.id, newObject).remove();
                        }
                        if (this.state != $.icescrum.story.STATE_SUGGESTED) {
                            $('#menu-accept-' + this.id, newObject).remove();
                            $('#menu-accept-feature-' + this.id, newObject).remove();
                        }
                        if ($.icescrum.sprint.current == null) {
                            this.state == $.icescrum.story.STATE_SUGGESTED ? $('#menu-accept-task-' + this.id, newObject).hide() : $('#menu-accept-task-' + this.id, newObject).remove();
                        } else if (this.state > $.icescrum.story.STATE_SUGGESTED) {
                            $('#menu-accept-task-' + this.id, newObject).remove();
                        }
                        if (this.state != $.icescrum.story.STATE_INPROGRESS) {
                            $('#menu-done-' + this.id, newObject).remove();
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
                    }
                },

                task: {
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
                                return (this.type == $.icescrum.task.TYPE_RECURRENT || this.type == $.icescrum.task.TYPE_URGENT) ? '#kanban-sprint' + '-' + this.backlog.id + ' .table-line[type=' + this.type + '] .kanban-col[type=' + this.state + ']' : '#kanban-sprint' + '-' + this.backlog.id + ' .row-story[elemid=' + this.parentStory.id + '] .kanban-col[type=' + this.state + ']';
                            },
                            remove:function() {
                                $('.postit-task[elemid=' + this.id + ']').remove();
                            }
                        }
                    },
                    add:function(template) {
                        $(this).each(function() {
                            var task = this;
                            $.icescrum.addOrUpdate(this, $.icescrum.task.templates[template], $.icescrum.task._postRendering);
                        });
                    },

                    update:function(template) {
                        $(this).each(function() {
                            $.icescrum.task.remove.apply(this, [template]);
                            $.icescrum.task.add.apply(this, [template]);
                        });
                    },

                    remove:function(template) {
                        $(this).each(function() {
                            $.icescrum.task.templates[template].remove.apply(this);
                        });
                    },

                    _postRendering:function(tmpl, postit) {
                        if ($(tmpl.view + '-' + this.backlog.id).hasClass('ui-selectable') && this.backlog.state != $.icescrum.sprint.STATE_DONE) {
                            postit.addClass('ui-selectee');
                        }
                        if (this.totalAttachments == undefined || !this.totalAttachments) {
                            postit.find('.postit-attachment').hide()
                        }
                        var responsible = (this.responsible && this.responsible.id == $.icescrum.user.id) ? true : false;
                        var creator = (this.creator.id == $.icescrum.user.id);
                        if ((this.state == $.icescrum.task.STATE_DONE && !$.icescrum.user.scrumMaster) || (!(responsible || creator || $.icescrum.user.poOrSm) && this.state != $.icescrum.task.STATE_DONE)) {
                            $('#menu-delete-' + this.id, postit).remove();
                        }

                        if (!((responsible || $.icescrum.user.scrumMaster) && this.state != $.icescrum.task.STATE_DONE && ($.icescrum.sprint.current && this.backlog.id != $.icescrum.sprint.current.id))) {
                            $('#menu-blocked-' + this.id, postit).remove();
                        }
                        if (this.state == $.icescrum.task.STATE_DONE) {
                            $('#menu-edit-' + this.id, postit).remove();
                        }
                        if (this.state == $.icescrum.task.STATE_DONE || responsible) {
                            $('#menu-take-' + this.id, postit).remove();
                        }
                        if (this.state == $.icescrum.task.STATE_DONE || !responsible) {
                            $('#menu-unassign-' + this.id, postit).remove();
                        }

                        if (this.state != $.icescrum.task.STATE_DONE) {
                            responsible ? $('#menu-unassign-' + this.id, postit).addClass('first') : $('#menu-take-' + this.id, postit).addClass('first');
                        } else {
                            $('#menu-copy-' + this.id, postit).addClass('first')
                        }

                        this.blocked ? $('#menu-blocked-' + this.id + ' a', postit).text($.icescrum.task.UNBLOCK) : $('#menu-blocked-' + this.id + ' a', postit).text($.icescrum.task.BLOCK);

                        if (this.backlog.state != $.icescrum.sprint.STATE_DONE) {
                            if (this.state != $.icescrum.task.STATE_DONE && (responsible || (!responsible && creator) || $.icescrum.user.scrumMaster)) {
                                $('.mini-value', postit).addClass('editable editable-hover');
                                if ((responsible || $.icescrum.user.scrumMaster)) {
                                    if (this.parentStory && this.parentStory.state == $.icescrum.story.STATE_DONE) {
                                        //do nothing
                                    } else {
                                        $('.postit-label', postit).addClass('postit-sortable');
                                    }
                                }
                            }
                        }
                    },

                    toggleBlocked:function(id) {
                        if ($('#postit-task-' + id + ' .postit-ico,.table-line[elemid=' + id + ']').toggleClass('ico-task-1').hasClass('ico-task-1')) {
                            $('#menu-blocked-' + id + ' a').text($.icescrum.task.UNBLOCK);
                            $('#postit-task-' + id + ' .postit-ico,.table-line[elemid=' + id + ']').attr('title', $.icescrum.task.BLOCKED);
                        } else {
                            $('#menu-blocked-' + id + ' a').text($.icescrum.task.BLOCK);
                            $('#postit-task-' + id + ' .postit-ico,.table-line[elemid=' + id + ']').attr('title', '');
                        }
                    }
                },

                sprint:{
                    i18n:{
                        name:'Sprint'
                    },
                    current: null,
                    STATE_WAIT : 1,
                    STATE_INPROGRESS : 2,
                    STATE_DONE : 3,
                    templates:{
                        window:{
                            selector:function() {
                                return this.add ? 'div.event-container' : 'div.event-header';
                            },
                            id:function() {
                                return  this.add ? 'sprint-releasePlan-tmpl' : 'sprint-releasePlan-update-tmpl';
                            },
                            view:function() {
                                return this.add ? 'div.event-overflow' + '[elemid=' + this.parentRelease.id + ']' : this.id ? 'div.event-container' + '[elemid=' + this.id + ']' : 'div.event-container';
                            },
                            constaintTmpl:function() {
                                return $('div.event-overflow').attr('elemid') == this.parentRelease.id;
                            },
                            remove:function() {
                                $('div.event-container[elemid=' + this.id + ']').remove();
                                $('span.event-select-item[elemid=' + this.id + ']').remove();
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
                                $('div.event-select').append($('<span class="event-select-item" elemid="' + this.id + '">' + $.icescrum.sprint.i18n.name + ' ' + this.orderNumber + '</span>'));
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
                                selectOnSprintPlan.selectmenu('add', this.id, this.parentRelease.name + ' - ' + $.icescrum.sprint.i18n.name + ' ' + this.orderNumber);
                            }
                            if (selectOnTimeline.length) {
                                selectOnTimeline.selectmenu('add', $.icescrum.jsonToDate(this.startDate).getTime(), this.parentRelease.name + ' - ' + $.icescrum.sprint.i18n.name + ' ' + this.orderNumber, this.id);
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
                            selectOnTimeline.selectmenu('update', this.id, $.icescrum.jsonToDate(this.startDate).getTime(), this.parentRelease.name + ' - ' + $.icescrum.sprint.i18n.name + ' ' + this.orderNumber);
                        }

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
                                selectOnSprintPlan.selectmenu('remove', this.id);
                            }
                            if (selectOnTimeline.length) {
                                selectOnTimeline.selectmenu('remove', this.id, true, true);

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
                        this.current = null;
                        $('li.menu-accept-task').hide();
                        $('#kanban-sprint-' + this.id + ' td:not(.first)').sortable('destroy');
                        $('.close-sprint-' + this.parentRelease.id + '-' + (this.orderNumber)).remove();
                        $('.activate-sprint-' + this.parentRelease.id + '-' + (this.orderNumber + 1)).removeClass('hidden');
                    },

                    activate:function(template) {
                        if (template) {
                            $.icescrum.sprint.update.apply(this, [template]);
                        }
                        this.current = this;
                        $('#kanban-sprint-' + this.id + ' td.no-drop').removeClass('no-drop');
                        $('.menu-accept-task').show();
                        $('.activate-sprint-' + this.parentRelease.id + '-' + (this.orderNumber)).remove();
                        $('.close-sprint-' + this.parentRelease.id + '-' + (this.orderNumber)).removeClass('hidden');
                    },

                    _postRendering:function(tmpl, newObject) {
                        if (this.state == $.icescrum.sprint.STATE_DONE) {
                            var backlog = $("#backlog-layout-plan-releasePlan-" + this.id);
                            if (backlog.length) {
                                backlog.sortable('disable', true);
                                $('.postit-label.postit-sortable', backlog).removeClass('postit-sortable');
                                $('.event-container[elemid=' + this.id + '] > .event-content-list').droppable('disable', true).removeClass('ui-state-disabled');
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

                    sprintMesure:function() {
                        $(this).each(function() {
                            var header = $('.event-header[elemid=' + this.id + ']');
                            if (header.length) {
                                if (this.state >= $.icescrum.sprint.STATE_INPROGRESS) {
                                    this.velocity = (this.velocity != undefined) ? this.velocity : 0;
                                    this.capacity = (this.capacity != undefined) ? this.capacity : 0;
                                    header.find('.event-header-velocity').html(this.velocity + ' / ' + this.capacity);
                                } else {
                                    header.find('.event-header-velocity').html(this.capacity);
                                }
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
                    }
                },

                release:{
                    add:function() {
                        var select = $('#selectOnTimeline');
                        if (select.length) {
                            select.selectmenu('add', $.icescrum.jsonToDate(this.startDate).getTime(), this.name, this.id);
                        }
                        var release = $('#selectOnReleasePlan');
                        if (release.length) {
                            release.selectmenu('add', this.id, this.name);
                        }
                    },

                    update:function() {
                        var select = $('#selectOnTimeline');
                        if (select.length) {
                            select.selectmenu('update', this.id, $.icescrum.jsonToDate(this.startDate).getTime(), this.name, true);
                        }
                        var release = $('#selectOnReleasePlan');
                        if (release.length) {
                            release.selectmenu('update', this.id, this.id, this.name);
                        }
                    },

                    remove:function() {
                        var select = $('#selectOnTimeline');
                        if (select.length) {
                            select.selectmenu('remove', this.id, true, true);
                        }
                        var release = $('#selectOnReleasePlan');
                        if (release.length) {
                            release.selectmenu('remove', this.id, false, true);
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
                },

                alertDeleteOrUpdateObject:function(message, url, deleted, container) {
                    $('#window-dialog').dialog('destroy');
                    $(document.body).append("<div id='window-dialog'/>");
                    $('#window-dialog').html('<div class="panel ui-corner-all"><h3 class="panel-title">Warning</h3><p class="field-information">' + message + '</p></div>').dialog({
                                dialogClass: 'no-titlebar',
                                closeOnEscape:true,
                                closeText:'Close',
                                draggable:false,
                                modal:true,
                                position:'top',
                                resizable:false,
                                stack:true,
                                width:300,
                                zindex:1000,
                                close:function(ev, ui) {
                                    $(this).remove();
                                    if (deleted) {
                                        $.icescrum.navigateTo(url);
                                    } else {
                                        $(container).load(url);
                                    }
                                },
                                buttons:{
                                    'Refresh':function() {
                                        $(this).dialog('close');
                                    }
                                }
                            });
                },

                addOrUpdate:function(object, _tmpl, after, app) {

                    if ($.isFunction(_tmpl.constraintTmpl)) {
                        if (_tmpl.constraintTmpl.apply(object) == false) {
                            return false;
                        }
                    }

                    var tmpl;
                    tmpl = $.extend(tmpl, _tmpl);
                    tmpl.selector = $.isFunction(tmpl.selector) ? tmpl.selector.apply(object) : tmpl.selector;
                    tmpl.view = $.isFunction(tmpl.view) ? tmpl.view.apply(object) : tmpl.view;
                    tmpl.id = $.isFunction(tmpl.id) ? tmpl.id.apply(object) : tmpl.id;

                    if ($(tmpl.window + ' .box-blank:visible').length) {
                        $(tmpl.view).show();
                        $(tmpl.window + ' .box-blank').hide();
                    }

                    var container = $(tmpl.view);
                    var current = $(tmpl.selector + '[elemid=' + object.id + ']', container);
                    var beforeData = null;

                    if ($.isFunction(tmpl.beforeTmpl)) {
                        beforeData = tmpl.beforeTmpl.apply(object, [tmpl,container,current]);
                    }

                    if (current.length) {
                        $(tmpl.selector + '[elemid=' + object.id + ']', container).jqoteup('#' + tmpl.id, object);
                    }
                    else {
                        app ? container.jqoteapp('#' + tmpl.id, object) : container.jqotepre('#' + tmpl.id, object);
                    }
                    var newObject = $(tmpl.selector + '[elemid=' + object.id + ']', container);

                    if ($.isFunction(after)) {
                        after.apply(object, [tmpl,newObject,container]);
                    }
                    if ($.isFunction(tmpl.afterTmpl)) {
                        tmpl.afterTmpl.apply(object, [tmpl,container,newObject,beforeData]);
                    }

                    return $(tmpl.selector + '[elemid=' + object.id + ']', container);
                }
            });
})($);
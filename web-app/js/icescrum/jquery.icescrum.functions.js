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
                    i18n:{
                        removeRoleProduct:'You have been removed from the project:',
                        addRoleProduct:'You have been added to the project:',
                        updateRoleProduct:'Your role has changed on the project:'
                    },

                    scrumMaster:false,
                    productOwner:false,
                    teamMember:false,
                    stakeHolder:true,
                    poOrSm:function() {
                        return (this.scrumMaster || this.productOwner);
                    },

                    addRoleProduct:function(){
                        if ($('li#product-'+this.product.id).length == 0){
                            var newProduct = $('<li></li>').attr('id','product-'+this.product.id);
                            var a = $('<a></a>').attr('href',$.icescrum.o.baseUrl +'p/'+ this.product.pkey +'#project');
                            a.text(this.product.name);
                            a.appendTo(newProduct);
                            var projects = $('div#menu-project li#my-projects');
                            newProduct.insertAfter(projects);
                            if (projects.is(':hidden')){
                                projects.show();
                            }
                        }
                        $.icescrum.renderNotice($.icescrum.user.i18n.addRoleProduct+' '+this.product.name);
                        if ($.icescrum.product.id && $.icescrum.product.id == this.product.id){
                            $.doTimeout(500, function() {
                                document.location.reload(true);
                            });
                        }
                    },

                    removeRoleProduct:function(){
                        $('li#product-'+this.product.id+':not(.owner)').remove();
                        if ($('div#menu-project li.projects').length == 0){
                            $('div#menu-project li#my-projects').hide();
                        }
                        $.icescrum.renderNotice($.icescrum.user.i18n.removeRoleProduct+' '+this.product.name);
                        if ($.icescrum.product.id && $.icescrum.product.id == this.product.id){
                            $.doTimeout(500, function() {
                                document.location = $.icescrum.o.baseUrl;
                            });
                        }
                    },

                    updateRoleProduct:function(){
                        $.icescrum.renderNotice($.icescrum.user.i18n.updateRoleProduct+' '+this.product.name);
                        if ($.icescrum.product.id && $.icescrum.product.id == this.product.id){
                            $.doTimeout(500, function() {
                                document.location.reload(true);
                            });
                        }
                    },

                    updateProfile:function(){
                        $('#profile-name a').html(this.user.name);
                        $('#user-tooltip-username').html(this.user.name);
                        if (this.updateAvatar) {
                            var avatar = this.updateAvatar;
                            $('.avatar-user-' + this.user.userid).each(
                                    function() {
                                        $(this).attr('src', avatar + '?nocache=' + new Date().getTime());
                                    }
                            )
                        }

                        if (this.user.forceRefresh) {
                            $.doTimeout(500, function() {
                                document.location.reload(true);
                            })
                        }
                        $.icescrum.renderNotice(this.user.notice, 'notice');
                    }
                },


                product: {
                    id:null,
                    pkey:null,
                    displayUrgentTasks:true,
                    displayRecurrentTasks:true,
                    assignOnBeginTask:false,
                    hidden:false,
                    limitUrgentTasks:0,
                    timezoneOffset:0,
                    i18n : {
                        deleted:'Project deleted',
                        updated:'Project settings updated',
                        archived:'Project archived',
                        unArchived:'Project unarchived'
                    },

                    add:function() {
                        //TODO ?
                    },

                    update:function() {
                        if (this.id == $.icescrum.product.id){
                            if (this.pkey != $.icescrum.product.pkey){
                                alert($.icescrum.product.i18n.updated);
                                var view = $.icescrum.o.currentOpenedWindow ? $.icescrum.o.currentOpenedWindow.data('id') : 'project';
                                document.location = $.icescrum.o.baseUrl + 'p/' + this.pkey + '#' + view;
                                return;
                            }

                            $("div#menu-project .dropmenu-button span.content").text(this.name);

                            if (this.preferences.hidden != $.icescrum.product.hidden && $.icescrum.user.stakeHolder && this.preferences.hidden){
                                alert($.icescrum.product.i18n.updated);
                                $.doTimeout(500, function() {
                                    document.location.reload(true);
                                });
                                return;
                            }
                            if ($.icescrum.product.displayUrgentTasks != this.preferences.displayUrgentTasks){
                                $('tr.row-urgent-task').toggle();
                                $('tr.table-line.table-group[data-elemid=urgent]').toggle();
                                $.icescrum.product.displayUrgentTasks = this.preferences.displayUrgentTasks;
                            }
                            if (this.preferences.displayRecurrentTasks != $.icescrum.product.displayRecurrentTasks){
                                $('tr.row-recurrent-task').toggle();
                                $('tr.table-line.table-group[data-elemid=recurrent]').toggle();
                                $.icescrum.product.displayRecurrentTasks = this.preferences.displayRecurrentTasks;
                            }
                            if (this.preferences.limitUrgentTasks != $.icescrum.product.limitUrgentTasks){
                                var text = $('#limit-urgent-tasks').text();
                                var reg=new RegExp($.icescrum.product.limitUrgentTasks, "g");
                                $('#limit-urgent-tasks').text(text.replace(reg,this.preferences.limitUrgentTasks));
                                if (this.preferences.limitUrgentTasks > 0){
                                    $('#limit-urgent-tasks').show();
                                }else{
                                    $('#limit-urgent-tasks').hide();
                                }
                                $.icescrum.product.limitUrgentTasks = this.preferences.limitUrgentTasks;
                            }
                            if ($.icescrum.product.assignOnBeginTask != this.preferences.assignOnBeginTask){
                                $.icescrum.product.assignOnBeginTask = this.preferences.assignOnBeginTask;
                                $.icescrum.sprint.sortableTasks();
                            }
                            $('#project-details ul li:first strong').text(this.name);
                            if (this.description){
                                $('#panel-description .panel-box-content').load($.icescrum.o.baseUrl + 'textileParser', {data:this.description,withoutHeader:true});
                            }
                        }
                    },

                    remove:function() {
                        if (this.id == $.icescrum.product.id){
                            alert($.icescrum.product.i18n.deleted);
                            document.location = $.icescrum.o.baseUrl;
                        }
                    },

                    archive:function() {
                        if (this.id == $.icescrum.product.id){
                            alert($.icescrum.product.i18n.archived);
                            $.doTimeout(500, function() {
                                document.location.reload(true);
                            });
                        }
                    },

                    unarchive:function() {
                        if (this.id == $.icescrum.product.id){
                            alert($.icescrum.product.i18n.unArchived);
                            $.doTimeout(500, function() {
                                document.location.reload(true);
                            });
                        }
                    },

                    redirect:function() {
                        if (document.location.href.indexOf($.icescrum.o.grailsServer+'/p/'+this.pkey) > -1 ){
                            document.location.reload();
                        }else{
                            document.location = $.icescrum.o.grailsServer+'/p/'+this.pkey+'#project';
                        }
                    }
                },

                actor: {
                    templates:{
                        window:{
                            selector:function() {
                                return $.icescrum.getDefaultView() == 'postitsView' ? 'div.postit-actor' : 'tr.table-line';
                            },
                            id:function() {
                                return $.icescrum.getDefaultView() == 'postitsView' ? 'postit-actor-tmpl' : 'table-row-actor-tmpl';
                            },
                            view:function() {
                                return $.icescrum.getDefaultView() == 'postitsView' ? '#backlog-layout-window-actor' : '#actor-table';
                            },
                            remove:function(tmpl) {
                                $.icescrum.getDefaultView() == 'postitsView' ? $(tmpl.view+' '+'.postit-actor[data-elemid=' + this.id + ']').remove() : $('#actor-table .table-line[data-elemid=' + this.id + ']').remove();
                                if ($.icescrum.getDefaultView() == 'tableView') {
                                    $('#actor-table').trigger("update");
                                }
                            },
                            window:'#window-content-actor',
                            afterTmpl:function(tmpl) {
                                if ($.icescrum.getDefaultView() == 'tableView') {
                                    $('#actor-table').trigger("update");
                                }
                            }
                        },
                        widget:{
                            selector:'li.postit-row-actor',
                            id:'postit-row-actor-tmpl',
                            view:'#backlog-layout-widget-actor',
                            remove:function() {
                                $('.postit-row-actor[data-elemid=' + this.id + ']').remove();
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
                            tmpl.remove.apply(this,[tmpl]);
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
                        features:{
                            selector:function() {
                                return $.icescrum.getDefaultView() == 'postitsView' ? 'div.postit-feature' : 'tr.table-line';
                            },
                            id:function() {
                                return $.icescrum.getDefaultView() == 'postitsView' ? 'postit-feature-tmpl' : 'table-row-feature-tmpl';
                            },
                            view:function() {
                                return $.icescrum.getDefaultView() == 'postitsView' ? '#backlog-layout-window-feature' : '#feature-table';
                            },
                            remove:function(tmpl) {
                                if ($.icescrum.getDefaultView() == 'tableView') {
                                    var tableline = $('#feature-table .table-line[data-elemid=' + this.id + ']');
                                    var oldRank = tableline.data('rank');
                                    tableline.remove();
                                    $.icescrum.postit.updateRankAndVersion(tmpl.selector, tmpl.view, oldRank);
                                    $('#feature-table').trigger("update");
                                }else{
                                    $(tmpl.view+' '+'.postit-feature[data-elemid=' + this.id + ']').remove();
                                }
                            },
                            window:'#window-content-feature',
                            afterTmpl:function(tmpl, container, newObject) {
                                if ($.icescrum.getDefaultView() == 'tableView') {
                                    $('div[name=rank]', $(newObject)).text(this.rank);
                                    if(this.oldRank != this.rank) {
                                        $.icescrum.postit.updateRankAndVersion(tmpl.selector, tmpl.view, this.oldRank, this.rank, this.id);
                                    }
                                    $('#feature-table').updateTableSorter();
                                }else{
                                    if (this.rank && this.rank != 0) {
                                        $.icescrum.postit.updatePosition(tmpl.selector, newObject, this.rank, container);
                                    }
                                }
                            },
                            beforeTmpl:function(tmpl,container,current) {
                                this.oldRank = current.data('rank');
                            }
                        },
                        widget:{
                            selector:'.postit-row-feature',
                            id:'postit-row-feature-tmpl',
                            view:'#backlog-layout-widget-feature',
                            remove:function(tmpl) {
                                $(tmpl.view+' '+'.postit-row-feature[data-elemid=' + this.id + ']').remove();
                            },
                            window:'#widget-content-feature',
                            afterTmpl:function(tmpl, container, newObject) {
                                if (this.rank && this.rank != 0) {
                                    $.icescrum.postit.updatePosition(tmpl.selector, newObject, this.rank, container);
                                }
                            }
                        }
                    },

                    add:function(template) {
                        $(this).each(function() {
                            $.icescrum.addOrUpdate(this, $.icescrum.feature.templates[template], $.icescrum.feature._postRendering);
                        });
                    },

                    update:function(template) {
                        var feature = this;
                        $(feature.stories).each(function() {
                            $('div.postit-story[data-elemid=' + this.id + '] .postit-layout').removeClass().addClass('postit-layout postit-' + feature.color);
                            $('li.postit-row-story[data-elemid=' + this.id + '] .postit-icon').removeClass().addClass('postit-icon postit-icon-' + feature.color);
                        });
                        $('#detail-feature-' + feature.id + ' .line-right').replaceWith('<td class="line-right"><span class="postit-icon postit-icon-' + feature.color + '" title="' + feature.name + '"></span>' + feature.name + '</td>');
                        if (template){
                            $.icescrum.addOrUpdate(feature, $.icescrum.feature.templates[template], $.icescrum.feature._postRendering);
                        }
                    },

                    remove:function(template) {
                        var tmpl;
                        tmpl = $.extend(tmpl, $.icescrum.feature.templates[template]);
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
                    },

                    _postRendering:function(tmpl, newObject, container) {
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
                    i18n : {
                        stories:'stories',
                        points:'points'
                    },
                    templates:{
                        sandbox:{
                            selector:function() {
                                return $.icescrum.getDefaultView() == 'postitsView' ? 'div.postit-story' : 'tr.table-line';
                            },
                            id:function() {
                                return $.icescrum.getDefaultView() == 'postitsView' ? 'postit-story-sandbox-tmpl' : 'table-row-story-sandbox-tmpl';
                            },
                            view:function() {
                                return $.icescrum.getDefaultView() == 'postitsView' ? '#backlog-layout-window-sandbox' : '#story-table';
                            },
                            remove:function(tmpl) {
                                var story = $.icescrum.getDefaultView() == 'postitsView' ? $(tmpl.view+' .postit-story[data-elemid=' + this.id + ']') : $(tmpl.view+' .table-line[data-elemid=' + this.id + ']');
                                this.rank = story.index() + 1;
                                story.remove();
                                if ($.icescrum.getDefaultView() == 'tableView') {
                                    $(tmpl.view).trigger("update");
                                }
                            },
                            constraintTmpl:function() {
                                return this.state == $.icescrum.story.STATE_SUGGESTED;
                            },
                            window:'#window-content-sandbox',
                            afterTmpl:function(tmpl, container, newObject) {
                                if (this.rank){
                                    $.icescrum.postit.updatePosition(tmpl.selector, newObject, this.rank, container);
                                }
                                if ($.icescrum.getDefaultView() == 'tableView') {
                                    $('#story-table').trigger("update");
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
                            }
                        }
                    },

                    add:function(template, append) {
                        $(this).each(function() {
                            $.icescrum.addOrUpdate(this, $.icescrum.story.templates[template], $.icescrum.story._postRendering, append);
                        });
                    },

                    update:function(template, append) {
                        $(this).each(function() {
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

                    associated:function(template) {
                        $.icescrum.story.update.apply(this, [template]);
                    },

                    dissociated:function(template) {
                        $.icescrum.story.update.apply(this, [template]);
                    },

                    _postRendering:function(tmpl, newObject, container) {
                        if (this.totalComments <= 0 ) {
                            newObject.find('.postit-comment,.table-comment').hide();
                        }
                        if (!this.dependsOn) {
                            newObject.find('.dependsOn').remove();
                        }
                        if(!this.acceptanceTests || this.acceptanceTests.length <= 0) {
                            newObject.find('.postit-acceptance-test,.table-acceptance-test').hide();
                        }
                        if (this.totalAttachments <= 0) {
                            newObject.find('.postit-attachment,.table-attachment').hide()
                        }
                        if (container.hasClass('ui-selectable')) {
                            newObject.addClass('ui-selectee');
                        }

                        var creator = (this.creator.id == $.icescrum.user.id);
                        if (!((this.state == $.icescrum.story.STATE_SUGGESTED && creator) || (this.state >= $.icescrum.story.STATE_SUGGESTED && this.state != $.icescrum.story.STATE_DONE && $.icescrum.user.productOwner))) {
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
                        jQuery('#window-title-bar-backlog .content .details').html(' - <span id="stories-backlog-size">'+size+'</span> '+$.icescrum.story.i18n.stories+' / <span id="stories-backlog-effort">'+effort+'</span> '+$.icescrum.story.i18n.points);
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
                                return (this.type == $.icescrum.task.TYPE_RECURRENT || this.type == $.icescrum.task.TYPE_URGENT) ? '#kanban-sprint' + '-' + this.sprint.id + ' .table-line[type=' + this.type + '] .kanban-col[type=' + this.state + ']' : this.sprint ? '#kanban-sprint' + '-' + this.sprint.id + ' .row-story[data-elemid=' + this.parentStory.id + '] .kanban-col[type=' + this.state + ']' : '';
                            },
                            remove:function() {
                                $('.kanban-col .postit-task[data-elemid=' + this.id + ']').remove();
                            }
                        }
                    },
                    add:function(template) {
                        $(this).each(function() {
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
                        $.icescrum.sprint.updateRemaining();
                    },

                    _postRendering:function(tmpl, postit) {

                        if ($(tmpl.view + '-' + this.sprint.id).hasClass('ui-selectable') && this.sprint.state != $.icescrum.sprint.STATE_DONE) {
                            postit.addClass('ui-selectee');
                        }
                        if (this.totalAttachments == undefined || !this.totalAttachments) {
                            postit.find('.postit-attachment').hide();
                        }

                        var responsible = (this.responsible && this.responsible.id == $.icescrum.user.id) ? true : false;
                        var creator = this.creator.id == $.icescrum.user.id;
                        var taskDone = this.state == $.icescrum.task.STATE_DONE;

                        var taskEditable = ($.icescrum.user.scrumMaster || responsible || creator) && !taskDone;
                        var taskDeletable = $.icescrum.user.scrumMaster || responsible || creator;
                        var taskBlockable = ($.icescrum.user.scrumMaster || responsible) && !taskDone && this.sprint.state == $.icescrum.sprint.STATE_INPROGRESS;
                        var taskSortable = ($.icescrum.user.scrumMaster || responsible || ($.icescrum.product.assignOnBeginTask && this.state == $.icescrum.task.STATE_WAIT)) && !taskDone;
                        var taskTakable = !responsible && !taskDone;
                        var taskReleasable = responsible && !taskDone;
                        var taskCopyable = !this.parentStory || this.parentStory.state != $.icescrum.story.STATE_DONE;

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
                    },

                    toggleBlocked:function(data) {
                        if ($('#postit-task-' + data.id + ' .postit-ico,.table-line[data-elemid=' + data.id + ']').toggleClass('ico-task-1').hasClass('ico-task-1')) {
                            $('#menu-blocked-' + data.id + ' a').text($.icescrum.task.UNBLOCK);
                            $('#postit-task-' + data.id + ' .postit-ico,.table-line[data-elemid=' + data.id + ']').attr('title', $.icescrum.task.BLOCKED);
                        } else {
                            $('#menu-blocked-' + data.id + ' a').text($.icescrum.task.BLOCK);
                            $('#postit-task-' + data.id + ' .postit-ico,.table-line[data-elemid=' + data.id + ']').attr('title', '');
                        }
                    }
                },

                sprint:{
                    i18n:{
                        name:'Sprint',
                        noDropMessage:'',
                        noDropMessageLimitedTasks:'',
                        totalRemainingHours:'',
                        hours:''
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
                        $('table#kanban-sprint-' + this.id).addClass('done');
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

                    updateWindowTitle:function(sprint){
                        if ($("#selectOnSprintPlan") && $("#selectOnSprintPlan").val() == sprint.id){
                            $('#window-title-bar-sprintPlan .content .details').html(' - '+$.icescrum.sprint.i18n.name+' '+sprint.orderNumber+' - '+$.icescrum.sprint.states[sprint.state]+' - ['+$.icescrum.dateLocaleFormat(sprint.startDate)+' -> '+$.icescrum.dateLocaleFormat(sprint.endDate)+'] - '+$.icescrum.sprint.i18n.totalRemainingHours+' <span class="remaining">'+sprint.totalRemainingHours+'</span> '+$.icescrum.sprint.i18n.hours);
                        }
                    },

                    updateRemaining:function(){
                        var remaining = 0;
                        $('table.table.kanban div.postit-task span.mini-value').each(function(){
                            var val = $(this).text();
                            if (val != '?'){
                                remaining += parseFloat(val);
                            }
                        });
                        $('#window-title-bar-sprintPlan span.remaining').html(remaining);
                    },

                    sprintMesure:function() {
                        $(this).each(function() {
                            var header = $('.event-header[data-elemid=' + this.id + ']');
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

                comment:{

                    i18n:{
                        noComment:'No comment'
                    },

                    templates:{
                        storyDetail:{
                            selector:'li.comment',
                            id:'comment-storydetail-tmpl',
                            view:'ul.list-comments',
                            remove:function(tmpl) {
                                var commentList = $(tmpl.view);
                                var comment = $(tmpl.selector + '[data-elemid=' + this.id + ']', commentList);
                                comment.remove();
                                if ($(tmpl.selector, commentList).length == 0) {
                                    commentList.html('<li class="panel-box-empty">' + $.icescrum.comment.i18n.noComment + '</li>');
                                }
                            }
                        },
                        storyDetailSummary:{
                            selector:'li.comment',
                            id:'comment-storydetailsummary-tmpl',
                            view:'ul.list-news',
                            remove:function(tmpl) {
                                var summary = $(tmpl.view);
                                var comment = $(tmpl.selector + '[data-elemid=' + this.id + ']', summary);
                                comment.remove();
                            }
                        }
                    },

                    add:function(template) {
                        var tmpl = $.icescrum.comment.templates[template];
                        var commentList = $(tmpl.view);
                        if(commentList.find('li.panel-box-empty').length > 0) {
                           commentList.html('');
                        }
                        $(this).each(function() {
                            var comment = $.icescrum.addOrUpdate(this, tmpl, $.icescrum.comment._postRendering);
                            comment.appendTo(commentList);
                            $('.comment-lastUpdated', comment).hide();
                        });
                    },

                    update:function(template) {
                        $(this).each(function() {
                            $.icescrum.addOrUpdate(this, $.icescrum.comment.templates[template], $.icescrum.comment._postRendering);
                        });
                    },

                    remove:function(template) {
                        var tmpl = $.icescrum.comment.templates[template];
                        $(this).each(function() {
                            tmpl.remove.apply(this, [tmpl]);
                        });
                    },

                    _postRendering:function(tmpl, comment) {
                        var isPoster = (this.poster.id == $.icescrum.user.id);
                        if(!$.icescrum.user.poOrSm()) {
                            if(!isPoster) {
                                comment.find('.menu-comment').remove();
                            }
                            else {
                                comment.find('.delete-comment').remove();
                            }
                        }
                        $('.comment-body', comment).load(jQuery.icescrum.o.baseUrl + 'textileParser', {data:this.body,withoutHeader:true});
                        $('.comment-avatar', comment).load(jQuery.icescrum.o.baseUrlProduct + 'user/displayAvatar', {id:this.poster.id, email:this.poster.email});
                    }

                },

                acceptancetest:{

                    i18n:{
                        noAcceptanceTest:'no acceptance test'
                    },

                    templates:{
                        storyDetail:{
                            selector:'li.acceptance-test',
                            id:'acceptancetest-storydetail-tmpl',
                            view:'ul.list-acceptance-tests',
                            remove:function(tmpl) {
                                var acceptanceTests = $(tmpl.view);
                                var acceptanceTest = $(tmpl.selector + '[data-elemid=' + this.id + ']', acceptanceTests);
                                acceptanceTest.remove();
                                if ($(tmpl.selector, acceptanceTests).length == 0) {
                                    acceptanceTests.html('<li class="panel-box-empty">' + $.icescrum.acceptancetest.i18n.noAcceptanceTest + '</li>');
                                }
                            }
                        }
                    },

                    add:function(template) {
                        var tmpl = $.icescrum.acceptancetest.templates[template];
                        var acceptanceTests = $(tmpl.view);
                        if(acceptanceTests.find('li.panel-box-empty').length > 0) {
                           acceptanceTests.html('');
                        }
                        $(this).each(function() {
                            var acceptanceTest = $.icescrum.addOrUpdate(this, tmpl, $.icescrum.acceptancetest._postRendering);
                            acceptanceTest.appendTo(acceptanceTests);
                        });
                    },

                    update:function(template) {
                        $(this).each(function() {
                            $.icescrum.addOrUpdate(this, $.icescrum.acceptancetest.templates[template], $.icescrum.acceptancetest._postRendering);
                        });
                    },

                    _postRendering:function(tmpl, acceptanceTest) {
                        var isCreator = (this.creator.id == $.icescrum.user.id);
                        if(!$.icescrum.user.scrumMaster && !isCreator) {
                           acceptanceTest.find('.acceptance-test-menu').remove();
                        }
                        var description = $('.acceptance-test-description', acceptanceTest);
                        if(this.description != null) {
                            description.load(jQuery.icescrum.o.baseUrl + 'textileParser', {data:this.description,withoutHeader:true});
                        } else {
                            description.text('');
                        }
                    },

                    remove:function(template) {
                        var tmpl = $.icescrum.acceptancetest.templates[template];
                        $(this).each(function() {
                            tmpl.remove.apply(this, [tmpl]);
                        });
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
                    var current = $(tmpl.selector + '[data-elemid=' + object.id + ']', container);
                    var beforeData = null;
                    if ($.isFunction(tmpl.beforeTmpl)) {
                        beforeData = tmpl.beforeTmpl.apply(object, [tmpl,container,current]);
                    }

                    if (current.length) {
                        $(tmpl.selector + '[data-elemid=' + object.id + ']', container).jqoteup('#' + tmpl.id, object);
                    }
                    else {
                        app ? container.jqoteapp('#' + tmpl.id, object) : container.jqotepre('#' + tmpl.id, object);
                    }
                    var newObject = $(tmpl.selector + '[data-elemid=' + object.id + ']', container);

                    if ($.isFunction(after)) {
                        after.apply(object, [tmpl,newObject,container]);
                    }
                    if ($.isFunction(tmpl.afterTmpl)) {
                        tmpl.afterTmpl.apply(object, [tmpl,container,newObject,beforeData]);
                    }

                    return $(tmpl.selector + '[data-elemid=' + object.id + ']', container);
                }
            });
})($);
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
        product: {
            id:null,
            pkey:null,
            displayUrgentTasks:true,
            displayRecurrentTasks:true,
            assignOnBeginTask:false,
            hidden:false,
            limitUrgentTasks:0,
            timezoneOffset:0,
            estimatedSprintsDuration:14,
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
                        document.location = $.icescrum.o.baseUrl + 'p/' + this.pkey + '#/' + view;
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
                        var $urgentTasks = $('#limit-urgent-tasks');
                        var text = $urgentTasks.text();
                        var reg=new RegExp($.icescrum.product.limitUrgentTasks, "g");
                        $urgentTasks.text(text.replace(reg,this.preferences.limitUrgentTasks));
                        if (this.preferences.limitUrgentTasks > 0){
                            $urgentTasks.show();
                        }else{
                            $urgentTasks.hide();
                        }
                        $.icescrum.product.limitUrgentTasks = this.preferences.limitUrgentTasks;
                    }
                    if ($.icescrum.product.assignOnBeginTask != this.preferences.assignOnBeginTask){
                        $.icescrum.product.assignOnBeginTask = this.preferences.assignOnBeginTask;
                        $.icescrum.sprint.sortableTasks();
                    }
                    $('#project-details').find('ul li:first strong').text(this.name);
                    if (this.description){
                        $('#panel-description').find('.panel-box-content').load($.icescrum.o.baseUrl + 'textileParser', {data:this.description,withoutHeader:true});
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
                    document.location = $.icescrum.o.grailsServer+'/p/'+this.pkey+'#/project';
                }
            }
        }
    });

})($);
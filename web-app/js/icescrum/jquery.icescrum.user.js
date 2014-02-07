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

            inProduct:function() {
                return (this.scrumMaster || this.productOwner || this.teamMember);
            },

            creator:function(object) {
                return this.id == object.creator.id;
            },

            authSuccess:function(data){
                $.doTimeout(500, function() {
                    document.location.reload(true);
                });
                return false;
            },

            registerSuccess:function(data){
                $.doTimeout(500, function() {
                    document.location = $.icescrum.o.baseUrl+'?lang='+data.lang+'#!login';
                });
                return true;
            },

            retrieveSuccess: function(data){
                $.doTimeout(500, function() {
                    document.location = $.icescrum.o.baseUrl+'#!login';
                });
                return true;
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
                $('#profile-name').find('a').html(this.user.name);
                $('#user-tooltip-username').html(this.user.name);
                if (this.user.updateAvatar) {
                    var avatar = this.user.updateAvatar;
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
        }
    });

})($);
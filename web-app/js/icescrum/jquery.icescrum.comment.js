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
                        commentList.find('li.last').removeClass('last');
                        commentList.find('li:last').addClass('last');
                    },
                    afterTmpl:function(tmpl, container){
                        container.find('li.last').removeClass('last');
                        container.find('li:last').addClass('last');
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
                        summary.find('li.last').removeClass('last');
                        summary.find('li:last').addClass('last');
                    }
                },
                taskDetail:{
                    selector:'li.comment',
                    id:'comment-taskdetail-tmpl',
                    view:'ul.list-comments',
                    remove:function(tmpl) {
                        var commentList = $(tmpl.view);
                        var comment = $(tmpl.selector + '[data-elemid=' + this.id + ']', commentList);
                        comment.remove();
                        if ($(tmpl.selector, commentList).length == 0) {
                            commentList.html('<li class="panel-box-empty">' + $.icescrum.comment.i18n.noComment + '</li>');
                        } else {
                            commentList.find('li.last').removeClass('last');
                            commentList.find('li:last').addClass('last');
                        }
                    }
                },
                taskDetailSummary:{
                    selector:'li.comment',
                    id:'comment-taskdetailsummary-tmpl',
                    view:'ul.list-news',
                    remove:function(tmpl) {
                        var summary = $(tmpl.view);
                        var comment = $(tmpl.selector + '[data-elemid=' + this.id + ']', summary);
                        comment.remove();
                        summary.find('li.last').removeClass('last');
                        summary.find('li:last').addClass('last');
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
                    var comment = $.icescrum.addOrUpdate(this, tmpl, $.icescrum.comment._postRendering, true);
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

            _postRendering:function(tmpl, comment, container) {
                container.find('li.last').removeClass('last');
                container.find('li:last').addClass('last');
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
                //todo change to new avatar management
                $('.comment-avatar', comment).load(jQuery.icescrum.o.baseUrlSpace + 'user/displayAvatar', {id:this.poster.id, email:this.poster.email});
            }

        }
    })
})($);
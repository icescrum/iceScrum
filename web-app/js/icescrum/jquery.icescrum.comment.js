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
        comment: {
            add:function(data, event, xhr, elem){
                var commentable = _.findWhere($.icescrum[elem.data('commentableType')].data, {id:elem.data('commentableId')});
                commentable._comments.push(data);
                elem.find('textarea').val('').trigger('hide.mkp');
            },
            update:function(data, event, xhr, elem){
                elem.hide().parents('table:first').parent().find('.comment-editor').show().find('textarea').val('').trigger('hide');
                var commentable = _.findWhere($.icescrum[elem.data('commentableType')].data, {id:elem.data('commentableId')});
                var indexOf = _.indexOf(commentable._comments, _.find(commentable._comments, { id:elem.data('commentId') }));
                //replace current comment
                commentable._comments.splice(indexOf, 1, data);
            },
            'delete':function(data, event, xhr, elem){
                var commentable = _.findWhere($.icescrum[elem.data('commentableType')].data, {id:elem.data('commentableId')});
                commentable._comments = _.reject(commentable._comments, function(item) {
                    return item.id === elem.data('commentId');
                });
            },
            edit:function(data){
                var commentable = _.findWhere($.icescrum[data.commentableType].data, { id:data.commentableId });
                var comment =  _.findWhere(commentable._comments, { id:data.commentId });
                var $editor = $('#' + data.commentableType + '-' + data.commentableId + '-' + data.commentId );
                var oldContent = $editor.html();
                $editor = $editor.replaceWithPush($.template('comment-edit', {commentable:commentable, comment:comment}));
                attachOnDomUpdate($editor);
                $editor.parents('table:first').parent().find('.comment-editor').hide().find('textarea').val('').trigger('hide');
                $editor.find('textarea').on('cancel.mkp', function(){
                    $editor = $editor.replaceWithPush('<tr id="'+ data.commentableType + '-' + data.commentableId + '-' + data.commentId+'">'+oldContent+'</tr>');
                    $editor.parents('table:first').parent().find('.comment-editor').show();
                    attachOnDomUpdate($editor);
                }).focus();

            }
        }
    })
})($);
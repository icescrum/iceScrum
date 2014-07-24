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
services.factory( 'Comment', [ 'Resource', function( $resource ) {
    return $resource( 'comment/:type/:typeId/:id',
        { id: '@id', typeId:'@typeId', type:'@type' } ,
        {
            query: {method:'GET', isArray:true, cache: true}
        });
}]);

services.service("CommentService", ['Comment', '$q', function(Comment, $q) {
    this.save = function(comment, commentable){
        comment.class = 'comment';
        comment.type = commentable.class.toLowerCase();
        comment.typeId = commentable.id;
        comment.commentable = {id:commentable.id};
        Comment.save(comment, function(comment){
            commentable.comments.push(comment);
            commentable.comments_count += 1;
        });
    };
    this['delete'] = function(comment, commentable){
        comment.type = commentable.class.toLowerCase();
        comment.typeId = commentable.id;
        comment.commentable = {id:commentable.id};
        comment.$delete(function(){
            if (commentable){
                var index = commentable.comments.indexOf(comment);
                if (index != -1){
                    commentable.comments.splice(index, 1);
                    commentable.comments_count -= 1;
                }
            }
        });
    };
    this.update = function(comment, commentable){
        comment.type = commentable.class.toLowerCase();
        comment.typeId = commentable.id;
        comment.commentable = {id:commentable.id};
        comment.$update(function(data){
            var index = commentable.comments.indexOf(_.findWhere(commentable.comments, { id: comment.id }));
            if (index != -1) {
                commentable.comments.splice(index, 1, data);
            }
        });
    };
    this.list = function(commentable){
        Comment.query({ typeId: commentable.id, type:commentable.class.toLowerCase() }, function(data){
            commentable.comments = data;
        });
    }
}]);
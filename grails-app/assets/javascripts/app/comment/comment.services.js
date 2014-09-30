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
services.factory('Comment', [ 'Resource', function($resource) {
    return $resource('comment/:type/:typeId/:id', { typeId: '@typeId', type: '@type' });
}]);

services.service("CommentService", ['$q', 'Comment', 'Session', function($q, Comment, Session) {
    this.save = function(comment, commentable) {
        comment.class = 'comment';
        comment.type = commentable.class.toLowerCase();
        comment.typeId = commentable.id;
        comment.commentable = {id: commentable.id};
        return Comment.save(comment, function(comment) {
            commentable.comments.push(comment);
            commentable.comments_count = commentable.comments.length;
        }).$promise;
    };
    this['delete'] = function(comment, commentable) {
        comment.type = commentable.class.toLowerCase();
        comment.typeId = commentable.id;
        comment.commentable = {id: commentable.id};
        return comment.$delete(function() {
            _.remove(commentable.comments, { id: comment.id });
            commentable.comments_count = commentable.comments.length;
        });
    };
    this.update = function(comment, commentable) {
        comment.type = commentable.class.toLowerCase();
        comment.typeId = commentable.id;
        comment.commentable = {id: commentable.id};
        return comment.$update(function(returnedComment) {
            angular.extend(_.findWhere(commentable.comments, { id: comment.id }), returnedComment);
        });
    };
    this.list = function(commentable) {
        if (_.isEmpty(commentable.comments)) {
            return Comment.query({ typeId: commentable.id, type: commentable.class.toLowerCase() }, function(data) {
                commentable.comments = data;
                commentable.comments_count = commentable.comments.length;
            }).$promise;
        } else {
            return $q.when(commentable.comments);
        }
    };
    this.authorizedComment = function(action, comment) {
        switch (action) {
            case 'create':
                return Session.authenticated();
            case 'update':
                return Session.user.id == comment.poster.id;
            case 'delete':
                return Session.poOrSm() || Session.user.id == comment.poster.id;
            default:
                return false;
        }
    }
}]);
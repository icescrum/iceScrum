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
services.factory('Comment', ['Resource', function($resource) {
    return $resource('/p/:projectId/comment/:type/:typeId/:id');
}]);

services.service("CommentService", ['$q', 'Comment', 'Session', 'IceScrumEventType', 'CacheService', 'PushService', function($q, Comment, Session, IceScrumEventType, CacheService, PushService) {
    var self = this;
    var crudMethods = {};
    crudMethods[IceScrumEventType.CREATE] = function(comment) {
        CacheService.addOrUpdate('comment', comment);
    };
    crudMethods[IceScrumEventType.UPDATE] = function(comment) {
        CacheService.addOrUpdate('comment', comment);
    };
    crudMethods[IceScrumEventType.DELETE] = function(comment) {
        CacheService.remove('comment', comment.id);
    };
    _.each(crudMethods, function(crudMethod, eventType) {
        PushService.registerListener('comment', eventType, crudMethod);
    });
    this.mergeComments = function(comment) {
        _.each(comment, crudMethods[IceScrumEventType.UPDATE]);
    };
    this.save = function(comment, commentable, projectId) {
        comment.class = 'comment';
        comment.commentable = {id: commentable.id};
        return Comment.save({projectId: projectId, type: commentable.class.toLowerCase(), typeId: commentable.id}, comment, crudMethods[IceScrumEventType.CREATE]).$promise;
    };
    this['delete'] = function(comment, commentable, projectId) {
        comment.commentable = {id: commentable.id};
        return Comment.delete({projectId: projectId, type: commentable.class.toLowerCase(), typeId: commentable.id}, comment, crudMethods[IceScrumEventType.DELETE]).$promise;
    };
    this.update = function(comment, commentable, projectId) {
        comment.commentable = {id: commentable.id};
        return Comment.update({projectId: projectId, type: commentable.class.toLowerCase(), typeId: commentable.id}, comment, crudMethods[IceScrumEventType.UPDATE]).$promise;
    };
    this.list = function(commentable, projectId) {
        var promise = Comment.query({projectId: projectId, typeId: commentable.id, type: commentable.class.toLowerCase()}, self.mergeComments).$promise;
        return _.isEmpty(commentable.comments) ? promise : $q.when(commentable.comments);
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
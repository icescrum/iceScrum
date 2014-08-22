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
controllers.controller('commentCtrl', ['$scope', 'CommentService', function($scope, CommentService) {
    $scope.setShowCommentForm = function(show) {
        $scope.editComment($scope.editableComment.id, show);
    };
    $scope.getShowCommentForm = function() {
        return ($scope.commentEdit[$scope.editableComment.id] == true);
    };
    $scope.resetCommentForm = function() {
        $scope.editableComment = $scope.comment ? angular.copy($scope.comment) : {};
        if ($scope.getShowCommentForm()) {
            $scope.setShowCommentForm(false);
        }
        if ($scope.formHolder.commentForm) {
            $scope.formHolder.commentForm.$setPristine();
        }
    };
    $scope.saveOrUpdate = function(type, comment, commentable) {
        var promise;
        if (type == 'save') {
            promise = CommentService.save(comment, commentable);
        } else if (type == 'update') {
            promise = CommentService.update(comment, commentable);
        }
        promise.then($scope.resetCommentForm);
    };
    $scope['delete'] = function(comment, commentable) {
        CommentService.delete(comment, commentable);
    };
    $scope.authorizedComment = function(action, comment) {
        return CommentService.authorizedComment(action, comment);
    };
    // Init
    $scope.formHolder = {};
    $scope.resetCommentForm();
    if (_.isEmpty($scope.editableComment) && $scope.authorizedComment('create')) {
        $scope.setShowCommentForm(true);
    }
}]);
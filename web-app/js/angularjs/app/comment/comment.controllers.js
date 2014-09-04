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
    $scope.resetCommentForm = function() {
        $scope.editableComment = $scope.comment ? angular.copy($scope.comment) : {};
        if ($scope.formHolder.commentForm) {
            $scope.formHolder.commentForm.$setPristine();
        }
    };
    $scope.save = function(comment, commentable) {
        CommentService.save(comment, commentable).then($scope.resetCommentForm);
    };
    $scope['delete'] = function(comment, commentable) {
        CommentService.delete(comment, commentable);
    };
    $scope.authorizedComment = function(action, comment) {
        return CommentService.authorizedComment(action, comment);
    };
    $scope.showForm = function(value) {
        $scope.formHolder.showForm = value;
    };
    $scope.editForm = function(value) {
        $scope.formHolder.editing = value;
    };
    $scope.blurComment = function(comment, commentable, $event) {
        if ($($event.target).hasClass('ng-valid')) {
            $scope.showForm(false);
            $scope.editForm(false);
            if ($($event.target).hasClass('ng-dirty')) {
                CommentService.update(comment, commentable);
            }
        }
    };
    // Init
    $scope.formHolder = {};
    $scope.resetCommentForm();
}]);
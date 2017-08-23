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
controllers.controller('commentCtrl', ['$scope', 'CommentService', 'hotkeys', function($scope, CommentService, hotkeys) {
    // Functions
    $scope.resetCommentForm = function() {
        $scope.editableComment = $scope.comment ? angular.copy($scope.comment) : {};
        $scope.formHolder.editing = false;
        $scope.formHolder.expandedForm = false;
        $scope.resetFormValidation($scope.formHolder.commentForm);
    };
    $scope.formEditable = function() {
        return $scope.comment ? $scope.authorizedComment('update', $scope.editableComment) : false
    };
    $scope.formDeletable = function() {
        return $scope.comment ? $scope.authorizedComment('delete', $scope.editableComment) : false
    };
    $scope.save = function(comment, commentable) {
        CommentService.save(comment, commentable)
            .then(function() {
                $scope.resetCommentForm();
                $scope.notifySuccess('todo.is.ui.comment.saved');
            });
    };
    $scope['delete'] = function(comment, commentable) {
        CommentService.delete(comment, commentable)
            .then(function() {
                $scope.notifySuccess('todo.is.ui.deleted');
            });
    };
    $scope.authorizedComment = function(action, comment) {
        return CommentService.authorizedComment(action, comment);
    };
    $scope.editForm = function(value) {
        $scope.formHolder.editing = $scope.formEditable() && value;
        if (value) {
            hotkeys.bindTo($scope).add({
                combo: 'esc',
                allowIn: ['TEXTAREA'],
                callback: $scope.resetCommentForm
            });
        } else {
            hotkeys.del('esc');
        }
    };
    $scope.update = function(comment, commentable) {
        if (!$scope.formHolder.commentForm.$invalid) {
            $scope.editForm(false);
            if ($scope.formHolder.commentForm.$dirty) {
                CommentService.update(comment, commentable)
                    .then(function() {
                        $scope.notifySuccess('todo.is.ui.comment.updated');
                    });
            }
        }
    };
    // Init
    $scope.formHolder = {};
    $scope.resetCommentForm();
}]);

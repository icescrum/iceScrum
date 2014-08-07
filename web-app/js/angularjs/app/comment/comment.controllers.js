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
controllers.controller('commentCtrl', ['$scope', 'CommentService', 'Session', function($scope, CommentService, Session) {

    $scope.setShowForm = function(show) {
        $scope.editComment($scope.comment.id, show);
    };
    $scope.getShowForm = function() {
        return ($scope.commentEdit[$scope.comment.id] == true);
    };
    function initComment() {
        return $scope.readOnlyComment ? angular.copy($scope.readOnlyComment) : {};
    }

    $scope.comment = initComment();
    if (_.isEmpty($scope.comment)) {
        $scope.setShowForm(true);
    }

    $scope.submitForm = function(type, comment, commentable) {
        var promise;
        if (type == 'save') {
            promise = CommentService.save(comment, commentable).then(function() {
                $scope.comment = initComment();
            });
        } else if (type == 'update') {
            promise = CommentService.update(comment, commentable);
        }
        promise.then(function() {
            $scope.setShowForm(false);
        });
    };
    $scope.cancel = function() {
        $scope.setShowForm(false);
        $scope.comment = initComment();
    };
    $scope['delete'] = function(comment, commentable) {
        CommentService.delete(comment, commentable);
    };
    $scope.deletable = function() {
        return Session.poOrSm() || Session.user.id == $scope.comment.poster.id;
    };
    $scope.readOnly = function() {
        return Session.user.id != $scope.comment.poster.id;
    };
}]);
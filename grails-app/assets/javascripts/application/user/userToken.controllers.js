/*
 * Copyright (c) 2017 Kagilum SAS.
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
controllers.controller('UserTokenCtrl', ['$scope', 'UserTokenService', 'Session', function($scope, UserTokenService, Session) {
    // Functions
    $scope.resetUserTokenForm = function() {
        $scope.editableUserToken = {};
    };
    $scope.save = function($event) {
        if($event){
            $event.preventDefault();
        }
        UserTokenService.save($scope.editableUserToken, Session.user)
            .then(function() {
                $scope.resetUserTokenForm();
                $scope.formHolder.profileForm['userToken.name'].$setPristine();
                $scope.formHolder.profileForm['userToken.name'].$setUntouched();
                $scope.notifySuccess('todo.is.ui.userToken.saved');
            });
    };
    /*$scope.update = function(userToken, user) {
        if (!$scope.formHolder.userTokenForm.$invalid && $scope.formHolder.userTokenForm.$dirty) {
            UserTokenService.update(userToken, user)
                .then(function() {
                    $scope.resetAcceptanceTestForm();
                    $scope.notifySuccess('todo.is.ui.userToken.updated');
                });
        }
    };*/
    $scope['delete'] = function(userToken) {
        UserTokenService.delete(userToken, Session.user)
            .then(function() {
                $scope.notifySuccess('todo.is.ui.deleted');
            });
    };
    // Init
    $scope.editableUserToken = {};
    $scope.user = Session.user;
}]);

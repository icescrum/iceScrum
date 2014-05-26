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

var controllers = angular.module('controllers', []);

controllers.controller('appCtrl', ['$scope', '$modal', 'Session', function ($scope, $modal, Session) {
    $scope.currentUser = Session.user;
    $scope.roles = Session.roles;
    $scope.changeRole = function(newRole) {
        Session.changeRole(newRole);
    };
    $scope.showAbout = function () {
        $modal.open({
            templateUrl: 'scrumOS/about',
            controller:function ($scope, $modalInstance) {
                $scope.tabsType = 'pills';
                $scope.ok = function () {
                    $modalInstance.close();
                };
                $scope.cancel = function () {
                    $modalInstance.dismiss('cancel');
                };
            }
        });
    };
    $scope.showAuthModal = function () {
        $modal.open({
            templateUrl: 'login/auth',
            controller:'loginCtrl',
            size:'sm'
        });
    };
}]).controller('loginCtrl',['$scope', '$rootScope','$modalInstance' , 'AUTH_EVENTS', 'AuthService', function ($scope, $rootScope, $modalInstance, AUTH_EVENTS, AuthService) {
    $scope.credentials = {
        j_username: '',
        j_password: ''
    };
    $scope.cancel = function() {
        $modalInstance.dismiss('cancel');
    };
    $scope.login = function (credentials) {
        AuthService.login(credentials).then(function () {
            $modalInstance.close();
            $rootScope.$broadcast(AUTH_EVENTS.loginSuccess);
        }, function () {
            $rootScope.$broadcast(AUTH_EVENTS.loginFailed);
        });
    };
}]);

controllers.controller('sandboxCtrl', ['$scope', '$location', '$state', 'stories', function ($scope, $location, $state, stories) {
    $scope.stories = stories;
    $scope.predicate = 'suggestedDate';
    $scope.go = function(url){
        $location.path(url);
    };
}]);

controllers.controller('actorsCtrl', ['$scope', '$location', 'actors', function ($scope, $location, actors) {
    $scope.actors = actors;
    $scope.go = function(url){
        $location.path(url);
    };
}]);

controllers.controller('featuresCtrl', ['$scope', '$location', 'features', function ($scope, $location, features) {
    $scope.features = features;
    $scope.go = function(url){
        $location.path(url);
    };
}]);
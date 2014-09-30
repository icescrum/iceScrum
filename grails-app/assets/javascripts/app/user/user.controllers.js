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
controllers.controller('userCtrl', ['$scope', 'UserService', 'User', '$modalInstance', function ($scope, UserService, User, $modalInstance) {
    $scope.update = function(user) {
        UserService.update(user).then(function() {
            $modalInstance.close();
        });
    };
    $scope.refreshAvatar = function(user){
        var url;
        var avatar = user.avatar;
        var avatarImg = angular.element('#user-avatar').find('img');
        if (avatar == 'gravatar'){
            url = user.email ? "https://secure.gravatar.com/avatar/" + $.md5(user.email) : null;
        } else if (avatar == 'custom') {
            avatarImg.triggerHandler('click');
            url = null;
        } else {
            url = avatar;
        }
        avatarImg.attr('src', url);
    };
    $scope.setTabSelected = function(tab) {
        $scope.tabSelected = {};
        $scope.tabSelected[tab] = true;
    };

    // Init
    $scope.currentUser = {};
    $scope.formHolder = {};
    $scope.tabSelected = { 'general': true };
    UserService.getCurrent().then(function(data) {
        $scope.currentUser = angular.copy(new User(data.user));
    });
}]);
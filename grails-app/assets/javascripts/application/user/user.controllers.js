/*
 * Copyright (c) 2015 Kagilum SAS.
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
controllers.controller('userCtrl', ['$scope', '$timeout', 'UserService', 'User', 'Session', function($scope, $timeout, UserService, User, Session) {
    // Functions
    $scope.update = function(user) {
        var newEmailsSettings = _.mapValues($scope.emailsSettings, function(emailsSetting) {
            return _.keys(_.pickBy(emailsSetting, _.id));
        });
        user.preferences.emailsSettings = newEmailsSettings;
        var languageChanged = Session.user.preferences.language != user.preferences.language;
        UserService.update(user).then(function(updatedUser) {
            if ($scope.$close) {
                $scope.$close(); // Close auth modal if present
            }
            if (languageChanged) {
                $scope.notifySuccess('todo.is.ui.profile.updated.refreshing');
                $timeout(function() {
                    document.location.reload(true);
                }, 2000);
            } else {
                $scope.notifySuccess('todo.is.ui.profile.updated');
            }
            angular.extend(Session.user, updatedUser);
            Session.user.preferences.emailsSettings = newEmailsSettings; // Need manual setting because it is not returned by the JSON marshaller for performance and security reasons
        });
    };
    $scope.refreshAvatar = function(user) {
        var url;
        var avatar = user.avatar;
        var avatarImg = angular.element('#user-avatar').find('img');
        if (avatar == 'gravatar') {
            url = user.email ? "https://secure.gravatar.com/avatar/" + $.md5(user.email) : null;
        } else if (avatar == 'custom') {
            avatarImg.triggerHandler('click');
            url = null;
        } else {
            url = avatar;
        }
        avatarImg.attr('src', url);
    };
    // Init
    $scope.formHolder = {};
    $scope.editableUser = angular.copy(Session.user);
    $scope.emailsSettings = _.transform(['autoFollow', 'onStory', 'onUrgentTask'], function(emailsSettings, settingName) {
        var projectKeys = $scope.editableUser.preferences.emailsSettings[settingName];
        emailsSettings[settingName] = _.zipObject(projectKeys, _.map(projectKeys, _.constant(true)));
    }, {});
    $scope.languages = {};
    $scope.languageKeys = [];
    Session.getLanguages().then(function(languages) {
        $scope.languages = languages;
        $scope.languageKeys = _.keys(languages);
    });
}]);

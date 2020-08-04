/*
 * Copyright (c) 2020 Kagilum SAS.
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
controllers.controller('devopsCtrl', ['$scope', 'AppService', function($scope, AppService) {
    // Functions
    $scope.isEnabledApp = function(appDefinition) {
        return AppService.isEnabledApp(appDefinition, $scope.project);
    };
    $scope.selectDevopsActivity = function(activityCode) {
        $scope.devopsActivity = $scope.devopsActivities[activityCode];
        var i18nBase = 'is.ui.devops.' + activityCode;
        $scope.devopsActivity.name = $scope.message(i18nBase);
        $scope.devopsActivity.description = $scope.message(i18nBase + '.description');
        $scope.devopsActivity.code = activityCode;
    };
    $scope.hasActiveApps = function(activityCode) {
        return _.find($scope.devopsActivities, function(devopsActivity) {
            return devopsActivity.code === activityCode && _.find(devopsActivity.apps, $scope.isEnabledApp);
        });
    };
    // Init
    $scope.project = $scope.getProjectFromState();
    $scope.devopsActivities = {
        plan: {
            code: 'plan',
            appIds: ['roadmap', 'forecast', 'featuremap']
        },
        code: {
            code: 'code',
            appIds: ['git', 'gitlab', 'github', 'vsts-scm', 'svn']
        },
        build: {
            code: 'build',
            appIds: ['travis', 'jenkins', 'vsts-ci']
        },
        test: {
            code: 'test',
            appIds: ['travis', 'jenkins', 'vsts-ci']
        },
        deploy: {
            code: 'deploy',
            appIds: ['travis', 'jenkins', 'vsts-ci']
        },
        monitor: {
            code: 'monitor',
            appIds: []
        },
        inspect: {
            code: 'inspect',
            appIds: ['upvote', 'bugzilla', 'mantis', 'jira', 'trac', 'redmine', 'vsts']
        },
        collaborate: {
            code: 'collaborate',
            appIds: ['msTeams', 'drawIO', 'zoom', 'jitsi', 'iobeya', 'jamboard', 'discord', 'slack', 'mattermost', 'mural']
        }
    };
    AppService.getAppDefinitions().then(function(appDefinitions) {
        $scope.appDefinitions = appDefinitions;
        _.each($scope.devopsActivities, function(devopsActivity) {
            devopsActivity.apps = _.map(devopsActivity.appIds, function(appId) {
                return _.find($scope.appDefinitions, {id: appId});
            });
        });
    });
    $scope.selectDevopsActivity('collaborate');
}]);
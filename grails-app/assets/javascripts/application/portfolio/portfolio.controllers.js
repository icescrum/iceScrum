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

controllers.controller('abstractPortfolioCtrl', ['$scope', function($scope) {
    $scope.preparePortfolio = function(portfolio) {
        var p = angular.copy(portfolio);
        var mapId = function(members) {
            return _.map(members, function(member) {
                return member.id ? {id: member.id} : {};
            });
        };
        p.stakeHolders = mapId(portfolio.stakeHolders);
        var invited = function(members) {
            return _.filter(members, function(member) {
                return !member.id
            });
        };
        p.invitedStakeHolders = invited(portfolio.stakeHolders);
        return p;
    };
    // Init
}]);

controllers.controller('newPortfolioCtrl', ['$scope', '$rootScope', '$controller', '$uibModal', 'Session', 'WizardHandler', 'Portfolio', 'Project', 'PortfolioService', function($scope, $rootScope, $controller, $uibModal, Session, WizardHandler, Portfolio, Project, PortfolioService) {
    $controller('abstractPortfolioCtrl', {$scope: $scope});
    $scope.checkPortfolioPropertyUrl = '/portfolio/available';
    // Functions
    $scope.enableVisibilityChange = function() {
        return isSettings.portfolioPrivateEnabled || Session.admin();
    };
    $scope.isCurrentStep = function(index, name) {
        return WizardHandler.wizard(name).currentStepNumber() === index;
    };
    $scope.createPortfolio = function(portfolio) {
        var p = $scope.preparePortfolio(portfolio);
        $scope.formHolder.creating = true;
        PortfolioService.save(p).then(function(portfolio) {
            $scope.openWorkspace(portfolio);
        }).catch(function() {
            $scope.formHolder.creating = false;
        });
    };
    $scope.nameChanged = function() {
        var fkeyModel = $scope.formHolder.portfolioForm.fkey;
        if (!fkeyModel.$touched) {
            $scope.portfolio.fkey = _.upperCase($scope.portfolio.name).replace(/\W+/g, "").substring(0, 10);
            fkeyModel.$setDirty(); // To trigger remote validation
        }
    };
    $scope.addNewProject = function() {
        $uibModal.open({
            keyboard: false,
            backdrop: 'static',
            templateUrl: $rootScope.serverUrl + "/project/add",
            size: 'lg',
            controller: 'newProjectCtrl',
            resolve: {
                manualSave: true,
                projectTemplate: function() {
                    var template = _.find($scope.portfolio.projects, function(project) { return project.id === undefined; });
                    if (template) {
                        return {
                            initialize: template.initialize,
                            startDate: template.startDate,
                            endDate: template.endDate,
                            firstSprint: template.firstSprint,
                            vision: template.vision, //good idea?
                            planningPokerGameType: template.planningPokerGameType,
                            preferences: template.preferences
                        }
                    } else {
                        return null;
                    }
                }
            }
        }).result.then(function(project) {
            project.class = "project";
            $scope.portfolio.projects[$scope.portfolio.projectsSize] = project;
            $scope.portfolio.projectsSize += 1;
        }, function() { });
    };
    // Init
    $scope.formHolder = {};
    $scope.portfolio = new Portfolio();
    angular.extend($scope.portfolio, {
        projects: {},
        projectsSize: 0,
        hidden: isSettings.portfolioPrivateDefault && isSettings.portfolioPrivateEnabled,
        stakeHolders: [Session.user, Session.user]
    });
}]);
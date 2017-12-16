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
}]);

controllers.controller('newPortfolioCtrl', ['$scope', '$rootScope', '$controller', '$uibModal', '$filter', 'Session', 'WizardHandler', 'Portfolio', 'Project', 'ProjectService', 'PortfolioService', 'UserService', function($scope, $rootScope, $controller, $uibModal, $filter, Session, WizardHandler, Portfolio, Project, ProjectService, PortfolioService, UserService) {
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
    $scope.searchProject = function(val) {
        return ProjectService.listByUserAndRole(Session.user.id, 'productOwner', {term: val, create: true, light: "startDate,preferences,team,productOwners"}).then(function(projects) {
            var projectsList = _.map($scope.portfolio.projects, function(project) { return project.name; });
            return _.filter(projects, function(project) {
                return !_.includes(projectsList, project.name);
            });
        })
    };
    $scope.selectProject = function(project, model, label) {
        if (project.portfolio) {
            return;
        }
        if (project.id) {
            $scope.portfolio.projects[$scope.portfolio.projectsSize] = angular.copy(project);
            $scope.portfolio.projectsSize += 1;
        } else {
            project.pkey = _.upperCase(project.name).replace(/\W+/g, "").substring(0, 10);
            addNewProject(project);
        }
        this.projectSelection = null;
    };
    var addNewProject = function(project) {
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
                        template = angular.copy(template);
                        var templatePreferences = angular.copy(template.preferences);
                        var restrictedTeamsNames = _.chain($scope.portfolio.projects).filter(function(project) {
                            return !angular.isDefined(project.team.id);
                        }).map(function(project) {
                            return project.team.name;
                        }).value();
                        return {
                            name: project ? project.name : '',
                            pkey: project ? project.pkey : '',
                            initialize: template.initialize ? template.initialize : '',
                            restrictedTeamsNames: restrictedTeamsNames,
                            startDate: template.startDate,
                            endDate: template.endDate,
                            firstSprint: template.firstSprint,
                            vision: template.vision, //good idea?
                            planningPokerGameType: template.planningPokerGameType,
                            preferences: templatePreferences
                        }
                    } else {
                        return {
                            name: project ? project.name : '',
                            pkey: project ? project.pkey : ''
                        };
                    }
                }
            }
        }).result.then(function(project) {
            if (project) {
                project.class = "project";
                $scope.portfolio.projects[$scope.portfolio.projectsSize] = project;
                $scope.portfolio.projectsSize += 1;
            }
        });
    };
    $scope.removeProject = function(projectToRemove) {
        var projects = {};
        var projectsSize = 0;
        _.filter($scope.portfolio.projects, function(project) {
            if (projectToRemove !== project) {
                projects[projectsSize] = project;
                projectsSize += 1;
            }
        });
        $scope.portfolio.projects = projects;
        $scope.portfolio.projectsSize = projectsSize;
    };
    $scope.searchUsers = function(val) {
        return UserService.search(val, true).then(function(users) {
            return _.chain(users)
                .filter(function(u) {
                    var found = _.find($scope.portfolio.businessOwners, {email: u.email});
                    if (!found) {
                        found = _.find($scope.portfolio.stakeHolders, {email: u.email});
                    }
                    return !found;
                })
                .map(function(member) {
                    member.name = $filter('userFullName')(member);
                    return member;
                })
                .value();
        });
    };
    $scope.addUser = function(user, role) {
        if (role == 'bo') {
            $scope.portfolio.businessOwners.push(user);
            $scope.po = {};
        } else if (role == 'sh') {
            $scope.portfolio.stakeHolders.push(user);
            $scope.sh = {};
        }
    };
    $scope.removeUser = function(user, role) {
        if (role == 'bo') {
            _.remove($scope.portfolio.businessOwners, {email: user.email});
        } else if (role == 'sh') {
            _.remove($scope.portfolio.stakeHolders, {email: user.email});
        }
    };
    // Init
    $scope.formHolder = {};
    $scope.portfolio = new Portfolio();
    angular.extend($scope.portfolio, {
        projects: {},
        projectsSize: 0,
        businessOwners: [Session.user],
        stakeHolders: [],
        hidden: isSettings.portfolioPrivateDefault && isSettings.portfolioPrivateEnabled
    });
}]);
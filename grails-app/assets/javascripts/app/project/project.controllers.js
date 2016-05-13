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
controllers.controller('projectCtrl', ["$scope", 'ProjectService', 'FormService', 'Session', '$uibModal', '$state', function($scope, ProjectService, FormService, Session, $uibModal, $state) {
    $scope.authorizedProject = function(action, project) {
        return ProjectService.authorizedProject(action, project);
    };
    $scope.showProjectEditModal = function(view) {
        var childScope = $scope.$new();
        if (view) {
            $scope.panel = {current: view};
        }
        $uibModal.open({
            keyboard: false,
            templateUrl: $scope.serverUrl + "/project/edit",
            size: 'lg',
            scope: childScope,
            controller: 'editProjectModalCtrl'
        });
    };
    $scope.showProjectListModal = function(type) {
        $uibModal.open({
            keyboard: false,
            templateUrl: $scope.serverUrl + "/project/listModal",
            size: 'lg',
            controller: ['$scope', '$controller', 'ProjectService', function($scope, $controller, ProjectService) {
                $controller('abstractProjectListCtrl', {$scope: $scope});
                // Functions
                $scope.searchProjects = function() {
                    var offset = $scope.projectsPerPage * ($scope.currentPage - 1);
                    var listFunction = type == 'public' ? ProjectService.listPublic : ProjectService.listByUser;
                    listFunction($scope.projectSearch, offset).then(function(projectsAndTotal) {
                        $scope.totalProjects = projectsAndTotal.total;
                        $scope.projects = projectsAndTotal.projects;
                        if (!_.isEmpty($scope.projects) && _.isEmpty($scope.project)) {
                            $scope.selectProject(_.head($scope.projects));
                        }
                    });
                };
                // Init
                $scope.totalProjects = 0;
                $scope.currentPage = 1;
                $scope.projectsPerPage = 9; // Constant
                $scope.projectSearch = '';
                $scope.projects = [];
                $scope.searchProjects();
            }]
        });
    };
    $scope['import'] = function(project) {
        var url = $scope.serverUrl + "/project/import";
        $uibModal.open({
            keyboard: false,
            templateUrl: url + "Dialog",
            controller: ['$scope', '$http', function($scope, $http) {
                $scope.flowConfig = {target: url, singleFile: true};
                $scope.changes = false;
                $scope._changes = {
                    showTeam: false,
                    showProject: false
                };
                $scope.progress = false;

                $scope.checkValidation = function($message) {
                    if ($message) {
                        $scope.progress = false;
                        $scope.changes = !angular.isObject($message) ? JSON.parse($message) : $message;
                        $scope._changes = angular.copy($scope.changes);
                        $scope._changes = angular.extend($scope._changes, {
                            showTeam: $scope.changes.team ? true : false,
                            showUsers: $scope.changes.users ? true : false,
                            showProjectName: $scope.changes.product ? ($scope.changes.product.name ? true : false) : false,
                            showProjectPkey: $scope.changes.product ? ($scope.changes.product.pkey ? true : false) : false
                        });
                    }
                };

                $scope.applyChanges = function() {
                    $http({
                        url: url,
                        method: 'POST',
                        headers: {'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'},
                        transformRequest: function(data) {
                            return FormService.formObjectData(data, 'changes.');
                        },
                        data: $scope.changes
                    }).then(function(response) {
                            var data = response.data;
                            if (data && data.class == 'Product') {
                                document.location = $scope.serverUrl + '/p/' + data.pkey + '/';
                            } else {
                                $scope.checkValidation(data);
                            }
                        }, function() {
                            $scope.progress = false;
                        }
                    );
                    $scope.progress = true;
                };
            }]
        });
    };
    $scope['export'] = function(project) {
        var modal = $uibModal.open({
            keyboard: false,
            templateUrl: "project/exportDialog",
            controller: ['$scope', function($scope) {
                $scope.zip = true;
                $scope.progress = false;
                $scope.start = function() {
                    $scope.downloadFile("project/export" + ($scope.zip ? "?zip=true" : ""));
                    $scope.progress = true;
                }
            }]
        });
        modal.result.then(
            function() {
                $scope.downloadFile("");
            },
            function() {
                $scope.downloadFile("");
            }
        );
    };
    $scope.goToHome = function() {
        window.location.href = $scope.serverUrl;
    };
    $scope.goToNewProject = function() {
        $state.go('newProject');
    };
    // Init
    $scope.sortableId = 'menu';
    $scope.currentProject = Session.getProject();
}]);

controllers.controller('dashboardCtrl', ['$scope', 'ProjectService', 'ReleaseService', 'SprintService', 'PushService', 'TeamService', function($scope, ProjectService, ReleaseService, SprintService, PushService, TeamService) {
    $scope.authorizedRelease = function(action, release) {
        return ReleaseService.authorizedRelease(action, release);
    };
    $scope.authorizedSprint = function(action, sprint) {
        return SprintService.authorizedSprint(action, sprint);
    };
    // Init
    $scope.activities = [];
    $scope.release = {};
    $scope.currentOrLastSprint = {};
    $scope.listeners = [];
    $scope.projectMembersCount = 0;
    $scope.project = $scope.currentProject;
    ProjectService.getActivities($scope.currentProject).then(function(activities) {
        $scope.activities = activities;
    });
    ReleaseService.getCurrentOrNextRelease($scope.currentProject).then(function(release) {
        $scope.release = release;
        if (release && release.id) {
            SprintService.list(release); // TODO push on sprints
        }
        $scope.listeners.push(PushService.synchronizeItem('release', $scope.release));
    });
    TeamService.get($scope.currentProject).then(function(team) {
        // That's ugly and repeated in TeamController...
        team.members = _.map(team.members, function(member) {
            member.scrumMaster = _.find(team.scrumMasters, {id: member.id}) ? true : false;
            return member;
        });
    });
    // Needs a separate call because it may not be in the currentOrNextRelease
    SprintService.getCurrentOrLastSprint($scope.currentProject).then(function(sprint) {
        $scope.currentOrLastSprint = sprint;
        $scope.listeners.push(PushService.synchronizeItem('sprint', $scope.currentOrLastSprint));
    });
    $scope.$on('$destroy', function() {
        _.each($scope.listeners, function(listener) {
            listener.unregister();
        });
    })
}]);

controllers.controller('abstractProjectListCtrl', ['$scope', 'ProjectService', 'ReleaseService', 'SprintService', 'TeamService', function($scope, ProjectService, ReleaseService, SprintService, TeamService) {
    $scope.selectProject = function(project) {
        $scope.project = project;
        TeamService.get(project).then(function() {
            $scope.projectMembersCount = ProjectService.countMembers(project);
        });
        ReleaseService.getCurrentOrNextRelease(project).then(function(release) {
            if (release.id != undefined) {
                SprintService.list(release);
            }
            $scope.release = release;
        });
    };
    // Init
    $scope.release = {};
    $scope.project = {};
    $scope.projectMembersCount = 0;
}]);

controllers.controller('publicProjectListCtrl', ['$scope', '$controller', 'ProjectService', function($scope, $controller, ProjectService) {
    $controller('abstractProjectListCtrl', {$scope: $scope});
    // Init
    $scope.projects = [];
    $scope.openedProjects = {};
    $scope.$watch('openedProjects', function(newVal) { // Really ugly hack, only way to watch which accordion group is opened...
        var selectedProjectId = _.invert(newVal)[true];
        if (selectedProjectId != undefined) {
            var selectedProject = _.find($scope.projects, {id: parseInt(selectedProjectId)});
            $scope.selectProject(selectedProject);
        }
    }, true);
    ProjectService.listPublic().then(function(projectsAndTotal) {
        $scope.projects = projectsAndTotal.projects;
    });
}]);

controllers.controller('quickProjectsListCtrl', ['$scope', 'ProjectService', function($scope, ProjectService) {
    $scope.getProjectUrl = function(project, viewName) {
        return $scope.serverUrl + '/p/' + project.pkey + '/' + (viewName ? "#/" + viewName : '');
    };
    // Init
    $scope.projects = [];
    ProjectService.listByUser().then(function(projectsAndTotal) {
        $scope.projects = projectsAndTotal.projects;
    });
}]);

controllers.controller('abstractProjectCtrl', ['$scope', '$filter', 'Session', 'UserService', function($scope, $filter, Session, UserService) {
    $scope.searchUsers = function(val, isPo) {
        return UserService.search(val).then(function(users) {
            return _.chain(users)
                .filter(function(u) {
                    var found = _.find($scope.project.productOwners, {email: u.email});
                    if (!found) {
                        found = _.find($scope.project.stakeHolders, {email: u.email});
                    }
                    if (!found && $scope.project.team) {
                        found = _.find($scope.project.team.members, {email: u.email});
                        if (isPo && found && found.scrumMaster) {
                            found = false;
                        }
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
        if (role == 'po') {
            $scope.project.productOwners.push(user);
            if ($scope.project.team) {
                var member = _.find($scope.project.team.members, {email: user.email});
                if (member) {
                    member.productOwner = true;
                }
            }
            $scope.po = {};
        } else if (role == 'sh') {
            $scope.project.stakeHolders.push(user);
            $scope.sh = {};
        }
    };
    $scope.removeUser = function(user, role) {
        if (role == 'po') {
            _.remove($scope.project.productOwners, {email: user.email});
            if ($scope.project.team) {
                var member = _.find($scope.project.team.members, {email: user.email});
                if (member) {
                    member.productOwner = false;
                }
            }
        } else if (role == 'sh') {
            _.remove($scope.project.stakeHolders, {email: user.email});
        }
    };
    $scope.prepareProject = function(project) {
        var p = angular.copy(project);
        var mapId = function(members) {
            return _.map(members, function(member) {
                return {id: member.id};
            });
        };
        p.team.scrumMasters = mapId(project.team.scrumMasters);
        p.team.members = _.filter(mapId(project.team.members), function(member) {
            return !_.some(p.team.scrumMasters, {id: member.id});
        });
        p.stakeHolders = mapId(project.stakeHolders);
        p.productOwners = mapId(project.productOwners);
        var invited = function(members) {
            return _.chain(members).filter({id: null}).map(function(member) { return {email: member.email}; }).value();
        };
        p.team.invitedScrumMasters = invited(project.team.scrumMasters);
        p.team.invitedMembers = _.filter(invited(project.team.members), function(member) {
            return !_.some(p.team.invitedScrumMasters, {email: member.email});
        });
        p.invitedStakeHolders = invited(project.stakeHolders);
        p.invitedProductOwners = invited(project.productOwners);
        return p;
    };
    // Init
    $scope.po = {};
    $scope.sh = {};
    $scope.timezones = {};
    $scope.timezoneKeys = [];
    Session.getTimezones().then(function(timezones) {
        $scope.timezones = timezones;
        $scope.timezoneKeys = _.keys(timezones);
    });
}]);

controllers.controller('newProjectCtrl', ["$scope", '$filter', '$controller', 'DateService', 'UserTimeZone', 'WizardHandler', 'Project', 'ProjectService', 'Session', function($scope, $filter, $controller, DateService, UserTimeZone, WizardHandler, Project, ProjectService, Session) {

    $controller('abstractProjectCtrl', {$scope: $scope});
    $scope.type = 'newProject';
    $scope.checkProjectPropertyUrl = '/project/available';
    $scope.isCurrentStep = function(index) {
        return WizardHandler.wizard().currentStepNumber() == index;
    };
    $scope.createProject = function(project) {
        var p = $scope.prepareProject(project);
        ProjectService.save(p).then(function(project) {
            $scope.openProject(project);
        });
    };
    $scope.teamMembersEditable = function(team) {
        return team.id == null;
    };
    $scope.teamCreatable = function() {
        return true;
    };
    $scope.teamRemovable = function() {
        return true;
    };
    $scope.projectMembersEditable = function() {
        return true;
    };
    $scope.computePlanning = function() {
        $scope.totalDuration = DateService.daysBetweenDays($scope.project.firstSprint, $scope.project.endDate);
        if ($scope.project.preferences.estimatedSprintsDuration > $scope.totalDuration) {
            $scope.project.preferences.estimatedSprintsDuration = $scope.totalDuration;
        }
        var sprintDuration = $scope.project.preferences.estimatedSprintsDuration;
        var nbSprints = Math.floor($scope.totalDuration / sprintDuration);
        $scope.sprints = [];
        for (var i = 1; i <= nbSprints; i++) {
            var startDate = DateService.immutableAddDaysToDate($scope.project.firstSprint, (i - 1) * sprintDuration);
            var endDate = DateService.immutableAddDaysToDate(startDate, sprintDuration);
            $scope.sprints.push({orderNumber: i, startDate: startDate, endDate: endDate});
        }
    };
    $scope.initPkey = function() {
        if ($scope.project.name && !$scope.project.pkey) {
            $scope.project.pkey = $filter('uppercase')($scope.project.name.replace(/\W+/g, ""));
        }
    };
    // Init
    $scope.project = new Project();
    var today = DateService.getMidnightTodayUTC();
    var endDate = DateService.immutableAddMonthsToDate(today, 3);
    angular.extend($scope.project, {
        startDate: today,
        firstSprint: today,
        endDate: endDate,
        planningPokerGameType: 1,
        preferences: {
            timezone: UserTimeZone.name(),
            noEstimation: false,
            estimatedSprintsDuration: 14,
            displayRecurrentTasks: true,
            displayUrgentTasks: true,
            hidden: true
        },
        productOwners: [Session.user],
        stakeHolders: []
    });
    $scope.startDateOptions = {
        opened: false
    };
    $scope.firstSprintOptions = angular.copy($scope.startDateOptions);
    $scope.endDateOptions = angular.copy($scope.startDateOptions);
    $scope.$watchCollection('[project.startDate, project.endDate, project.firstSprint]', function(newValues) {
        var startDate = newValues[0];
        var endDate = newValues[1];
        var firstSprint = newValues[2];
        $scope.endDateOptions.minDate = DateService.immutableAddDaysToDate(firstSprint, 1);
        $scope.startDateOptions.maxDate = DateService.immutableAddDaysToDate(endDate, -1);
        $scope.firstSprintOptions.maxDate = $scope.startDateOptions.maxDate;
        $scope.firstSprintOptions.minDate = startDate;
    });
    $scope.totalDuration = 0;
    $scope.sprints = [];
    $scope.computePlanning();
}]);

controllers.controller('editProjectModalCtrl', ['$scope', 'Session', 'ProjectService', 'ReleaseService', function($scope, Session, ProjectService, ReleaseService) {
    $scope.type = 'editProject';
    $scope.authorizedProject = function(action, project) {
        return ProjectService.authorizedProject(action, project);
    };
    $scope.setCurrentPanel = function(panel) {
        $scope.panel.current = panel;
    };
    $scope.getCurrentPanel = function() {
        return $scope.panel.current;
    };
    $scope.isCurrentPanel = function(panel) {
        return $scope.panel.current == panel;
    };
    // Mock steps of wizard
    $scope.isCurrentStep = function() {
        return true;
    };
    // Init
    $scope.currentProject = Session.getProject();
    $scope.checkProjectPropertyUrl = '/project/' + $scope.currentProject.id + '/available';
    ReleaseService.list($scope.currentProject).then(function(releases) {
        if (releases.length > 0) {
            $scope.startDateOptions.maxDate = new Date(releases[0].startDate);
        }
    });
    $scope.startDateOptions = {
        opened: false
    };
    if (!$scope.panel) {
        var defaultView = $scope.authorizedProject('update', $scope.currentProject) ? 'general' : 'team';
        $scope.panel = {current: defaultView};
    }
}]);

controllers.controller('editProjectMembersCtrl', ['$scope', '$controller', 'Session', 'ProjectService', 'TeamService', function($scope, $controller, Session, ProjectService, TeamService) {
    $controller('abstractProjectCtrl', {$scope: $scope});
    $scope.teamMembersEditable = function() {
        return false;
    };
    $scope.teamCreatable = function() {
        return false;
    };
    $scope.teamRemovable = function() {
        return ProjectService.authorizedProject('updateTeamMembers', $scope.project);
    };
    $scope.projectMembersEditable = function(project) {
        return ProjectService.authorizedProject('updateProjectMembers', project);
    };
    $scope.resetTeamForm = function() {
        $scope.resetFormValidation($scope.formHolder.editMembersForm);
        $scope.project = angular.copy($scope.currentProject);
        $scope.project.stakeHolders = $scope.project.stakeHolders.concat($scope.project.invitedStakeHolders);
        $scope.project.productOwners = $scope.project.productOwners.concat($scope.project.invitedProductOwners);
        $scope.teamPromise = TeamService.get($scope.project);
    };
    $scope.updateProjectTeam = function(project) {
        var p = $scope.prepareProject(project);
        ProjectService.updateTeam(p)
            .then(function(updatedProject) {
                Session.updateProject(updatedProject);
                $scope.resetTeamForm();
                $scope.notifySuccess('todo.is.ui.project.members.updated');
            });
    };
    $scope.leaveTeam = function(project) {
        ProjectService.leaveTeam(project).then(function() {
            document.location.reload(true);
        });
    };
    // Init
    $scope.formHolder = {};
    $scope.resetTeamForm();
}]);

controllers.controller('editProjectCtrl', ['$scope', 'Session', 'ProjectService', function($scope, Session, ProjectService) {
    $scope.views = [];
    $scope.update = function(project) {
        $scope.project.preferences.stakeHolderRestrictedViews = _.chain($scope.views).filter({hidden: true}).map('id').value().join(',');
        ProjectService.update(project)
            .then(function(updatedProject) {
                Session.updateProject(updatedProject);
                $scope.notifySuccess('todo.is.ui.project.general.updated');
                $scope.resetProjectForm();
            });
    };
    $scope.resetProjectForm = function() {
        $scope.resetFormValidation($scope.formHolder.editProjectForm);
        $scope.project = angular.copy($scope.currentProject);
        var restrictedViews = $scope.project.preferences.stakeHolderRestrictedViews ? $scope.project.preferences.stakeHolderRestrictedViews.split(',') : [];
        $scope.views = _.chain($scope.applicationMenus).map(function(menu) {
            return {title: menu.title, id: menu.id, hidden: _.includes(restrictedViews, menu.id)};
        }).sortBy('title').value();
    };
    $scope['delete'] = function(project) {
        $scope.confirm({
            message: $scope.message('todo.is.ui.projectmenu.submenu.project.delete.confirm'),
            callback: function() {
                ProjectService.delete(project).then(function() {
                    document.location = $scope.serverUrl;
                });
            }
        })
    };
    $scope.archive = function(project) {
        $scope.confirm({
            message: $scope.message('is.dialog.project.archive.confirm'),
            callback: function() {
                ProjectService.archive(project).then(function() {
                    document.location = $scope.serverUrl;
                });
            }
        })
    };
    // Init
    $scope.formHolder = {};
    $scope.resetProjectForm();
    $scope.timezones = {};
    $scope.timezoneKeys = [];
    Session.getTimezones().then(function(timezones) {
        $scope.timezones = timezones;
        $scope.timezoneKeys = _.keys(timezones);
    });
}]);
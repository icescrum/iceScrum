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
 *
 */
controllers.controller('projectCtrl', ["$scope", 'ProjectService', 'Session', '$modal', function($scope, ProjectService, Session, $modal) {
    $scope.showProjectEditModal = function(view) {
        var childScope = $scope.$new();
        if (view) {
            $scope.panel = { current: view };
        }
        $modal.open({
            keyboard: false,
            templateUrl: $scope.serverUrl + "/project/edit",
            size: 'lg',
            scope: childScope,
            controller: 'editProjectModalCtrl'
        });
    };
    $scope.showProjectListModal = function(type) {
        $modal.open({
            keyboard: false,
            templateUrl: $scope.serverUrl + "/project/listModal",
            size: 'lg',
            controller: ['$scope', '$controller', 'ProjectService', function($scope, $controller, ProjectService) {
                $controller('abstractProjectListCtrl', { $scope: $scope });
                // Functions
                $scope.searchProjects = function() {
                    var offset = $scope.projectsPerPage * ($scope.currentPage - 1);
                    var listFunction = type == 'public' ? ProjectService.listPublic : ProjectService.listByUser;
                    listFunction($scope.projectSearch, offset).then(function(projectsAndTotal) {
                        $scope.totalProjects = projectsAndTotal.total;
                        $scope.projects = projectsAndTotal.projects;
                        if (!_.isEmpty($scope.projects) && _.isEmpty($scope.project)) {
                            $scope.selectProject(_.first($scope.projects));
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
        $modal.open({
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
                            return formObjectData(data, 'changes.');
                        },
                        data: $scope.changes
                    })
                    .then(function(response) {
                            if (response.data && response.data.class == 'Product') {
                                document.location = $scope.serverUrl + '/p/' + response.data.pkey + '/';
                            } else {
                                $scope.checkValidation(response.data);
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
        var modal = $modal.open({
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

    $scope.goToHome = function(){
        $scope.$state.go('root');
    };

    // Init
    $scope.currentProject = Session.getProject();
}]);

controllers.controller('dashboardCtrl', ['$scope', 'ProjectService', 'ReleaseService', 'SprintService', 'PushService', function($scope, ProjectService, ReleaseService, SprintService, PushService) {
    $scope.authorizedRelease = function(action, release) {
        return ReleaseService.authorizedRelease(action, release);
    };
    $scope.authorizedSprint = function(action, sprint) {
        return SprintService.authorizedSprint(action, sprint);
    };
    $scope.updateRelease = function(release) {
        if (!_.isEqual($scope.editableReleaseReference, $scope.editableRelease)) {
            ReleaseService.update(release)
                .then(function(updatedRelease) {
                    angular.extend($scope.release, updatedRelease);
                    $scope.editableRelease = $scope.release;
                    $scope.editableReleaseReference = $scope.release;
                    $scope.notifySuccess('todo.is.ui.release.updated');
                });
        }
    };
    $scope.updateSprint = function(sprint) {
        if (!_.isEqual($scope.editableCurrentOrLastSprintReference, $scope.editableCurrentOrLastSprint)) {
            SprintService.update(sprint, $scope.currentProject.id)
                .then(function(updatedSprint) {
                    angular.extend($scope.currentOrLastSprint, updatedSprint);
                    $scope.editableCurrentOrLastSprint = $scope.currentOrLastSprint;
                    $scope.editableCurrentOrLastSprintReference = $scope.currentOrLastSprint;
                    $scope.notifySuccess('todo.is.ui.sprint.updated');
                });
        }
    };
    $scope.editRelease = function(isEditable) {
        if (isEditable) {
            $scope.editableRelease = angular.copy($scope.release);
            $scope.editableReleaseReference = angular.copy($scope.release);
        }
    };
    $scope.editSprint = function(isEditable) {
        if (isEditable) {
            $scope.editableCurrentOrLastSprint = angular.copy($scope.currentOrLastSprint);
            $scope.editableCurrentOrLastSprintReference = angular.copy($scope.currentOrLastSprint);
        }
    };
    // Init
    $scope.activities = [];
    $scope.release = {};
    $scope.editableRelease = {};
    $scope.editableReleaseReference = {};
    $scope.currentOrLastSprint = {};
    $scope.editableCurrentOrLastSprint = {};
    $scope.editableCurrentOrLastSprintReference = {};
    $scope.listeners = [];
    $scope.projectMembersCount = 0;
    $scope.project = $scope.currentProject;
    ProjectService.getActivities($scope.currentProject).then(function(activities) {
        $scope.activities = activities;
    });
    ReleaseService.getCurrentOrNextRelease($scope.currentProject).then(function(release) {
        $scope.release = release;
        $scope.editableRelease = release;
        if (release) {
            SprintService.list(release); // TODO push on sprints
        }
        $scope.listeners.push(PushService.synchronizeItem('release', $scope.release));
    });
    ProjectService.countMembers($scope.currentProject).then(function(count) {
        $scope.projectMembersCount = count;
    });
    // Needs a separate call because it may not be in the currentOrNextRelease
    SprintService.getCurrentOrLastSprint($scope.currentProject).then(function(sprint) {
        $scope.currentOrLastSprint = sprint;
        $scope.editableCurrentOrLastSprint = sprint;
        $scope.listeners.push(PushService.synchronizeItem('sprint', $scope.currentOrLastSprint));
    });
    $scope.$on('$destroy', function() {
        _.each($scope.listeners, function(listener) {
            listener.unregister();
        });
    })
}]);

controllers.controller('abstractProjectListCtrl', ['$scope', 'ProjectService', 'ReleaseService', 'SprintService', function($scope, ProjectService, ReleaseService, SprintService) {
    $scope.selectProject = function(project) {
        $scope.project = project;
        ProjectService.countMembers(project).then(function(count) {
            $scope.projectMembersCount = count;
        });
        ReleaseService.getCurrentOrNextRelease(project).then(function(release) {
            if (release) {
                SprintService.list(release);
            }
            $scope.release = release;
        });
    };
    $scope.openProject = function (project) {
        document.location = $scope.serverUrl + '/p/' + project.pkey;
    };
    // Init
    $scope.release = {};
    $scope.project = {};
    $scope.projectMembersCount = 0;
}]);

controllers.controller('projectListCtrl', ['$scope', '$controller', 'ProjectService', function($scope, $controller, ProjectService) {
    $controller('abstractProjectListCtrl', { $scope: $scope });
    // Init
    $scope.projects = [];
    $scope.openedProjects = {};
    $scope.$watch('openedProjects', function(newVal) { // Really ugly hack, only way to watch which accordion group is opened...
        var selectedProjectId = _.invert(newVal)[true];
        if (selectedProjectId != undefined) {
            var selectedProject = _.find($scope.projects, { id: parseInt(selectedProjectId) });
            $scope.selectProject(selectedProject);
        }
    }, true);
    var listFunction = $scope.type == 'public' ? ProjectService.listPublic : ProjectService.listByUser;
    listFunction().then(function (projectsAndTotal) {
        $scope.projects = projectsAndTotal.projects;
    });
}]);

controllers.controller('abstractProjectCtrl', ['$scope', '$http', '$filter', function($scope, $http, $filter) {
    $scope.searchUsers = function(val, isPo) {
        return $http.get($scope.serverUrl + '/user/search', {
            params: {
                value: val,
                invit: true
            }
        }).then(function(response) {
            return _.chain(response.data)
                .filter(function(u) {
                    var found = _.find($scope.project.productOwners, { email: u.email });
                    if (!found) {
                        found = _.find($scope.project.stakeHolders, { email: u.email });
                    }
                    if (!found && $scope.project.team) {
                        found = _.find($scope.project.team.members, { email: u.email });
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
                var member = _.find($scope.project.team.members, { email: user.email });
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
            _.remove($scope.project.productOwners, { email: user.email});
            if ($scope.project.team) {
                var member = _.find($scope.project.team.members, { email: user.email });
                if (member) {
                    member.productOwner = false;
                }
            }
        } else if (role == 'sh') {
            _.remove($scope.project.stakeHolders, { email: user.email});
        }
    };
    $scope.prepareProject = function(project) {
        var p = angular.copy(project);
        var mapId = function(members) {
            return _.map(members, function(member) {
                return { id: member.id };
            });
        };
        p.team.scrumMasters = mapId(project.team.scrumMasters);
        p.team.members = _.filter(mapId(project.team.members), function(member) {
            return !_.any(p.team.scrumMasters, { id: member.id });
        });
        p.stakeHolders = mapId(project.stakeHolders);
        p.productOwners = mapId(project.productOwners);
        var invited = function(members) {
            return _.chain(members).where({id: null}).map(function(member) { return {email:member.email}; }).value();
        };
        p.team.invitedScrumMasters = invited(project.team.scrumMasters);
        p.team.invitedMembers = _.filter(invited(project.team.members), function(member) {
            return !_.any(p.team.invitedScrumMasters, { email: member.email });
        });
        p.invitedStakeHolders = invited(project.stakeHolders);
        p.invitedProductOwners = invited(project.productOwners);
        return p;
    };
    // Init
    $scope.po = {};
    $scope.sh = {};
}]);

controllers.controller('newProjectCtrl', ["$scope", '$filter', '$controller', 'WizardHandler', 'Project', 'ProjectService', 'Session', function($scope, $filter, $controller, WizardHandler, Project, ProjectService, Session) {

    $controller('abstractProjectCtrl', { $scope: $scope });
    $scope.type = 'newProject';
    $scope.openDatepicker = function($event, name) {
        $event.preventDefault();
        $event.stopPropagation();
        if ($scope[name]) {
            $scope[name].opened = true;
        }
    };
    $scope.isCurrentStep = function(index) {
        return WizardHandler.wizard().currentStepNumber() == index;
    };
    $scope.createProject = function(project) {
        var p = $scope.prepareProject(project);
        p.startDate = $filter('dateToIso')(project.startDate);
        p.endDate = $filter('dateToIso')(project.endDate);
        p.firstSprint = $filter('dateToIso')(project.firstSprint);
        ProjectService.save(p).then(function(project) {
            document.location = $scope.serverUrl + '/p/' + project.pkey + '/';
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
        $scope.totalDuration = $scope.durationBetweenDates($scope.project.firstSprint, $scope.project.endDate);
        if ($scope.project.preferences.estimatedSprintsDuration > $scope.totalDuration) {
            $scope.project.preferences.estimatedSprintsDuration = $scope.totalDuration;
        }
        var sprintDuration = $scope.project.preferences.estimatedSprintsDuration;
        var nbSprints = Math.floor($scope.totalDuration / sprintDuration);
        $scope.sprints = [];
        for (var i = 1; i <= nbSprints; i++) {
            var startDate = new Date($scope.project.firstSprint);
            startDate.setDate($scope.project.firstSprint.getDate() + (i - 1) * sprintDuration);
            var endDate = new Date(startDate);
            endDate.setDate(startDate.getDate() + sprintDuration);
            $scope.sprints.push({ orderNumber : i, startDate: startDate, endDate: endDate });
        }
    };
    $scope.initPkey = function() {
        if ($scope.project.name && !$scope.project.pkey) {
            $scope.project.pkey = $filter('uppercase')($scope.project.name.replace(/\W+/g, ""));
        }
    };
    // Init
    $scope.project = new Project();
    var today = new Date();
    today.setHours(0, 0, 0, 0);
    var endDate = new Date();
    endDate.setHours(0, 0, 0, 0);
    endDate.setMonth(today.getMonth() + 3);
    angular.extend($scope.project, {
        startDate: today,
        firstSprint: today,
        endDate: endDate,
        planningPokerGameType: 1,
        preferences: {
            noEstimation: false,
            estimatedSprintsDuration: 14,
            displayRecurrentTasks: true,
            displayUrgentTasks: true,
            hidden: true
        },
        productOwners: [Session.user],
        stakeHolders: []
    });
    $scope.startDate = {
        startingDay: 1,
        opened: false,
        format: 'dd/MM/yyyy',
        disabled: function(date, mode) {
            return ( mode === 'day' && ( date.getDay() === 0 || date.getDay() === 6 ) );
        }

    };
    $scope.endDate = angular.copy($scope.startDate);
    $scope.firstSprint = angular.copy($scope.startDate);
    $scope.$watchCollection('[project.startDate, project.endDate, project.firstSprint]', function(newValues) {
        var startDate = newValues[0];
        var endDate = newValues[1];
        var firstSprint = newValues[2];
        $scope.projectMinEndDate = new Date(startDate).setDate(firstSprint.getDate() + 1);
        $scope.projectMaxStartDate = new Date(endDate).setDate(endDate.getDate() - 1);
        $scope.sprintMaxStartDate = $scope.projectMaxStartDate;
        $scope.sprintMinStartDate = startDate;
    });
    $scope.totalDuration = 0;
    $scope.sprints = [];
    $scope.computePlanning();
}]);

controllers.controller('editProjectModalCtrl', ['$scope', 'Session', 'ProjectService', function($scope, Session, ProjectService) {
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
    if (!$scope.panel) {
        var defaultView = $scope.authorizedProject('update', $scope.currentProject) ? 'general' : 'team';
        $scope.panel = { current: defaultView };
    }
}]);

controllers.controller('editProjectMembersCtrl', ['$scope', '$controller', 'Session', 'ProjectService', 'TeamService', function($scope, $controller, Session, ProjectService, TeamService) {
    $controller('abstractProjectCtrl', { $scope: $scope });
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
                Session.setProject(updatedProject);
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
        $scope.project.preferences.stakeHolderRestrictedViews = _.chain($scope.views).where({hidden: true}).map('id').value().join(',');
        ProjectService.update(project)
            .then(function(updatedProject) {
                Session.setProject(updatedProject);
                $scope.notifySuccess('todo.is.ui.project.general.updated');
                $scope.resetProjectForm();
            });
    };
    $scope.resetProjectForm = function() {
        $scope.resetFormValidation($scope.formHolder.editProjectForm);
        $scope.project = angular.copy($scope.currentProject);
        var restrictedViews = $scope.project.preferences.stakeHolderRestrictedViews ? $scope.project.preferences.stakeHolderRestrictedViews.split(',') : [];
        $scope.views = _.chain($scope.applicationMenus).map(function(menu) {
            return { title: menu.title, id: menu.id, hidden: _.contains(restrictedViews, menu.id) };
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
}]);
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
    $scope.currentProject = Session.getProject();

    $scope.import = function(project) {
        var url = $scope.serverUrl + "/project/import";
        $modal.open({
            keyboard: false,
            templateUrl: url +"Dialog",
            controller: ['$scope', '$http',function($scope, $http){
                $scope.flowConfig = {target: url, singleFile:true};
                $scope.changes = false;
                $scope._changes = {
                    showTeam:false,
                    showProject:false
                };
                $scope.progress = false;

                $scope.checkValidation = function($message){
                    if ($message){
                        $scope.progress = false;
                        $scope.changes = !angular.isObject($message) ? JSON.parse($message) : $message;
                        $scope._changes = angular.copy($scope.changes);
                        $scope._changes = angular.extend($scope._changes, {
                            showTeam:$scope.changes.team?true:false,
                            showUsers:$scope.changes.users?true:false,
                            showProjectName:$scope.changes.product? ($scope.changes.product.name ?true:false) :false,
                            showProjectPkey:$scope.changes.product? ($scope.changes.product.pkey ?true:false) :false
                        });
                    }
                };

                $scope.applyChanges = function(){
                    $http({ url: url,
                            method: 'POST',
                            headers: {'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'},
                            transformRequest: function (data) {
                                return formObjectData(data, 'changes.');
                            },
                            data: $scope.changes })
                        .then(function(response){
                            if (response.data && response.data.class == 'Product'){
                                document.location = $scope.serverUrl + '/p/' + response.data.pkey + '/';
                            } else {
                                $scope.checkValidation(response.data);
                            }
                        }, function(){
                            $scope.progress = false;
                    });
                    $scope.progress = true;
                };
            }]
        });
    };

    $scope.export = function(project) {
        var modal = $modal.open({
            keyboard: false,
            templateUrl: "project/exportDialog",
            controller: ['$scope',function($scope){
                $scope.zip = true;
                $scope.progress = false;
                $scope.start = function(){
                    $scope.downloadFile("project/export" + ($scope.zip ? "?zip=true" : ""));
                    $scope.progress = true;
                }
            }]
        });
        modal.result.then(
            function() {
                $scope.downloadFile("");
            },
            function(){
                $scope.downloadFile("");
            }
        );
    };

    $scope['delete'] = function(project) {
        $scope.confirm({
            message:$scope.message('todo.is.ui.projectmenu.submenu.project.delete'),
            callback:function(){
                ProjectService.delete(project).then(function(){
                    document.location = $scope.serverUrl;
                });
            }
        })
    };

    $scope.authorizedProject = function(action, project) {
       return ProjectService.authorizedProject(action, project);
    };
}]);

controllers.controller('abstractProjectCtrl', ['$scope', '$http', '$filter', function($scope, $http, $filter) {
    $scope.searchUsers = function(val, isPo){
        return $http.get($scope.serverUrl+ '/user/search', {
            params: {
                value: val,
                invit:true
            }
        }).then(function(response){
            return _.chain(response.data)
                .filter(function(u){
                    var found = _.find($scope.project.productOwners, { email: u.email });
                    if (!found){
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
                .map(function(member){
                    member.name = $filter('userFullName')(member);
                    return member;
                })
                .value();
        });
    };
    $scope.po = {};
    $scope.sh = {};
    $scope.addUser = function(user, role){
        if(role == 'po'){
            $scope.project.productOwners.push(user);
            if ($scope.project.team) {
                var member = _.find($scope.project.team.members, { email: user.email });
                if (member) {
                    member.productOwner = true;
                }
            }
            $scope.po = {};
        } else if(role == 'sh'){
            $scope.project.stakeHolders.push(user);
            $scope.sh = {};
        }
    };
    $scope.removeUser = function(user, role){
        if(role == 'po'){
            _.remove($scope.project.productOwners, { email: user.email});
            if ($scope.project.team) {
                var member = _.find($scope.project.team.members, { email: user.email });
                if (member) {
                    member.productOwner = false;
                }
            }
        } else if(role == 'sh'){
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
    }
}]);

controllers.controller('newProjectCtrl', ["$scope", '$filter', '$controller', 'WizardHandler', 'Project', 'ProjectService', 'Session', function($scope, $filter, $controller, WizardHandler, Project, ProjectService, Session){
    $controller('abstractProjectCtrl', { $scope: $scope });

    $scope.project = new Project();

    angular.extend($scope.project, {
        startDate:new Date(),
        endDate:new Date(new Date().setMonth(new Date().getMonth()+3)),
        planningPokerGameType:1,
        preferences:{
            noEstimation:false,
            sprintDuration:14,
            displayRecurrentTasks:true,
            displayUrgentTasks:true,
            hidden:true
        },
        productOwners:[Session.user],
        stakeHolders:[]
    });

    $scope.$watchCollection('[project.startDate, project.endDate]', function(newValues){
        $scope.projectMinDate = new Date(newValues[0]).setDate(newValues[0].getDate()+1);
        $scope.projectMaxDate = new Date(newValues[1]).setDate(newValues[1].getDate()-1);
    });

    $scope.startDate = {
        startingDay: 1,
        opened:false,
        format:'dd/MM/yyyy',
        disabled:function(date, mode) {
            return ( mode === 'day' && ( date.getDay() === 0 || date.getDay() === 6 ) );
        }

    };
    $scope.endDate = angular.copy($scope.startDate);

    $scope.openDatepicker = function($event, openEndDate) {
        $event.preventDefault();
        $event.stopPropagation();
        if(openEndDate) {
            $scope.endDate.opened = true;
        } else {
            $scope.startDate.opened = true;
        }
    };

    $scope.isCurrentStep = function(index){
        return WizardHandler.wizard().currentStepNumber() == index
    };

    $scope.createProject = function(project){
        var p = $scope.prepareProject(project);
        p.startDate = $filter('date')(project.startDate, "dd-MM-yyyy");
        p.endDate = $filter('date')(project.endDate, "dd-MM-yyyy");
        ProjectService.save(p).then(function(project) {
            document.location = $scope.serverUrl + '/p/' + project.pkey + '/';
        });
    };

    $scope.teamEditable = function(team) {
        return team.id == null;
    };
}]);

controllers.controller('editProjectMembersCtrl', ['$scope', '$controller', 'ProjectService', 'Session', function($scope, $controller, ProjectService, Session) {
    $controller('abstractProjectCtrl', { $scope: $scope });
    $scope.teamEditable = function() {
        return true;
    };
    $scope.project = Session.getProject();
    $scope.project.stakeHolders = $scope.project.stakeHolders.concat($scope.project.invitedStakeHolders);
    $scope.project.productOwners = $scope.project.productOwners.concat($scope.project.invitedProductOwners);
    $scope.teamPromise = ProjectService.getTeam($scope.project);
    $scope.updateProjectTeam = function(project) {
        var p = $scope.prepareProject(project);
        ProjectService.updateTeam(p)
            .then(function() {
                $scope.$close();
                $scope.notifySuccess('todo.is.ui.project.members.updated');
            });
    };
    $scope.leaveTeam = function(project) {
        ProjectService.leaveTeam(project).then(function() {
            document.location.reload(true);
        });
    }
}]);
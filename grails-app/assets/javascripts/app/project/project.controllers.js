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
controllers.controller('projectCtrl', ["$scope", 'ProjectService', 'Session', '$modal', '$timeout', function($scope, ProjectService, Session, $modal, $timeout) {
    $scope.currentProject = Session.getProject();

    $scope['import'] = function(project) {
        var modal = $modal.open({
            templateUrl: icescrum.grailsServer + '/' + "project/importDialog",
            size: 'md',
            controller: function($scope){

            }
        });
        modal.result.then(
            function(result) {

            },
            function(){

            }
        );
    };

    $scope['export'] = function(project) {
        var status;
        var stopStatus = function() {
            if (angular.isDefined(status)) {
                $timeout.cancel(status);
                status = undefined;
            }
        };
        var modal = $modal.open({
            templateUrl: "project/exportDialog",
            size: 'sm',
            controller: ['$scope', '$timeout', '$http',function($scope, $timeout, $http){
                $scope.progress = {
                    value:0,
                    label:""
                };
                $scope.zip = true;
                $scope.type = 'primary';
                $scope.started = false;

                $scope.start = function(){
                    $scope.started = true;
                    var progress = function() {
                        $http({
                            method: "get",
                            url: "project/exportStatus"
                        }).then(function (response) {
                            if (!response.data.error && !response.data.complete) {
                                status = $timeout(progress, 500);
                            } else if (response.data.error){
                                $scope.type = 'danger';
                            } else if (response.data.complete){
                                $scope.type = 'success';
                            }
                            $scope.progress = response.data;
                        }, function(){
                            $scope.type = 'danger';
                            $scope.progress.label = $scope.message("Error during export");
                            $scope.progress.value = 100;
                        });
                    };
                    debugger;
                    $scope.downloadFile("project/export" + ($scope.zip ? "?zip=true" : ""));
                    status = $timeout(progress, 500);
                }
            }]
        });
        modal.result.then(
            function(result) {
                stopStatus();
                $scope.downloadFile("");
            },
            function(){
                stopStatus();
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

controllers.controller('newProjectCtrl', ["$scope", 'WizardHandler', 'Project', 'ProjectService', '$filter', '$http', 'Session', function($scope, WizardHandler, Project, ProjectService, $filter, $http, Session){

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
        productowners:[Session.user],
        stakeholders:[]
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

    $scope.searchUsers = function(val){
        return $http.get($scope.serverUrl+ '/user/search', {
            params: {
                value: val,
                invit:true
            }
        }).then(function(response){
            return _.chain(response.data)
                .filter(function(u){
                    var found = _.find($scope.project.productowners, function(_u){
                        return u.email == _u.email;
                    });
                    if (!found){
                        found = _.find($scope.project.stakeholders, function(_u){
                            return u.email == _u.email;
                        });
                    }
                    if (!found){
                        if ($scope.project.team){
                            found = _.find($scope.project.team.members, function(_u){
                                return u.email == _u.email;
                            });
                        }
                    }
                    return !found;
                })
                .map(function(member){
                    member.name = member.firstName+' '+member.lastName;
                    return member;
                })
                .value();
        });
    };

    $scope.po = {};
    $scope.sh = {};
    $scope.addUser = function(user, role){
        if(role == 'po'){
            $scope.project.productowners.push(user);
            $scope.po = {};
        } else if(role == 'sh'){
            $scope.project.stakeholders.push(user);
            $scope.sh = {};
        }
    };

    $scope.removeUser = function(user, role){
        if(role == 'po'){
            $scope.project.productowners = _.filter($scope.project.productowners, function(_member){
                return _member.email != user.email;
            });
        } else if(role == 'sh'){
            $scope.project.stakeholders = _.filter($scope.project.stakeholders, function(_member){
                return _member.email != user.email;
            });
        }
    };

    $scope.createProject = function(project){
        var p = angular.copy(project);
        p.startDate = $filter( 'date')(project.startDate, "dd-MM-yyyy");
        p.endDate = $filter( 'date')(project.endDate, "dd-MM-yyyy");
        p.team.members = p.team.members.map(function(member){  return {id:member.id}; });
        p.team.scrumMasters = p.team.scrumMasters.map(function(sm){ return {id:sm.id}; });
        p.stakeholders = p.stakeholders.map(function(u){ return {id:u.id}; });
        p.productowners = p.productowners.map(function(u){ return {id:u.id}; });
        ProjectService.save(p).then(function(project){
            document.location = $scope.serverUrl + '/p/' + project.pkey + '/';
        });
    };
}]);
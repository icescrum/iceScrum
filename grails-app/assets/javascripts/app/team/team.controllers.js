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
controllers.controller('teamCtrl', ['$scope', '$http', '$filter', 'Session', function($scope, $http, $filter, Session) {

    $scope.team = {};
    $scope.searchTeam = function(val){
        return $http.get($scope.serverUrl+ '/team/search', {
            params: {
                value: val
            }
        }).then(function(response){
            return response.data;
        });
    };

    $scope.selectTeam = function($item, $model, $label){
        $scope.team = $model;
        $scope.team.selected = true;
        //Add current user to the team
        if (!$scope.team.id){
            var current = angular.copy(Session.user);
            $scope.team.members = [];
            $scope.team.members.push(current);
            $scope.team.scrumMasters = [];
            $scope.team.scrumMasters.push(current);
        }
        if ($model.members && $model.scrumMasters){
            $scope.team.members = $model.members.map(function(member){
                member.scrumMaster = _.find($model.scrumMasters, function(sm){ return member.id == sm.id }) ? true : false;
                return member;
            });
        }
        if ($scope.project){
            $scope.project.stakeHolders = _.filter($scope.project.stakeHolders, function(u){
                return !_.find($scope.team.members, function(_member){
                    return u.email == _member.email;
                });
            });
        }
    };

    $scope.unSelectTeam = function(){
        if ($scope.team.selected){
            $scope.team = {};
            $scope.member = {};
        }
    };

    $scope.member = {};
    $scope.searchMembers = function(val){
        return $http.get($scope.serverUrl+ '/user/search', {
            params: {
                value: val,
                invit:true
            }
        }).then(function(response){
            return _.chain(response.data)
                .filter(function(member){
                    var found = false;
                    if ($scope.project){
                        found = _.find($scope.project.stakeHolders, function(_member){
                            return member.email == _member.email;
                        });
                    }
                    if (!found){
                        found = _.find($scope.team.members, function(_member){
                            return member.email == _member.email;
                        });
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

    $scope.addTeamMember = function(item){
        $scope.team.members.push(item);
        $scope.member = {};
    };

    $scope.removeTeamMember = function($member){
        $scope.team.members = _.filter($scope.team.members, function(_member){
            return _member.email != $member.email;
        });
    };

    $scope.addTeam = function(product, team){
        team.scrumMasters = [];
        _.forEach(team.members, function (member) {
            if (member.scrumMaster) {
                team.scrumMasters.push(member);
            }
        });
        team.class = 'team';
        product.team = team;
        return true;
    }
}]);
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

controllers.controller('abstractTeamCtrl', ['$scope', '$filter', 'Session', 'TeamService', 'UserService', function($scope, $filter, Session, TeamService, UserService) {
    // Functions
    $scope.removeTeamMember = function(member) {
        _.remove($scope.team.members, {email: member.email});
        _.remove($scope.team.scrumMasters, {email: member.email});
    };
    $scope.scrumMasterChanged = function(member) {
        if (member.scrumMaster) {
            $scope.team.scrumMasters.push(member);
        } else {
            _.remove($scope.team.scrumMasters, {email: member.email}); // equality on email because invited members have no id
        }
    };
    $scope.searchMembers = function(val) {
        return UserService.search(val, true).then(function(users) {
            return _.chain(users)
                .filter(function(member) {
                    var found = false;
                    if ($scope.project) {
                        found = _.find($scope.project.stakeHolders, {email: member.email});
                    }
                    if (!found) {
                        found = _.find($scope.team.members, {email: member.email});
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
    $scope.invitationToUserMock = function(invitation) {
        return {email: invitation.email};
    };
    // Init
    $scope.team = $scope.team ? $scope.team : {};
    $scope.member = {};
}]);

controllers.controller('teamCtrl', ['$scope', '$controller', '$filter', 'Session', 'TeamService', function($scope, $controller, $filter, Session, TeamService) {
    $controller('abstractTeamCtrl', {$scope: $scope});
    // Functions
    $scope.searchTeam = function(val, create) {
        return TeamService.search(val, create).then(function(teams) {
            if ($scope.restrictedTeamsNames) {
                return _.filter(teams, function(team) {
                    return !_.includes($scope.restrictedTeamsNames, team.name);
                });
            } else {
                return teams;
            }
        });
    };
    $scope.selectTeam = function($item, $model) {
        $scope.team = $model;
        $scope.team.selected = true;
        //Add current user to the team
        if (!$scope.team.id) {
            $scope.team.class = 'team';
            var current = angular.copy(Session.user);
            $scope.team.members = [];
            $scope.team.members.push(current);
            $scope.team.scrumMasters = [];
            $scope.team.scrumMasters.push(current);
        }
        if ($model.members && $model.scrumMasters) {
            $scope.team.members = $model.members.map(function(member) {
                member.scrumMaster = _.find($model.scrumMasters, {id: member.id}) ? true : false;
                return member;
            });
        }
        if ($scope.project) {
            var filteredStakeHolders = _.filter($scope.project.stakeHolders, function(u) {
                return !_.find($scope.team.members, {email: u.email});
            });
            var filteredProductOwners = _.filter($scope.project.productOwners, function(u) {
                var member = _.find($scope.team.members, {email: u.email});
                return member ? member.scrumMaster : true;
            });
            if (filteredProductOwners.length != $scope.project.productOwners.length || filteredStakeHolders.length != $scope.project.stakeHolders.length) {
                $scope.warning.on = true;
            }
            $scope.project.stakeHolders = filteredStakeHolders;
            $scope.project.productOwners = filteredProductOwners;
            $scope.team.members = $scope.team.members.map(function(member) {
                member.productOwner = _.find($scope.project.productOwners, {id: member.id}) ? true : false;
                return member;
            });
            $scope.project.team = $scope.team;
        }
        if (!_.isEmpty($model.invitedMembers)) {
            $scope.team.members = $scope.team.members.concat(_.map($model.invitedMembers, $scope.invitationToUserMock));
        }
        if (!_.isEmpty($model.invitedScrumMasters)) {
            $scope.team.members = $scope.team.members.concat(_.map($model.invitedScrumMasters, function(invitation) {
                return _.merge($scope.invitationToUserMock(invitation), {scrumMaster: true});
            }));
        }
    };
    $scope.unSelectTeam = function() {
        $scope.warning.on = false;
        $scope.project.team = {};
        if ($scope.team.selected) {
            $scope.team = {};
            $scope.member = {};
        }
    };
    $scope.addTeamMember = function(member) {
        var po = _.find($scope.project.productOwners, {email: member.email});
        if (po) {
            member.scrumMaster = true;
            member.productOwner = true;
            $scope.team.scrumMasters.push(member);
        }
        $scope.team.members.push(member);
        $scope.member = {};
    };
    // Init
    $scope.warning = {on: false};
    if ($scope.project && $scope.project.team) {
        $scope.selectTeam(null, $scope.project.team);
    }
}]);

controllers.controller('manageTeamsModalCtrl', ['$scope', '$controller', '$filter', 'TeamService', function($scope, $controller, $filter, TeamService) {
    $controller('abstractTeamCtrl', {$scope: $scope});
    // Functions
    $scope.selectTeam = function(team) {
        $scope.team = angular.copy(team);
        if (team.members && team.scrumMasters) {
            $scope.team.members = team.members.map(function(member) {
                member.scrumMaster = _.find(team.scrumMasters, {id: member.id}) ? true : false;
                return member;
            });
            if (!_.isEmpty(team.invitedMembers)) {
                $scope.team.members = $scope.team.members.concat(_.map(team.invitedMembers, $scope.invitationToUserMock));
            }
            if (!_.isEmpty(team.invitedScrumMasters)) {
                $scope.team.members = $scope.team.members.concat(_.map(team.invitedScrumMasters, function(invitation) {
                    return _.merge($scope.invitationToUserMock(invitation), {scrumMaster: true});
                }));
            }
        }
        $scope.ownerCandidates = angular.copy($scope.team.members);
        var owner = team.owner;
        if (!_.find($scope.ownerCandidates, {id: owner.id})) {
            $scope.ownerCandidates.push(owner);
        }
    };
    $scope.save = function(team) {
        TeamService.save(team).then(function(team) {
            $scope.newTeam = {};
            $scope.team = team;
            $scope.teams.push(team);
            $scope.resetFormValidation($scope.formHolder.newTeamForm);
            $scope.notifySuccess('todo.is.ui.team.saved');
        });
    };
    $scope.update = function(team) {
        var invited = function(members) {
            return _.filter(members, function(member) {
                return !member.id
            });
        };
        team.invitedScrumMasters = invited(team.scrumMasters);
        team.invitedMembers = _.filter(invited(team.members), function(member) {
            return !_.some(team.invitedScrumMasters, {email: member.email});
        });
        TeamService.update(team).then(function(returnedTeam) {
            $scope.resetFormValidation($scope.formHolder.updateTeamForm);
            var teamIndex = _.findIndex($scope.teams, {id: team.id});
            if (teamIndex != -1) {
                $scope.teams.splice(teamIndex, 1, returnedTeam);
            }
            $scope.selectTeam(returnedTeam);
            $scope.notifySuccess('todo.is.ui.team.updated');
        });
    };
    $scope.delete = function(team) {
        TeamService.delete(team).then(function() {
            $scope.notifySuccess('todo.is.ui.deleted');
            $scope.team = {};
            $scope.searchTeams();
        });
    };
    $scope.cancelConfirmed = function() {
        $scope.team = {};
        $scope.resetFormValidation($scope.formHolder.updateTeamForm);
    };
    $scope.cancel = function() {
        if ($scope.formHolder.updateTeamForm.$dirty) {
            $scope.confirm({message: $scope.message('todo.is.ui.project.members.cancel.confirm'), callback: $scope.cancelConfirmed});
        } else {
            $scope.cancelConfirmed();
        }
    };
    $scope.teamSelected = function() {
        return !_.isEmpty($scope.team);
    };
    $scope.authorizedTeam = function(action, team) {
        return TeamService.authorizedTeam(action, team);
    };
    $scope.searchTeams = function() {
        var offset = $scope.teamsPerPage * ($scope.currentPage - 1);
        TeamService.listByUser($scope.teamSearch, offset).then(function(teams) {
            $scope.teams = teams;
        });
        TeamService.countByUser($scope.teamSearch).then(function(data) {
            $scope.totalTeams = data.count;
        });
    };
    $scope.teamMembersEditable = function() {
        return true;
    };
    $scope.addTeamMember = function(member) {
        $scope.team.members.push(member);
        $scope.member = {};
    };
    // Init
    if ($scope.selectedTeam) {
        $scope.selectTeam($scope.selectedTeam);
    }
    $scope.totalTeams = 0;
    $scope.currentPage = 1;
    $scope.teamsPerPage = 9; // Constant
    $scope.teamSearch = '';
    $scope.teams = [];
    $scope.formHolder = {};
    $scope.newTeam = {};
    $scope.searchTeams();
}]);
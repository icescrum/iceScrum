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
controllers.controller('projectCtrl', ["$scope", function($scope) {
}]);

controllers.controller('newProjectCtrl', ["$scope", 'WizardHandler', '$http', function($scope, WizardHandler, $http){
    $scope.product = {
        startDate:new Date(),
        endDate:new Date(new Date().setMonth(new Date().getMonth()+3)),
        name:'test',
        pkey:'AZERTY',
        preferences:{
            timezone:'Europe/Paris'
        }
    };

    $scope.$watchCollection('[product.startDate, product.endDate]', function(newValues){
        $scope.productMinDate = new Date(newValues[0]).setDate(newValues[0].getDate()+1);
        $scope.productMaxDate = new Date(newValues[1]).setDate(newValues[1].getDate()-1);
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

    $scope.searchTeam = function(val){
        return $http.get($scope.serverUrl+ '/team/search', {
            params: {
                value: val
            }
        }).then(function(response){
            return response.data;
        });
    };

    $scope.team = {};
    $scope.selectTeam = function($item, $model, $label){
        $scope.team = $model;
        $scope.team.selected = true;
        if ($model.members && $model.scrumMasters){
            $scope.team.members = $model.members.map(function(member){
                member.scrumMaster = _.find($model.scrumMasters, function(sm){ return member.id == sm.id }) ? true : false;
                return member;
            })
        }
    };
    $scope.unSelectTeam = function(){
        if ($scope.team.selected){
            $scope.team = {};
        }
    }

}]);
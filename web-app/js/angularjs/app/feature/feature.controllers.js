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
controllers.controller('featureCtrl', ['$scope', '$state', 'selected', 'FeatureService', function ($scope, $state, selected, FeatureService) {
    $scope.selected = selected;
    $scope.tabsType = 'tabs nav-tabs-google';
    $scope.tabActive = {'attachments': true};
    $scope.setTabActive = function (tabId) {
        $scope.tabActive = {};
        $scope.tabActive[tabId] = true;
    };
    $scope.update = function (feature) {
        FeatureService.update(feature, function () {
            $scope.$digest();
        });
    };

    $scope['delete'] = function (feature) {
        FeatureService.delete(feature);
        $state.go('^');
    };
}]);

controllers.controller('featureHeaderCtrl', ['$scope', 'FeatureService', function ($scope, FeatureService) {
    var list = FeatureService.list;
    var ind = list.indexOf($scope.selected);
    $scope.previous = ind > 0 ? list[ind - 1] : null;
    $scope.next = ind + 1 <= list.length ? list[ind + 1] : null;
}]);

controllers.controller('featureEditCtrl', ['$scope', 'Session', function ($scope, Session) {
    $scope.feature = angular.copy($scope.selected);
    $scope.selectTagsOptions = {
        tags: [],
        multiple: true,
        simple_tags: true,
        tokenSeparators: [",", " "],
        createSearchChoice: function (term) {
            return { id: term, text: term };
        },
        formatSelection: function (object) {
            return '<a href="#finder/?tag=' + object.text + '" onclick="document.location=this.href;"> <i class="fa fa-tag"></i> ' + object.text + '</a>';
        },
        ajax: {
            url: 'finder/tag',
            cache: 'true',
            data: function (term) {
                return {term: term};
            },
            results: function (data) {
                var results = [];
                angular.forEach(data, function (result) {
                    results.push({id: result, text: result});
                });
                return {results: results};
            }
        }
    };
    $scope.readOnly = function() {
        return !Session.roles.productOwner;
    };
}]);


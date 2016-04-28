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
 *
 */
controllers.controller('homeCtrl', ['$scope', '$filter', 'Session', 'WidgetService', function($scope, $filter, Session, WidgetService) {
    $scope.templateWidgetUrl = function(widget){
        return 'ui/widget/'+widget.widgetDefinitionId+ (widget.id? '/'+widget.id :'');
    };

    //init
    var position = function(event) {
        debugger;
        var widget = event.source.itemScope.modelValue;
        widget.position = event.dest.index + 1;
        widget.onRight = event.dest.sortableScope.options.sortableId === 'sortableRight';
        WidgetService.update(widget);
    };

    $scope.widgetSortableOptionsLeft = {
        itemMoved: position,
        orderChanged: position,
        sortableId:'sortableLeft',
        accept: function(sourceItemHandleScope, destSortableScope) {
            return _.includes(['sortableLeft', 'sortableRight'], destSortableScope.options.sortableId);
        }
    };

    $scope.widgetSortableOptionsRight = {
        itemMoved: position,
        orderChanged: position,
        sortableId:'sortableRight',
        accept: function(sourceItemHandleScope, destSortableScope) {
            return _.includes(['sortableLeft', 'sortableRight'], destSortableScope.options.sortableId);
        }
    };

    $scope.authenticated = Session.authenticated; // This is a function which return value will change when user will be set

    $scope.widgets = Session.widgets;
    $scope.$watchCollection('widgets', function(){
        $scope.widgetsOnLeft = $filter('filter')($scope.widgets, {onRight:false});
        $scope.widgetsOnRight = $filter('filter')($scope.widgets, {onRight:true});
    });
    WidgetService.list();
}]);
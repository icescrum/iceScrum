/*
 * Copyright (c) 2016 Kagilum SAS.
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
 * Colin Bontemps (cbontemps@kagilum.com)
 *
 */

controllers.controller("widgetCtrl", ['$scope', 'WidgetService', '$q', function($scope, WidgetService, $q) {
    // Used to be overrided by plugin if necessary
    $scope.display = function(widget) {};
    $scope.toggleSettings = function(widget) {
        if ($scope.showSettings) {
            return $scope.update(widget).then(function(widget) {
                $scope.showSettings = !$scope.showSettings;
                $scope.display(widget);
            });
        }
        $scope.showSettings = !$scope.showSettings;
        return $q.when(widget);
    };
    $scope.update = function(widget) {
        return WidgetService.update(widget);
    };
    $scope.delete = function(widget) {
        return WidgetService.delete(widget);
    };
    $scope.authorizedWidget = WidgetService.authorizedWidget;
}]);

controllers.controller('widgetViewCtrl', ['$scope', '$uibModal', 'Session', 'CacheService', 'WidgetService', function($scope, $uibModal, Session, CacheService, WidgetService) {
    // Functions
    $scope.showAddWidgetModal = function() {
        $uibModal.open({
            keyboard: false,
            templateUrl: 'addWidget.modal.html',
            controller: ['$scope', function($scope) {
                $scope.detailsWidgetDefinition = function(widgetDefinition) {
                    $scope.widgetDefinition = widgetDefinition;
                    $scope.addWidgetForm.$invalid = !widgetDefinition.available;
                };
                $scope.addWidget = function(widgetDefinition) {
                    WidgetService.save(widgetDefinition.id).then(function() {
                        $scope.$close();
                    });
                };
                // Init
                $scope.widgetDefinition = {};
                $scope.widgetDefinitions = [];
                WidgetService.getWidgetDefinitions().then(function(widgetDefinitions) {
                    if (widgetDefinitions.length > 0) {
                        $scope.widgetDefinitions = widgetDefinitions;
                        $scope.widgetDefinition = widgetDefinitions[0];
                    }
                });
            }],
            size: 'lg'
        });
    };
    $scope.templateWidgetUrl = function(widget) {
        return 'ui/widget/' + widget.widgetDefinitionId + (widget.id ? '/' + widget.id : '');
    };
    // Init
    var position = function(event) {
        var widget = event.source.itemScope.modelValue;
        widget.position = event.dest.index + 1;
        WidgetService.update(widget).catch(function() {
            $scope.revertSortable(event);
        });
    };
    $scope.widgetSortableOptions = {
        itemMoved: position,
        orderChanged: position,
        placeholderDisableComputeBounds: true,
        placeholder: function($scopeItem) {
            var widget = $scopeItem.element.find('.card')[0];
            var width = widget.getBoundingClientRect().width;
            var height = widget.getBoundingClientRect().height;
            return "<div style='height:" + height + "px;width:" + width + "px;'/>";
        },
        sortableId: 'widgets',
        containment: '.widget-dashboard > .row',
        containerPositioning: 'relative'
    };
    $scope.authenticated = Session.authenticated; // This is a function which return value will change when user will be set
    $scope.widgets = CacheService.getCache('widget');
    $scope.authorizedWidget = WidgetService.authorizedWidget;
    WidgetService.list();
}]);
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
controllers.controller('homeCtrl', ['$scope', 'Session', 'CacheService', 'WidgetService', function($scope, Session, CacheService, WidgetService) {
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
            var widget = $scopeItem.element.find('.panel')[0];
            var width = widget.getBoundingClientRect().width;
            var height = widget.getBoundingClientRect().height;
            return "<div style='height:" + height + "px;width:" + width + "px;'/>";
        },
        sortableId: 'widgets',
        containment: '#view-home > .row',
        containerPositioning: 'relative'
    };
    $scope.authenticated = Session.authenticated; // This is a function which return value will change when user will be set
    $scope.widgets = CacheService.getCache('widget');
    WidgetService.list();
}]);
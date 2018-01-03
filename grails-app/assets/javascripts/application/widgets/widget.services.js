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
 *
 */

services.factory('Widget', ['Resource', function($resource) {
    return $resource('ui/widget/:widgetDefinitionId/:id?nocache=' + (new Date()).getTime()); //fix weird safari no-cache control from server
}]);

services.service("WidgetService", ['CacheService', 'FormService', '$q', 'Widget', 'Session', function(CacheService, FormService, $q, Widget, Session) {
    this.list = function() {
        var cachedWidgets = CacheService.getCache('widget');
        return _.isEmpty(cachedWidgets) ? Widget.query({}, function(widgets) {
            _.each(widgets, function(widget) {
                widget.settings = widget.settingsData ? JSON.parse(widget.settingsData) : undefined;
                delete widget.settingsData;
                CacheService.addOrUpdate('widget', widget);
            });
        }).$promise : $q.when(cachedWidgets);
    };
    this.save = function(widgetDefinitionId) {
        var widget = {widget: 'feature', widgetDefinitionId: widgetDefinitionId};
        return Widget.save(widget, function(widget) {
            widget.settings = widget.settingsData ? JSON.parse(widget.settingsData) : undefined;
            delete widget.settingsData;
            CacheService.addOrUpdate('widget', widget);
        }).$promise;
    };
    this.update = function(widget) {
        widget.class = 'widget';
        widget.settingsData = JSON.stringify(widget.settings);
        return Widget.update({widgetDefinitionId: widget.widgetDefinitionId}, widget, function(widget) {
            widget.settings = widget.settingsData ? JSON.parse(widget.settingsData) : undefined;
            delete widget.settingsData;
            CacheService.addOrUpdate('widget', widget);
        }).$promise;
    };
    this['delete'] = function(widget) {
        return Widget.delete({widgetDefinitionId: widget.widgetDefinitionId, id: widget.id}, {}, function() {
            CacheService.remove('widget', widget.id);
        }).$promise;
    };
    this.getWidgetDefinitions = function() {
        return FormService.httpGet('ui/widget/definitions');
    };
    this.authorizedWidget = function(action, widget) {
        switch (action) {
            case 'move':
                return Session.authenticated();
            case 'create':
            case 'update':
            case 'delete':
                switch (Session.workspaceType) {
                    case 'portfolio': return Session.bo();
                    default: return Session.authenticated();
                }
            default:
                return false;
        }
    };
}]);

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

services.factory('Window', ['Resource', function($resource) {
    return $resource('ui/window/:windowDefinitionId/settings', {});
}]);

services.service("WindowService", ['CacheService', '$q', 'Window', function(CacheService, $q, Window) {
    var self = this;
    this.get = function(windowDefinitionId, context) {
        var id = self.computeId(windowDefinitionId, context ? context.class.toLowerCase() : null, context ? context.id : null);
        var cachedWindow = CacheService.get('window', id);
        return !angular.isUndefined(cachedWindow) ? $q.when(cachedWindow) : self.refresh(windowDefinitionId);
    };
    this.update = function(window) {
        window.class = 'window';
        window.settingsData = JSON.stringify(window.settings);
        return Window.update({windowDefinitionId: window.windowDefinitionId }, window, function(window) {
            window.id = self.computeId(window);
            window.settings = window.settingsData ? JSON.parse(window.settingsData) : {};
            delete window.settingsData;
            CacheService.addOrUpdate('window', window);
        }).$promise;
    };
    this.refresh = function(windowDefinitionId) {
        return Window.get({windowDefinitionId: windowDefinitionId}, function(window){
            window.id = self.computeId(window);
            window.settings = window.settingsData ? JSON.parse(window.settingsData) : {};
            delete window.settingsData;
            CacheService.addOrUpdate('window', window);
        }).$promise;
    };
    this.computeId = function(object, context, contextId){
        if(object.windowDefinitionId){
            return object.windowDefinitionId+'-'+object.context+'-'+object.contextId;
        } else {
            var id = object;
            if(context && contextId){
                id = id+'-'+context+'-'+contextId;
            }
            return id;
        }

    }
}]);

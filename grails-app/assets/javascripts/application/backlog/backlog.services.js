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
 * Vincent Barrier (vbarrier@kagilum.com)
 *
 */
services.factory('Backlog', ['Resource', function($resource) {
    return $resource('/p/:projectId/backlog/:id/:action');
}]);

services.service("BacklogService", ['Backlog', '$q', 'CacheService', 'StoryService', 'BacklogCodes', 'FormService', function(Backlog, $q, CacheService, StoryService, BacklogCodes, FormService) {
    var self = this;
    this.get = function(id, project) {
        return Backlog.get({id: id, projectId: project.id}).$promise;
    };
    this.list = function(project) {
        var cachedBacklogs = project.backlogs;
        return _.isEmpty(cachedBacklogs) ? Backlog.query({projectId: project.id}, self.mergeBacklogs).$promise.then(function() {
            return cachedBacklogs;
        }) : $q.when(cachedBacklogs);
    };
    this.isAll = function(backlog) {
        return backlog.code == BacklogCodes.ALL;
    };
    this.isSandbox = function(backlog) {
        return backlog.code == BacklogCodes.SANDBOX;
    };
    this.isBacklog = function(backlog) {
        return backlog.code == BacklogCodes.BACKLOG;
    };
    this.filterStories = function(backlog, stories) {
        var storyFilter = JSON.parse(backlog.filter).story;
        return StoryService.filterStories(stories, storyFilter);
    };
    this.openChart = function(backlog, project, chartType, chartUnit) {
        return FormService.httpGet('p/' + project.id + '/backlog/' + backlog.id + '/' + 'chartByProperty', {params: {chartType: chartType, chartUnit: chartUnit}}, true);
    };
    this.mergeBacklogs = function(backlogs) {
        _.each(backlogs, function(backlog) {
            CacheService.addOrUpdate('backlog', backlog);
        });
    };
}]);
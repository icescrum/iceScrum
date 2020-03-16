/*
 * Copyright (c) 2020 Kagilum SAS.
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
services.factory('Meeting', ['Resource', function($resource) {
    return $resource('/:workspaceType/:workspaceId/meeting/:type/:typeId/:id');
}]);

services.service('MeetingService', ['Meeting', 'Session', 'IceScrumEventType', 'CacheService', 'PushService', function(Meeting, Session, IceScrumEventType, CacheService, PushService) {
    var self = this;
    var crudMethods = {};
    crudMethods[IceScrumEventType.CREATE] = function(meeting) {
        meeting.startDate = meeting.startDate ? meeting.startDate.toISOString() : null; // Timeago requires ISO string
        meeting.endDate = meeting.endDate ? meeting.endDate.toISOString() : null; // Timeago requires ISO string
        CacheService.addOrUpdate('meeting', meeting);
    };
    crudMethods[IceScrumEventType.UPDATE] = function(meeting) {
        meeting.startDate = meeting.startDate ? meeting.startDate.toISOString() : null; // Timeago requires ISO string
        meeting.endDate = meeting.endDate ? meeting.endDate.toISOString() : null; // Timeago requires ISO string
        CacheService.addOrUpdate('meeting', meeting);
    };
    crudMethods[IceScrumEventType.DELETE] = function(meeting) {
        CacheService.remove('meeting', meeting.id);
    };
    _.each(crudMethods, function(crudMethod, eventType) {
        PushService.registerListener('meeting', eventType, crudMethod);
    });
    this.mergeMeetings = function(meeting) {
        _.each(meeting, crudMethods[IceScrumEventType.UPDATE]);
    };
    this.save = function(meeting, workspace, context) {
        meeting.class = 'meeting';
        if (context) {
            meeting.contextId = context.id;
            meeting.contextType = context.class.toLowerCase();
        }
        return Meeting.save({workspaceId: workspace.id, workspaceType: workspace.class.toLowerCase()}, meeting, crudMethods[IceScrumEventType.CREATE]).$promise;
    };
    this['delete'] = function(meeting, workspace) {
        return Meeting.delete({workspaceId: workspace.id, workspaceType: workspace.class.toLowerCase()}, meeting, crudMethods[IceScrumEventType.DELETE]).$promise;
    };
    this.update = function(meeting, workspace) {
        return Meeting.update({workspaceId: workspace.id, workspaceType: workspace.class.toLowerCase()}, meeting, crudMethods[IceScrumEventType.UPDATE]).$promise;
    };
    this.list = function(workspace, context) {
        return Meeting.query({workspaceId: workspace.id, workspaceType: workspace.class.toLowerCase(), typeId: context ? context.id : null, type: context ? context.class.toLowerCase() : null}, self.mergeMeetings).$promise;
    };
    this.authorizedMeeting = function(action, meeting) {
        switch (action) {
            case 'create':
            case 'view':
                return Session.inProject() || Session.bo();
            case 'update':
            case 'delete':
                return Session.owner(meeting) || Session.poOrSm();
            default:
                return false;
        }
    }
}]);
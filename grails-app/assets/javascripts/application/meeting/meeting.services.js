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

services.service("MeetingService", ['$q', 'Meeting', 'Session', 'IceScrumEventType', 'CacheService', 'PushService', 'I18nService', 'notifications', function($q, Meeting, Session, IceScrumEventType, CacheService, PushService, I18nService, notifications) {
    var self = this;
    var crudMethods = {};
    crudMethods[IceScrumEventType.CREATE] = function(meeting) {
        meeting.startDate = meeting.startDate ? meeting.startDate.toISOString() : null; //prevent to be a date object
        meeting.endDate = meeting.endDate ? meeting.endDate.toISOString() : null; //prevent to be a date object
        CacheService.addOrUpdate('meeting', meeting);
    };
    crudMethods[IceScrumEventType.UPDATE] = function(meeting) {
        meeting.startDate = meeting.startDate ? meeting.startDate.toISOString() : null; //prevent to be a date object
        meeting.endDate = meeting.endDate ? meeting.endDate.toISOString() : null; //prevent to be a date object
        CacheService.addOrUpdate('meeting', meeting);
    };
    crudMethods[IceScrumEventType.DELETE] = function(meeting) {
        CacheService.remove('meeting', meeting.id);
    };
    _.each(crudMethods, function(crudMethod, eventType) {
        PushService.registerListener('meeting', eventType, crudMethod);
    });
    this.displayNotification = function(meeting) {
        if (meeting.owner.id !== Session.user.id) {
            notifications.success('', I18nService.message("is.ui.collaboration.notification", [meeting.provider, meeting.subject]), {
                button: {
                    type: "primary gold",
                    name: I18nService.message("is.ui.collaboration.join"),
                    link: meeting.videoLink,
                    rel: "noreferer",
                    target: "_blank",
                    delay: 15000
                }
            });
        }
    };
    PushService.registerListener('meeting', "CREATE", this.displayNotification);
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
        var promise = Meeting.query({workspaceId: workspace.id, workspaceType: workspace.class.toLowerCase(), typeId: context ? context.id : null, type: context ? context.class.toLowerCase() : null}, self.mergeMeetings).$promise;
        return promise;
    };
    this.authorizedMeeting = function(action, meeting) {
        switch (action) {
            case 'create':
            case 'view':
                return Session.inProject() || Session.bo();
            case 'update':
            case 'delete':
                return Session.user.id == meeting.owner.id || Session.poOrSm();
            default:
                return false;
        }
    }
}]);
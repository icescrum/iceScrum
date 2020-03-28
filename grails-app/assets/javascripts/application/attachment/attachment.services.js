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
services.factory('Attachment', ['Resource', function($resource) {
    return $resource('/:workspaceType/:workspaceId/attachment/:type/:typeId/:id', {typeId: '@typeId', type: '@type'});
}]);

services.service("AttachmentService", ['Attachment', 'Session', '$q', '$injector', 'PushService', 'IceScrumEventType', function(Attachment, Session, $q, $injector, PushService, IceScrumEventType) {
    var self = this;
    this.getAttachmentable = function(attachment) {
        return $injector.get(attachment.attachmentable.class + 'Service').get(attachment.attachmentable.id);
    };

    PushService.registerListener('attachment', IceScrumEventType.CREATE, function(attachment) {
        self._addToAttachmentable(attachment)
    });

    PushService.registerListener('attachment', IceScrumEventType.UPDATE, function(attachment) {
        self.getAttachmentable(attachment).then(function(attachmentable) {
            var existingAttachment = _.find(attachmentable.attachments, {id: attachment.id});
            _.merge(existingAttachment, attachment);
        });
    });

    PushService.registerListener('attachment', IceScrumEventType.DELETE, function(attachment) {
        self.getAttachmentable(attachment).then(function(attachmentable) {
            _.remove(attachmentable.attachments, {id: attachment.id});
            attachmentable.attachments_count = attachmentable.attachments.length;
        });
    });

    this._addToAttachmentable = function(attachment) {
        self.getAttachmentable(attachment).then(function(attachmentable) {
            self.addToAttachmentable(attachment, attachmentable);
        });
    };

    this.addToAttachmentable = function(attachment, attachmentable) {
        if (!_.find(attachmentable.attachments, {id: attachment.id})) {
            attachment.type = attachmentable.class.toLowerCase();
            attachment.typeId = attachmentable.id;
            attachment.attachmentable = {id: attachmentable.id};
            attachmentable.attachments.unshift(attachment);
            attachmentable.attachments_count = attachmentable.attachments.length;
        }
    };
    this.update = function(attachment, attachmentable, workspaceId, workspaceType) {
        return Attachment.update({type: attachmentable.class.toLowerCase(), typeId: attachmentable.id, id: attachment.id, workspaceId: workspaceId, workspaceType: workspaceType}, attachment, function(returnedAttachment) {
            var existingAttachment = _.find(attachmentable.attachments, {id: returnedAttachment.id});
            _.merge(existingAttachment, returnedAttachment);
        }).$promise;
    };
    this['delete'] = function(attachment, attachmentable, workspaceId, workspaceType) {
        return Attachment.delete({type: attachmentable.class.toLowerCase(), typeId: attachmentable.id, id: attachment.id, workspaceId: workspaceId, workspaceType: workspaceType}, function() {
            _.remove(attachmentable.attachments, {id: attachment.id});
            attachmentable.attachments_count = attachmentable.attachments.length;
        }).$promise;
    };
    this.authorizedAttachment = function(action, attachment) {
        switch (action) {
            case 'update':
            case 'delete':
                return Session.poOrSm();
            default:
                return false;
        }
    };
    this.list = function(attachmentable, workspaceId, workspaceType) {
        if (_.isEmpty(attachmentable.attachments) && attachmentable.attachments_count > 0) {
            return Attachment.query({typeId: attachmentable.id, type: attachmentable.class.toLowerCase(), workspaceId: workspaceId, workspaceType: workspaceType}, function(data) {
                attachmentable.attachments = data;
                attachmentable.attachments_count = attachmentable.attachments.length;
            }).$promise;
        } else {
            if (!angular.isArray(attachmentable.attachments)) {
                attachmentable.attachments = []
            }
            return $q.when(attachmentable.attachments);
        }
    };
}]);
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
    return $resource('/p/:projectId/attachment/:type/:typeId/:id', {typeId: '@typeId', type: '@type'});
}]);

services.service("AttachmentService", ['Attachment', 'Session', '$q', function(Attachment, Session, $q) {
    this.addToAttachmentable = function(attachment, attachmentable) {
        if (!_.find(attachmentable.attachments, {id: attachment.id})) {
            attachment.type = attachmentable.class.toLowerCase();
            attachment.typeId = attachmentable.id;
            attachment.attachmentable = {id: attachmentable.id};
            attachmentable.attachments.unshift(attachment);
            attachmentable.attachments_count = attachmentable.attachments.length;
        }
    };
    this.update = function(attachment, attachmentable, projectId) {
        return Attachment.update({type: attachmentable.class.toLowerCase(), typeId: attachmentable.id, id: attachment.id, projectId: projectId}, attachment, function(returnedAttachment) {
            var existingAttachment = _.find(attachmentable.attachments, {id: returnedAttachment.id});
            _.merge(existingAttachment, returnedAttachment);
        }).$promise;
    };
    this['delete'] = function(attachment, attachmentable, projectId) {
        return Attachment.delete({type: attachmentable.class.toLowerCase(), typeId: attachmentable.id, id: attachment.id, projectId: projectId}, function() {
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
    this.list = function(attachmentable, projectId) {
        if (_.isEmpty(attachmentable.attachments) && attachmentable.attachments_count > 0) {
            return Attachment.query({typeId: attachmentable.id, type: attachmentable.class.toLowerCase(), projectId: projectId}, function(data) {
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
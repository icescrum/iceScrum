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
services.factory('Attachment', [ 'Resource', function($resource) {
    return $resource('attachment/:type/:typeId/:id', { typeId: '@typeId', type: '@type' });
}]);

services.service("AttachmentService", ['$q', 'Attachment', 'Session', function($q, Attachment, Session) {
    this.save = function(attachment, attachmentable) {
        attachment.type = attachmentable.class.toLowerCase();
        attachment.typeId = attachmentable.id;
        attachment.attachmentable = {id: attachmentable.id };
        attachmentable.attachments.unshift(attachment);
    };
    this['delete'] = function(attachment, attachmentable) {
        attachment.type = attachmentable.class.toLowerCase();
        attachment.typeId = attachmentable.id;
        attachment.attachmentable = {id: attachmentable.id};
        return Attachment.delete(attachment, function() {
            _.remove(attachmentable.attachments, { id: attachment.id });
        });
    };
    this.list = function(attachmentable) {
        if (_.isEmpty(attachmentable.attachments)) {
            return Attachment.query({ typeId: attachmentable.id, type: attachmentable.class.toLowerCase() }, function(data) {
                attachmentable.attachments = data;
            }).$promise;
        } else {
            return $q.when(attachmentable.attachments);
        }
    };
    this.authorizedAttachment = function(action, attachment) {
        switch (action) {
            case 'delete':
                return Session.poOrSm() || Session.user.id == attachment.posterId;
            default:
                return false;
        }
    }
}]);
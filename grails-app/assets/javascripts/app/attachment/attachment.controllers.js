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
controllers.controller('attachmentCtrl', ['$scope', 'AttachmentService', function($scope, AttachmentService) {
    //manual save from flow js
    $scope.$on('flow::fileSuccess', function(event, $flow, flowFile, message) {
        var attachment = JSON.parse(message);
        AttachmentService.save(attachment, $scope.story);
    });
    $scope['delete'] = function(attachment, attachmentable) {
        AttachmentService.delete(attachment, attachmentable);
    };
    $scope.authorizedAttachment = function(action, attachment) {
        return AttachmentService.authorizedAttachment(action, attachment);
    };
}]);
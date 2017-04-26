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
extensibleController('attachmentCtrl', ['$scope', '$uibModal', 'AttachmentService', 'attachmentable', 'clazz', function($scope, $uibModal, AttachmentService, attachmentable, clazz) {
    // Functions
    $scope.deleteAttachment = function(attachment, attachmentable) { // cannot be just "delete" because it clashes with controllers that will inherit from this one
        AttachmentService.delete(attachment, attachmentable);
    };
    $scope.authorizedAttachment = function(action, attachment) {
        return AttachmentService.authorizedAttachment(action, attachment);
    };
    $scope.getUrl = function(clazz, attachmentable, attachment) {
        return attachment.url ? attachment.url : "attachment/" + clazz + "/" + attachmentable.id + "/" + attachment.id;
    };
    $scope.isPreviewable = function(attachment) {
        if (attachment.provider) {
            return false;
        }
        var previewable;
        var ext = attachment.ext ? attachment.ext.toLowerCase() : '';
        switch (ext) {
            case 'pdf':
                previewable = 'pdf';
                break;
            case 'png':
            case 'gif':
            case 'jpg':
            case 'jpeg':
            case 'bmp':
                previewable = 'picture';
                break;
            default :
                previewable = false;
        }
        return previewable;
    };
    $scope.showPreview = function(attachment, attachmentable, type) {
        var previewType = $scope.isPreviewable(attachment);
        if (previewType == 'pdf') {
            $uibModal.open({
                templateUrl: "attachment.preview.pdf.html",
                size: 'lg',
                controller: ['$scope', 'PDFViewerService', function($scope, pdf) {
                    $scope.title = attachment.filename;
                    $scope.pdfURL = "attachment/" + type + "/" + attachmentable.id + "/" + attachment.id;
                    $scope.scale = 1.5;
                    $scope.viewer = pdf.Instance("viewer");
                    $scope.nextPage = function() {
                        $scope.viewer.nextPage();
                    };
                    $scope.prevPage = function() {
                        $scope.viewer.prevPage();
                    };
                    $scope.pageLoaded = function(curPage, totalPages) {
                        $scope.currentPage = curPage;
                        $scope.totalPages = totalPages;
                    };
                }]
            });
        } else if (previewType == 'picture') {
            $uibModal.open({
                templateUrl: "attachment.preview.picture.html",
                size: 'lg',
                controller: ['$scope', function($scope) {
                    $scope.title = attachment.filename;
                    $scope.srcURL = "attachment/" + type + "/" + attachmentable.id + "/" + attachment.id;
                }]
            });
        } else {
            attachment.showPreview = !attachment.showPreview;
        }

    };
    $scope.attachmentQuery = function($flow, attachmentable) {
        $scope.flow = $flow;
        $flow.opts.target = 'attachment/' + $scope.clazz + '/' + attachmentable.id + '/flow';
        $flow.upload();
    };
    // Init
    $scope.attachmentable = attachmentable;
    $scope.clazz = clazz;
}]);

// Flow events are triggered by "$scope.$broadcast so they can be received only on controllers that are at the same level or below
// Thus, this controller must be added at the lowest level where the event can be broadcasted from, i.e. the buttons
extensibleController('attachmentNestedCtrl', ['$scope', 'AttachmentService', function($scope, AttachmentService) {
    $scope.$on('flow::fileSuccess', function(event, $flow, flowFile, message) {
        var attachment = JSON.parse(message);
        AttachmentService.addToAttachmentable(attachment, $scope.attachmentable);
    });
    $scope.$on('flow::fileError', function(event, $flow, flowFile, message) {
        var data = JSON.parse(message);
        $scope.notifyError(angular.isArray(data) ? data[0].text : data.text, {duration: 8000});
    });
}]);


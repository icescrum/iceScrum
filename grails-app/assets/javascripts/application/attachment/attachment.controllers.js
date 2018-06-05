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
extensibleController('attachmentCtrl', ['$scope', '$uibModal', 'AttachmentService', 'attachmentable', 'clazz', 'project', function($scope, $uibModal, AttachmentService, attachmentable, clazz, project) {
    // Functions
    $scope.deleteAttachment = function(attachment, attachmentable) { // cannot be just "delete" because it clashes with controllers that will inherit from this one
        AttachmentService.delete(attachment, attachmentable, project.id);
    };
    $scope.authorizedAttachment = AttachmentService.authorizedAttachment;
    $scope.getMethod = function(attachment, method) {
        return $scope[method + _.capitalize(attachment.provider) + _.capitalize(attachment.ext)];
    };
    $scope.getUrl = function(clazz, attachmentable, attachment) {
        if (attachment.provider && $scope.getMethod(attachment, 'getUrl')) {
            return $scope.getMethod(attachment, 'getUrl')(clazz, attachmentable, attachment)
        } else {
            return attachment.url ? attachment.url : $scope.attachmentBaseUrl + clazz + "/" + attachmentable.id + "/" + attachment.id;
        }
    };
    $scope.isPreviewable = function(attachment) {
        var previewable;
        var ext = attachment.ext ? attachment.ext.toLowerCase() : '';
        if (attachment.provider) {
            return $scope.getMethod(attachment, 'isPreviewable') ? $scope.getMethod(attachment, 'isPreviewable')() : false;
        }
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
    $scope.isAttachmentEditable = function(attachment) {
        if (attachment.provider) {
            return $scope.getMethod(attachment, 'isAttachmentEditable') ? $scope.getMethod(attachment, 'isAttachmentEditable')() : false;
        } else {
            return false;
        }
    };
    $scope.isAttachmentDownloadable = function(attachment) {
        if (attachment.provider) {
            return $scope.getMethod(attachment, 'isAttachmentDownloadable') ? $scope.getMethod(attachment, 'isAttachmentDownloadable')() : false;
        } else {
            return true;
        }
    };
    $scope.editAttachment = function(attachment, attachmentable, type) {
        if ($scope.isAttachmentEditable(attachment)) {
            $scope.getMethod(attachment, 'editAttachment')(attachment, attachmentable, type)
        }
    };
    $scope.showPreview = function(attachment, attachmentable, type) {
        var previewType = $scope.isPreviewable(attachment);
        var attachmentBaseUrl = $scope.attachmentBaseUrl;
        if (previewType == 'pdf') {
            $uibModal.open({
                templateUrl: "attachment.preview.pdf.html",
                size: 'lg',
                controller: ['$scope', 'PDFViewerService', function($scope, pdf) {
                    $scope.title = attachment.filename;
                    $scope.pdfURL = attachmentBaseUrl + type + "/" + attachmentable.id + "/" + attachment.id;
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
        } else if (previewType === 'picture') {
            $uibModal.open({
                templateUrl: "attachment.preview.picture.html",
                size: 'lg',
                controller: ['$scope', function($scope) {
                    $scope.title = attachment.filename;
                    $scope.srcURL = attachmentBaseUrl + type + "/" + attachmentable.id + "/" + attachment.id;
                }]
            });
        } else if (previewType) {
            $scope.getMethod(attachment, 'showPreview')(attachment, attachmentable, type);
        }

    };
    $scope.attachmentQuery = function($flow, attachmentable) {
        $scope.flow = $flow;
        $flow.opts.target = $scope.attachmentBaseUrl + $scope.clazz + '/' + attachmentable.id + '/flow';
        $flow.upload();
    };
    // Init
    $scope.attachmentable = attachmentable;
    $scope.clazz = clazz;
    $scope.attachmentBaseUrl = $scope.serverUrl + '/p/' + project.id + '/attachment/';
}]);

// Flow events are triggered by "$scope.$broadcast so they can be received only on controllers that are at the same level or below
// Thus, this controller must be added at the lowest level where the event can be broadcasted from, i.e. the buttons
extensibleController('attachmentNestedCtrl', ['$scope', 'AttachmentService', function($scope, AttachmentService) {
    $scope.$on('flow::fileSuccess', function(event, $flow, flowFile, message) {
        var attachment = JSON.parse(message);
        AttachmentService.addToAttachmentable(attachment, $scope.attachmentable);
        $flow.cancel();
    });
    $scope.$on('flow::fileError', function(event, $flow, flowFile, message) {
        var data = JSON.parse(message);
        $scope.notifyError(angular.isArray(data) ? data[0].text : data.text, {duration: 8000});
        $flow.cancel();
    });
}]);


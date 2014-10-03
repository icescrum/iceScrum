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
controllers.controller('attachmentCtrl', ['$scope', '$modal', 'AttachmentService', function($scope, $modal, AttachmentService) {
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

    $scope.isPreviewable = function(attachment){
        var previewable;
        switch (attachment.ext){
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
            /*case 'mp3':
            case 'wave':
            case 'aac':
                previewable = 'audio';
                break;
            case 'avi':
            case 'flv':
            case 'mp4':
            case 'mpg':
            case 'mpeg':
                previewable = 'video';
                break;*/
            default :
                previewable = false;
        }
        return previewable;
    };

    $scope.showPreview = function(attachment, attachmentable, type){
        var previewType = $scope.isPreviewable(attachment);
        if(previewType == 'pdf'){
            $modal.open({
                templateUrl: "attachment.preview.pdf.html",
                size:'lg',
                controller:[ '$scope', 'PDFViewerService', function($scope, pdf) {
                    $scope.title = attachment.filename;
                    $scope.pdfURL = "attachment/"+type+"/"+attachmentable.id+"/"+ attachment.id;
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
        } else if (previewType == 'picture'){
            $modal.open({
                templateUrl: "attachment.preview.picture.html",
                size:'lg',
                controller:[ '$scope', function($scope) {
                    $scope.title = attachment.filename;
                    $scope.srcURL = "attachment/"+type+"/"+attachmentable.id+"/"+ attachment.id;
                }]
            });
        } else {
            attachment.showPreview = !attachment.showPreview;
        }

    };
}]);
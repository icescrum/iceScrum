%{--
- Copyright (c) 2014 Kagilum.
-
- This file is part of iceScrum.
-
- iceScrum is free software: you can redistribute it and/or modify
- it under the terms of the GNU Affero General Public License as published by
- the Free Software Foundation, either version 3 of the License.
-
- iceScrum is distributed in the hope that it will be useful,
- but WITHOUT ANY WARRANTY; without even the implied warranty of
- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
- GNU General Public License for more details.
-
- You should have received a copy of the GNU Affero General Public License
- along with iceScrum.  If not, see <http://www.gnu.org/licenses/>.
-
- Authors:
-
- Vincent Barrier (vbarrier@kagilum.com)
--}%
<script type="text/ng-template" id="attachment.list.html">
<div ng-repeat="attachment in attachmentable.attachments" class="hover-container" ng-show="$index < 10 || pref.showMore['attachments']">
    <hr ng-class="{'mt-0':$first}">
    <div class="attachment media d-flex align-content-stretch flex-wrap" ng-class="{'mb-3':$last || (attachmentable.attachments.length > 10 && !pref.showMore['attachments'])}">
        <div class="media-body flex-grow-1 attachment-type {{:: attachment.provider ? 'attachment-type-'+getAttachmentProviderName(attachment) : (attachment.ext | fileicon) }}">
            <div class="d-flex align-items-center justify-content-end flex-wrap">
                <a ng-if="!isPreviewable(attachment)"
                   class="filename flex-grow-1 mb-1 mb-md-0 text-truncate text-truncate-fix"
                   target="{{:: attachment.provider ? '_blank' : '' }}"
                   href="{{:: getUrl(clazz, attachmentable, attachment) }}">{{ attachment.filename }}</a>
                <a ng-if="isPreviewable(attachment)"
                   class="filename flex-grow-1 mb-1 mb-md-0 text-truncate text-truncate-fix"
                   ng-click="showPreview(attachment, attachmentable, clazz)"
                   href>{{ attachment.filename }}</a>
                <a ng-if=":: isAttachmentEditable(attachment)"
                   class="btn btn-secondary btn-sm hover-visible"
                   ng-click=":: editAttachment(attachment, attachmentable, clazz)"
                   href>Edit</a>
                <a ng-if=":: authorizedAttachment('update', attachment)"
                   class="btn btn-secondary btn-sm hover-visible"
                   ng-click="showEditAttachmentName(attachment, attachmentable)"
                   href>${message(code: 'todo.is.ui.attachment.edit')}</a>
                <a ng-if=":: isAttachmentDownloadable(attachment)"
                   class="btn btn-secondary btn-sm hover-visible"
                   href="{{:: getUrl(clazz, attachmentable, attachment) }}">Download</a>
                <a ng-if=":: !isAttachmentDownloadable(attachment)"
                   class="btn btn-secondary btn-sm hover-visible"
                   target="_blank"
                   href="{{:: getUrl(clazz, attachmentable, attachment) }}">View</a>
                <div ng-if=":: attachment.length > 0" class="size">{{:: attachment.length | filesize }}</div>
                <a ng-if=":: authorizedAttachment('delete', attachment)"
                   class="attachment-action attachment-remove-grey hover-visible"
                   ng-click="confirmDelete({ callback: deleteAttachment, args: [attachment, attachmentable] })"
                   href></a>
            </div>
        </div>
    </div>
</div>
<div ng-repeat="file in $flow.files | flowFilesNotCompleted">
    <hr ng-class="{'mt-0':!attachmentable.attachments}">
    <div class="attachment media d-flex align-content-stretch flex-wrap" ng-class="{'mb-3':$last}">
        <div class="media-body flex-grow-1 attachment-type {{:: attachment.ext | fileicon }}">
            <div class="d-flex uploading" ng-class="{'paused':file.paused}">
                <span class="flex-grow-1">{{:: file.name }}</span>
                <div class="size" ng-if="file.isUploading() || file.paused">{{file.sizeUploaded() / file.size * 100 | number:0}}%</div>
                <div class="progress" ng-if="file.isUploading() || file.paused">
                    <div class="progress-bar" role="progressbar" ng-style="{width: (file.sizeUploaded() / file.size * 100) + '%'}"></div>
                </div>
                <a ng-if="!file.paused && file.isUploading()"
                   class="attachment-action attachment-pause-grey"
                   ng-click="file.pause()"
                   href></a>
                <a ng-if="file.paused"
                   class="attachment-action attachment-resume-grey"
                   ng-click="file.resume()"
                   href></a>
                <a ng-if="!file.isComplete()"
                   class="attachment-action attachment-stop-grey"
                   ng-click="file.cancel()"
                   href></a>
                <a ng-if="file.error"
                   class="attachment-action attachment-retry-grey"
                   ng-click="file.retry()"
                   href></a>
                <a ng-if=":: authorizedAttachment('delete', attachment)"
                   class="attachment-action attachment-remove-grey hidden"></a>
            </div>
        </div>
    </div>
</div>
<div ng-if="attachmentable.attachments.length > 10 && !pref.showMore['attachments']" class="text-center">
    <span ng-click="showMore('attachments')" class="toggle-more">See more</span>
</div>
</script>


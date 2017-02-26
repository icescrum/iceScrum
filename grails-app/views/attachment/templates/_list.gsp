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
<div class="drop-zone">
    <h2>${message(code: 'todo.is.ui.drop.here')}</h2>
</div>
<table class="table table-striped attachments">
    <tbody>
        <tr ng-repeat="attachment in attachmentable.attachments">
            <td>
                <div class="col-sm-8 col-xs-8">
                    <div class="filename" title="{{ attachment.filename }}"><i class="fa fa-{{ attachment.ext | fileicon }}"></i> <a target="{{ attachment.provider ? '_blank' : '' }}" ng-show="!isPreviewable(attachment)" href="{{ getUrl(clazz, attachmentable, attachment) }}">{{ attachment.filename }}</a><a ng-show="isPreviewable(attachment)" href ng-click="showPreview(attachment, attachmentable, clazz)">{{ attachment.filename }}</a></div>
                    <div><small ng-if="attachment.length > 0">{{ attachment.length | filesize }}</small> <small>{{ attachment.provider ? '('+attachment.provider+')' : '' }}</small></div>
                </div>
                <div class="col-sm-4 col-xs-4 text-right">
                    <div class="btn-group">
                        <a href="{{ getUrl(clazz, attachmentable, attachment) }}"
                           target="{{ attachment.provider ? '_blank' : '' }}"
                           uib-tooltip="${message(code: 'todo.is.ui.attachment.download')}"
                           class="btn btn-default btn-xs"><i class="fa fa-{{ attachment.provider ? 'external-link' : 'download' }}"></i></a>
                        <button ng-click="showPreview(attachment, attachmentable, clazz)" type="button"
                                class="btn btn-xs btn-default ng-hide" ng-show="isPreviewable(attachment)"
                                uib-tooltip="${message(code: 'todo.is.ui.attachment.preview')}">
                            <i class="fa fa-search"></i>
                        </button>
                        <button ng-if="authorizedAttachment('delete', attachment)"
                                ng-click="confirm({ message: '${message(code: 'is.confirm.delete')}', callback: deleteAttachment, args: [attachment, attachmentable] })"
                                uib-tooltip="${message(code: 'default.button.delete.label')}"
                                type="button" class="btn btn-danger btn-xs">
                            <i class="fa fa-close"></i>
                        </button>
                    </div>
                </div>
                <div ng-show="attachment.showPreview" class="col-sm-12 ng-hide" ng-if="isPreviewable(attachment) == 'picture'">
                    <a href="attachment/{{ clazz }}/{{ attachmentable.id }}/{{ attachment.id }}">
                        <img ng-src="attachment/{{ clazz }}/{{ attachmentable.id }}/{{ attachment.id }}" width="100%"/>
                    </a>
                </div>
                <div ng-show="attachment.showPreview" class="col-sm-12 ng-hide" ng-if="isPreviewable(attachment) == 'video'">
                    <a href="attachment/{{ clazz }}/{{ attachmentable.id }}/{{ attachment.id }}">
                        <img ng-src="attachment/{{ clazz }}/{{ attachmentable.id }}/{{ attachment.id }}" width="100%"/>
                    </a>
                </div>
            </td>
        </tr>
        <tr ng-repeat="file in $flow.files | flowFilesNotCompleted">
            <td>
                <div class="col-sm-8">
                    <div class="filename" title="{{file.name}}"><i class="fa fa-{{ file.name | fileicon }}"></i> {{ file.name }}</div>
                    <div><small>{{ file.size | filesize }}</small></div>
                </div>
                <div class="col-sm-4 text-right">
                    <div class="progress ng-hide" ng-show="!file.paused && file.isUploading()">
                        <div class="progress-bar" role="progressbar" ng-style="{width: (file.sizeUploaded() / file.size * 100) + '%'}">
                            {{file.sizeUploaded() / file.size * 100 | number:0}}%
                        </div>
                    </div>
                    <div class="btn-group">
                        <button class="btn btn-xs btn-warning ng-hide" uib-tooltip="${message(code: 'todo.is.ui.attachment.pause')}" type="button" ng-click="file.pause()"  ng-show="!file.paused && file.isUploading()"><i class="fa fa-pause"></i></button>
                        <button class="btn btn-xs btn-warning ng-hide" uib-tooltip="${message(code: 'todo.is.ui.attachment.resume')}" type="button" ng-click="file.resume()" ng-show="file.paused"><i class="fa fa-play"></i></button>
                        <button class="btn btn-xs btn-danger ng-hide"  uib-tooltip="${message(code: 'is.button.cancel')}" type="button" ng-click="file.cancel()" ng-show="file.isComplete()"><i class="fa fa-close"></i></button>
                        <button class="btn btn-xs btn-info ng-hide"    uib-tooltip="${message(code: 'todo.is.ui.attachment.retry')}" type="button" ng-click="file.retry()"  ng-show="file.error"><i class="fa fa-refresh"></i></button>
                    </div>
                </div>
            </td>
        </tr>
        <tr ng-show="attachmentable.attachments !== undefined && attachmentable.attachments.length == 0">
            <td class="empty-content">
                <small>${message(code:'todo.is.ui.attachment.empty')}</small>
            </td>
        </tr>
    </tbody>
</table>
</script>
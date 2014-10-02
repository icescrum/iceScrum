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
    <tr ng-show="selected.attachments === undefined">
        <td class="empty-content">
            <i class="fa fa-refresh fa-spin"></i>
        </td>
    </tr>
    <tr ng-repeat="attachment in selected.attachments | orderBy:'dateCreated'">
        <td>
            <div class="col-sm-8">
                <div class="filename" title="{{ attachment.filename }}"><i class="fa fa-{{ attachment.ext | fileicon }}"></i> {{ attachment.filename }}</div>
                <div><small>{{ attachment.length | filesize }}</small></div>
            </div>
            <div class="col-sm-4 text-right">
                <div class="btn-group">
                    <button type="button" class="btn btn-default btn-xs"><i class="fa fa-download"></i></button>
                    <button ng-click="" type="button" class="btn btn-danger btn-xs"><i class="fa fa-close"></i></button>
                </div>
            </div>
        </td>
    </tr>
    <tr ng-repeat="file in $flow.files">
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
                    <button class="btn btn-xs btn-warning ng-hide" ng-click="file.pause()"  ng-show="!file.paused && file.isUploading()"><i class="fa fa-pause"></i></button>
                    <button class="btn btn-xs btn-warning ng-hide" ng-click="file.resume()" ng-show="file.paused"><i class="fa fa-play"></i></button>
                    <button class="btn btn-xs btn-danger"          ng-click="file.cancel()"><i class="fa fa-close"></i></button>
                    <button class="btn btn-xs btn-info ng-hide"    ng-click="file.retry()"  ng-show="file.error"><i class="fa fa-refresh"></i></button>
                </div>
            </div>
        </td>
    </tr>
    <tr ng-show="!selected.attachments && selected.attachments !== undefined">
        <td class="empty-content">
            <small>${message(code:'todo.is.ui.comment.empty')}</small>
        </td>
    </tr>
</script>
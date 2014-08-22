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
- Nicolas Noullet (nnoullet@kagilum.com)
--}%
<script type="text/ng-template" id="comment.list.html">
<tr ng-show="selected.comments === undefined">
    <td class="empty-content">
        <i class="fa fa-refresh fa-spin"></i>
    </td>
</tr>
<tr ng-repeat="comment in selected.comments | orderBy:'dateCreated'" ng-controller="commentCtrl">
    <td>
        <div class="content">
            <div ng-show="!getShowCommentForm()">
                <div class="pull-right">
                    <button class="btn btn-xs btn-primary"
                            type="button"
                            tooltip-placement="left"
                            tooltip="${message(code:'todo.is.ui.comment.edit')}"
                            ng-if="authorizedComment('update', comment)"
                            ng-click="setShowCommentForm(true)"><span class="fa fa-pencil"></span></button>
                    <button class="btn btn-xs btn-danger"
                            type="button"
                            tooltip-placement="left"
                            tooltip="${message(code:'todo.is.ui.comment.delete')}"
                            ng-if="authorizedComment('delete', comment)"
                            ng-click="confirm({ message: '${message(code: 'is.confirm.delete')}', callback: delete, args: [comment, selected] })"><span class="fa fa-times"></span></button>
                </div>
                <img class="inline-block"
                     ng-src="{{comment.poster | userAvatar}}"
                     alt="{{comment.poster | userFullName}}"
                     tooltip="{{comment.poster | userFullName}}"
                     width="25px"/>
                <span class="text-muted">
                    <time timeago datetime="'{{ comment.dateCreated }}'">
                        {{ comment.dateCreated }}
                    </time> <i class="fa fa-clock-o"></i> <span ng-show="comment.dateCreated != comment.lastUpdated">(${message(code:'todo.is.ui.commnent.edited')})</span>
                </span>
                <div class="pretty-printed"
                     ng-bind-html="comment.body | lineReturns | sanitize">
                </div>
            </div>
            <div ng-include="'comment.editor.html'" ng-show="getShowCommentForm()" ng-init="formType='update'"></div>
        </div>
    </td>
</tr>
<tr ng-show="!selected.comments && selected.comments !== undefined">
    <td class="empty-content">
        <small>${message(code:'todo.is.ui.comment.empty')}</small>
    </td>
</tr>
</script>
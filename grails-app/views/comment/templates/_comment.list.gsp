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
<tr ng-repeat="readOnlyComment in selected.comments | orderBy:'dateCreated'" ng-controller="commentCtrl">
    <td>
        <div class="content">
            <div ng-show="!getShowForm()">
                <div class="pull-right">
                    <button class="btn btn-xs btn-primary"
                            type="button"
                            tooltip-placement="left"
                            tooltip="${message(code:'todo.is.ui.comment.edit')}"
                            ng-if="!readOnly()"
                            ng-click="setShowForm(true)"><span class="fa fa-pencil"></span></button>
                    <button class="btn btn-xs btn-danger"
                            type="button"
                            tooltip-placement="left"
                            tooltip="${message(code:'todo.is.ui.comment.delete')}"
                            ng-if="deletable()"
                            ng-click="confirm('${message(code: 'is.confirm.delete')}', delete, [readOnlyComment, selected])"><span class="fa fa-times"></span></button>
                </div>
                <img class="inline-block"
                     ng-src="{{readOnlyComment.poster | userAvatar}}"
                     alt="{{readOnlyComment.poster | userFullName}}"
                     tooltip="{{readOnlyComment.poster | userFullName}}"
                     width="25px"/>
                <span class="text-muted">
                    <time class='timeago' datetime='{{ readOnlyComment.dateCreated }}'>
                        {{ readOnlyComment.dateCreated }}
                    </time> <span ng-show="readOnlyComment.dateCreated != readOnlyComment.lastUpdated">${message(code:'todo.is.ui.commnent.edited')}</span> <i class="fa fa-clock-o"></i>
                </span>
                <div class="pretty-printed"
                     ng-bind-html="readOnlyComment.body | lineReturns | sanitize">
                </div>
            </div>
            <div ng-include="'comment.editor.html'" ng-show="getShowForm()" ng-init="formType='update'"></div>
        </div>
    </td>
</tr>
<tr ng-show="!selected.comments && selected.comments !== undefined">
    <td class="empty-content">
        <small>${message(code:'todo.is.ui.comment.empty')}</small>
    </td>
</tr>
</script>
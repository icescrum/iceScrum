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
<tr ng-show="getSelected().comments === undefined">
    <td class="empty-content">
        <i class="fa fa-refresh fa-spin"></i>
    </td>
</tr>
<tr ng-repeat="comment in getSelected().comments | orderBy:'dateCreated'" ng-controller="commentCtrl">
    <td>
        <div class="content">
            <form name="formHolder.commentForm"
                  ng-mouseleave="formHover(false)"
                  ng-mouseover="formHover(true)"
                  class="form-editable"
                  ng-class="{ 'form-editing': (formHolder.editing || formHolder.formHover) && authorizedComment('update', editableComment) }"
                  show-validation
                  novalidate>
                <div ng-switch="(formHolder.editing || formHolder.formHover) && authorizedComment('delete', editableComment)"
                      class="form-group" >
                    <img class="comment-avatar"
                         ng-switch-default
                         ng-src="{{comment.poster | userAvatar}}"
                         alt="{{comment.poster | userFullName}}"/>
                    <button ng-switch-when="true"
                            class="btn btn-danger"
                            ng-click="confirm({ message: '${message(code: 'is.confirm.delete')}', callback: delete, args: [editableComment, story] })"
                            tooltip-placement="left"
                            tooltip-append-to-body="true"
                            tooltip="${message(code:'todo.is.ui.comment.delete')}"><span class="fa fa-times"></span>
                    </button>
                    <span>{{comment.poster | userFullName}}</span>
                    <span class="text-muted">
                        <time timeago datetime="'{{ comment.dateCreated }}'">
                            {{ comment.dateCreated }}
                        </time> <i class="fa fa-clock-o"></i> <span ng-show="comment.dateCreated != comment.lastUpdated">(${message(code:'todo.is.ui.comment.edited')})</span>
                    </span>
                </div>
                <div class="form-group">
                    <textarea required
                              msd-elastic
                              ng-maxlength="5000"
                              ng-blur="update(editableComment, getSelected()); showCommentBodyTextarea = false;"
                              is-markitup
                              name="body"
                              ng-model="editableComment.body"
                              is-model-html="editableComment.body_html"
                              ng-show="showCommentBodyTextarea"
                              class="form-control"></textarea>
                    <div class="markitup-preview"
                         ng-show="!showCommentBodyTextarea"
                         ng-click="editForm(true); showCommentBodyTextarea = true"
                         ng-focus="editForm(true); showCommentBodyTextarea = true"
                         tabindex="0"
                         ng-bind-html="editableComment.body_html | sanitize"></div>
                </div>
            </form>
        </div>
    </td>
</tr>
<tr ng-show="getSelected().comments !== undefined && getSelected().comments.length == 0">
    <td class="empty-content">
        <small>${message(code:'todo.is.ui.comment.empty')}</small>
    </td>
</tr>
</script>
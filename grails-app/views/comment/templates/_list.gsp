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
<div class="comments panel-body">
    <table class="table">
        <tr ng-repeat="comment in selected.comments | orderBy:'dateCreated'" ng-controller="commentCtrl">
            <td class="content">
                <form name="formHolder.commentForm"
                      ng-class="{'form-editable': formEditable(), 'form-editing': formHolder.editing }"
                      ng-submit="update(editableComment, selected)"
                      show-validation
                      novalidate>
                    <div class="clearfix no-padding">
                        <div class="col-sm-1">
                            <img height="30px"
                                 class="{{ comment.poster | userColorRoles }}"
                                 ng-src="{{comment.poster | userAvatar}}"
                                 alt="{{comment.poster | userFullName}}"/>
                        </div>
                        <div class="form-half">
                            <span class="poster form-control-static">{{comment.poster | userFullName}}</span>
                        </div>
                        <div class="col-sm-5 form-group text-right">
                            <span class="dateCreated text-muted">
                                <time timeago datetime="{{ comment.dateCreated }}">
                                    {{ comment.dateCreated | dateTime }}
                                </time> <i class="fa fa-clock-o"></i> <span ng-show="comment.dateCreated != comment.lastUpdated">(${message(code: 'todo.is.ui.comment.edited')})</span>&nbsp;
                            </span>
                            <div class="btn-group btn-group-sm" ng-show="formDeletable() || formEditable()" uib-dropdown>
                                <button type="button" class="btn btn-default" uib-dropdown-toggle>
                                    <i class="fa fa-ellipsis-h"></i> <i class="fa fa-caret-down"></i>
                                </button>
                                <ul uib-dropdown-menu class="pull-right">
                                    <li>
                                        <a href ng-click="confirmDelete({ callback: delete, args: [editableComment, selected] })">
                                            ${message(code: 'default.button.delete.label')}
                                        </a>
                                    </li>
                                </ul>
                            </div>
                        </div>
                    </div>
                    <div class="form-group">
                        <textarea at
                                  required
                                  ng-maxlength="5000"
                                  ng-blur="delayCall(blurComment)"
                                  is-markitup
                                  name="body"
                                  ng-model="editableComment.body"
                                  is-model-html="editableComment.body_html"
                                  ng-show="showCommentBodyTextarea"
                                  class="form-control"></textarea>
                        <div class="markitup-preview no-fixed-height"
                             ng-show="!showCommentBodyTextarea"
                             ng-click="editCommentBody()"
                             ng-focus="editCommentBody()"
                             tabindex="0"
                             ng-bind-html="editableComment.body_html"></div>
                    </div>
                    <div class="btn-toolbar"
                         ng-if="formHolder.editing">
                        <button class="btn btn-primary pull-right"
                                ng-disabled="!formHolder.commentForm.$dirty || formHolder.commentForm.$invalid || application.submitting"
                                ng-click="update(editableComment, selected)"
                                type="submit">
                            ${message(code: 'default.button.update.label')}
                        </button>
                        <button class="btn btn-default pull-right"
                                ng-click="resetCommentForm()"
                                type="button">
                            ${message(code: 'is.button.cancel')}
                        </button>
                    </div>
                </form>
                <hr ng-if="!$last"/>
            </td>
        </tr>
        <tr ng-show="selected.comments !== undefined && selected.comments.length == 0">
            <td class="empty-content">
                <small>${message(code: 'todo.is.ui.comment.empty')}</small>
            </td>
        </tr>
    </table>
</div>
<div class="panel-footer" ng-controller="commentCtrl">
    <div ng-include="'comment.editor.html'"></div>
</div>
</script>

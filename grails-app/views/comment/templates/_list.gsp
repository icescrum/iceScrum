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
<div class="card-body font-size-sm comments">
    <div ng-repeat="comment in selected.comments | orderBy:'dateCreated'" ng-controller="commentCtrl">
        <form name="formHolder.commentForm"
              ng-class="{'form-editable': formEditable(), 'form-editing': formHolder.editing }"
              ng-submit="update(editableComment, selected)"
              show-validation
              novalidate>
            <div class="row align-items-center mb-2">
                <div class="col-1 d-flex">
                    <div class="avatar {{ comment.poster | userColorRoles }}">
                        <img width="30"
                             height="30"
                             ng-src="{{comment.poster | userAvatar}}"
                             alt="{{comment.poster | userFullName}}"/>
                    </div>
                </div>
                <div class="col-6">
                    <span class="form-control-plaintext">{{comment.poster | userFullName}}</span>
                </div>
                <div class="col-4 text-right">
                    <span class="time-stamp">
                        <time timeago datetime="{{ comment.dateCreated }}">
                            {{ comment.dateCreated | dateTime }}
                        </time>
                        <span ng-show="comment.dateCreated != comment.lastUpdated">(${message(code: 'todo.is.ui.comment.edited')})</span>&nbsp;
                    </span>
                </div>
                <div class="col-1">
                    <div class="btn-group" ng-show="formDeletable() || formEditable()" uib-dropdown>
                        <button type="button" class="btn btn-link btn-sm" uib-dropdown-toggle></button>
                        <div uib-dropdown-menu ng-init="itemType = 'comment'" template-url="item.menu.html"></div>
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
                <div class="markitup-preview form-control no-fixed-height"
                     ng-show="!showCommentBodyTextarea"
                     ng-focus="editCommentBody()"
                     tabindex="0"
                     bind-html-scope="markitupCheckboxOptions()"
                     bind-html-compile="editableComment.body_html"></div>
            </div>
            <div class="btn-toolbar justify-content-end mb-3"
                 ng-if="formHolder.editing">
                <button class="btn btn-secondary btn-sm"
                        ng-click="resetCommentForm()"
                        type="button">
                    ${message(code: 'is.button.cancel')}
                </button>
                <button class="btn btn-primary btn-sm"
                        ng-disabled="!formHolder.commentForm.$dirty || formHolder.commentForm.$invalid || application.submitting"
                        ng-click="update(editableComment, selected)"
                        type="submit">
                    ${message(code: 'default.button.update.label')}
                </button>
            </div>
        </form>
        <hr ng-if="!$last" class="w-50 mt-2"/>
    </div>
    <div ng-show="selected.comments_count === 0"
         class="empty-content">
        <div class="form-text">
            ${message(code: 'todo.is.ui.comment.empty')}
        </div>
    </div>
</div>
<div ng-controller="meetingCtrl"
     ng-if="providers && workspaceType != workspaceTypes.PORTFOLIO"
     class="meetings-container"
     ng-init="subject = selected">
    <div ng-if="::providers && authorizedMeeting('create')"
         class="align-items-center d-flex"
         ng-class="hasMeetings() ? 'justify-content-end' : 'justify-content-between'">
        <div class="font-size-sm" ng-if="!hasMeetings()">
            <b>${message(code: 'is.ui.collaboration.start')}</b>
        </div>
        <div ng-class="{'meetings-provider-sm': hasMeetings()}">
            <div class="text-truncate" ng-if="::!providers || providers.length == 0" ng-click="showAppsModal(message('is.ui.apps.tag.collaboration'), true)">
                {{:: providersPromoteList() | randomPromote }}
            </div>
            <div class="d-flex justify-content-end">
                <div ng-if="!creating">
                    <a href
                       ng-repeat="provider in getFilteredProviders()"
                       ng-click="createMeeting(subject, provider)"
                       ng-class="hasMeetings() ? 'ml-1' : 'ml-2'"
                       class="meeting-provider-container ml-2">
                        <span class="meeting-provider meeting-provider-{{:: provider.id }}" title="{{:: provider.name }}"></span>
                    </a>
                </div>
                <div class="loading-dot dot-elastic align-middle align-self-center mr-4" ng-if="creating"></div>
                <a ng-if="::providers && providers.length != 0"
                   class="btn btn-secondary btn-sm plus-app"
                   ng-click="showAppsModal(message('is.ui.apps.tag.collaboration'), true)"
                   href></a>
            </div>
        </div>
    </div>
    <div ng-include="'meetings.html'"></div>
</div>
<div class="card-footer" ng-controller="commentCtrl">
    <div ng-include="'comment.editor.html'"></div>
</div>
</script>

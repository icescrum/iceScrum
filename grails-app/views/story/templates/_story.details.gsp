<%@ page import="org.icescrum.core.utils.BundleUtils" %>
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
<script type="text/ng-template" id="story.details.html">
<div class="panel panel-default">
    <div id="story-header"
         class="panel-heading"
         fixed="#right"
         fixed-offset-top="1"
         fixed-offset-width="-2">
        <h3 class="panel-title row">
            <div class="col-sm-8">
                <a href
                   tooltip="{{ story.followers_count }} ${message(code: 'todo.is.ui.followers')}"
                   tooltip-append-to-body="true"
                   ng-click="follow(story)"
                   ng-switch="story.followed"><i class="fa fa-star-o" ng-switch-default></i><i class="fa fa-star" ng-switch-when="true"></i></a>
                <span>{{ story.name }}</span> <small ng-show="story.origin">${message(code: 'is.story.origin')}: {{ story.origin }}</small>
            </div>
            <div class="col-sm-4">
                <div class="pull-right">
                    <span tooltip="${message(code: 'is.story.creator')} : {{ story.creator | userFullName }}">
                        <img ng-src="{{ story.creator | userAvatar }}" alt="{{ story.creator | userFullName }}"
                             height="21px"/>
                    </span>
                    <span class="label label-default"
                          tooltip="${message(code: 'is.backlogelement.id')}">{{ story.uid }}</span>

                    <a ng-if="previous"
                       class="btn btn-xs btn-default"
                       role="button"
                       tabindex="0"
                       href="#sandbox/{{ previous.id }}"><i class="fa fa-caret-left" title="${message(code:'is.ui.backlogelement.toolbar.previous')}"></i></a>
                    <a ng-if="next"
                       class="btn btn-xs btn-default"
                       role="button"
                       tabindex="0"
                       href="#sandbox/{{ next.id }}"><i class="fa fa-caret-right" title="${message(code:'is.ui.backlogelement.toolbar.next')}"></i></a>
                </div>
            </div>
        </h3>
        <div class="actions">
            <div class="btn-group"
                 ng-if="authorizedStory('menu', story)"
                 tooltip="${message(code: 'todo.is.ui.actions')}"
                 tooltip-append-to-body="true">
                <button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown">
                    <span class="fa fa-cog"></span> <span class="caret"></span>
                </button>
                <ul class="dropdown-menu"
                    ng-include="'story.menu.html'"></ul>
            </div>
            <button type="button"
                    popover-title="${message(code:'is.permalink')}"
                    popover="{{ serverUrl + '/TODOPKEY-' + story.uid }}"
                    popover-append-to-body="true"
                    popover-placement="left"
                    class="btn btn-default">
                <span class="fa fa-link"></span>
            </button>
            <button class="btn btn-default"
                    type="button"
                    ng-click="like(story)"
                    ng-switch="story.liked"
                    role="button"
                    tabindex="0"
                    tooltip="{{ story.likers_count }} ${message(code: 'todo.is.ui.likers')}"
                    tooltip-append-to-body="true">
                <i class="fa fa-thumbs-o-up" ng-switch-default></i>
                <i class="fa fa-thumbs-up" ng-switch-when="true"></i>
                <span class="badge" ng-show="story.likers_count">{{ story.likers_count }}</span>
            </button>
            <button class="btn btn-primary"
                    type="button"
                    tooltip="${message(code:'todo.is.ui.editable.enable')}"
                    ng-if="authorizedStory('update', story) && !getEditableMode(story)"
                    ng-click="enableEditableStoryMode()"><span class="fa fa-pencil"></span></button>
            <button class="btn btn-default"
                    type="button"
                    tooltip="${message(code:'todo.is.ui.editable.disable')}"
                    ng-if="getEditableStoryMode(story)"
                    ng-click="confirm({ message: '${message(code: 'todo.is.ui.dirty.confirm')}', callback: disableEditableStoryMode, condition: isDirty() })"><span class="fa fa-pencil-square-o"></span></button>
            <div class="btn-group pull-right">
                <button name="activities"
                        class="btn btn-default"
                        type="button"
                        ng-click="setTabSelected('activities')"
                        tooltip="${message(code:'todo.is.story.lastActivity')}"
                        tooltip-append-to-body="true">
                    <span class="fa fa-clock-o"></span>
                </button>
                <button name="attachments"
                        class="btn btn-default"
                        type="button"
                        ng-click="setTabSelected('attachments')"
                        tooltip="{{ story.attachments.length }} ${message(code:'todo.is.backlogelement.attachments')}"
                        tooltip-append-to-body="true">
                    <span class="fa fa-paperclip"></span>
                    <span class="badge" ng-show="story.attachments_count">{{ story.attachments_count }}</span>
                </button>
                <button name="comments"
                        class="btn btn-default"
                        type="button"
                        ng-click="setTabSelected('comments')"
                        tooltip="{{ story.comments.length }} ${message(code:'todo.is.story.comments')}"
                        tooltip-append-to-body="true"
                        ng-switch="story.comments_count">
                    <span class="fa fa-comment-o" ng-switch-when="0"></span>
                    <span class="fa fa-comment" ng-switch-default></span>
                    <span class="badge" ng-show="story.comments_count">{{ story.comments_count }}</span>
                </button>
                <button name="tasks"
                        class="btn btn-default"
                        type="button"
                        ng-click="setTabSelected('tasks')"
                        tooltip="{{ story.tasks_count }} ${message(code:'todo.is.story.tasks')}"
                        tooltip-append-to-body="true">
                    <span class="fa fa-tasks"></span>
                    <span class="badge" ng-show="story.tasks_count">{{ story.tasks_count }}</span>
                </button>
                <button name="tests"
                        class="btn btn-default"
                        type="button"
                        ng-click="setTabSelected('tests')"
                        tooltip="{{ story.acceptanceTests_count }} ${message(code:'todo.is.acceptanceTests')}"
                        tooltip-append-to-body="true"
                        tooltip-placement="left"
                        ng-switch="story.acceptanceTests_count">
                    <span class="fa fa-check-square-o" ng-switch-when="0"></span>
                    <span class="fa fa-check-square" ng-switch-default></span>
                    <span class="badge" ng-if="story.acceptanceTests_count">{{ story.acceptanceTests_count }}</span>
                </button>
            </div>
        </div>
        <div class="progress">
            <div ng-repeat="progressState in progressStates"
                 class="progress-bar progress-bar-{{ progressState.code }}"
                 tooltip-placement="left"
                 tooltip-append-to-body="true"
                 tooltip="{{ progressState.name }}" style="width:{{ progressState.width }}%">
                {{ progressState.days }}
            </div>
        </div>
    </div>

    <div id="right-story-container"
         class="panel-body">
        <form ng-submit="update(editableStory)"
              name='formHolder.storyForm'
              ng-class="{'form-disabled': !getEditableStoryMode(story)}"
              show-validation
              novalidate>
            <div class="clearfix no-padding">
                <div class="col-md-6 form-group">
                    <label for="story.name">${message(code:'is.story.name')}</label>
                    <input required
                           ng-maxlength="100"
                           ng-disabled="!getEditableStoryMode(story)"
                           name="editableStory.name"
                           ng-model="editableStory.name"
                           type="text"
                           class="form-control">
                </div>
                <div class="col-md-6 form-group" ng-switch="getEditableStoryMode(story) || !editableStory.feature">
                    <label for="story.feature.id">${message(code:'is.feature')}</label>
                    <div ng-switch-when="true"
                         ng-class="{'input-group':editableStory.feature.id, 'select2-border':editableStory.feature.id}">
                        <input type="hidden"
                               ng-disabled="!getEditableStoryMode(story)"
                               class="form-control"
                               value="{{ editableStory.feature.id ? editableStory.feature : '' }}"
                               ng-model="editableStory.feature"
                               ui-select2="selectFeatureOptions"
                               data-placeholder="${message(code: 'is.ui.story.nofeature')}"/>
                        <span class="input-group-btn" ng-show="editableStory.feature.id">
                            <a href="#feature/{{ editableStory.feature.id }}"
                               title="{{ editableStory.feature.name }}"
                               class="btn btn-default">
                                <i class="fa fa-external-link"></i>
                            </a>
                        </span>
                    </div>
                    <a ng-switch-default href="#feature/{{ editableStory.feature.id }}">
                        <input type="text"
                               class="form-control"
                               value="{{ editableStory.feature.name }}"
                               disabled="disabled"/>
                    </a>
                </div>
            </div>
            <div class="clearfix no-padding">
                <div class="form-group"
                     ng-class="{ 'col-md-6' : editableStory.type == 2 }">
                    <label for="story.type">${message(code:'is.story.type')}</label>
                    <select class="form-control"
                            ng-disabled="!getEditableStoryMode(story)"
                            ng-model="editableStory.type"
                            ui-select2>
                        <is:options values="${is.internationalizeValues(map: BundleUtils.storyTypes)}" />
                </select>
                </div>
                <div class="form-group col-md-6"
                     ng-show="editableStory.type == 2">
                    <label for="story.affectVersion">${message(code:'is.story.affectVersion')}</label>
                    <input class="form-control"
                           ng-disabled="!getEditableStoryMode(story)"
                           type="hidden"
                           value="{{ editableStory.affectVersion  }}"
                           ng-model="editableStory.affectVersion"
                           ui-select2="selectAffectionVersionOptions"
                           data-placeholder="${message(code:'is.ui.story.noaffectversion')}"/>
                </div>
            </div>
            <div class="form-group">
                <label for="story.dependsOn.id">${message(code:'is.story.dependsOn')}</label>
                <div ng-class="{'input-group':editableStory.dependsOn.id}">
                    <input  type="hidden"
                            ng-disabled="!getEditableStoryMode(story)"
                            style="width:100%;"
                            class="form-control"
                            value="{{ editableStory.dependsOn.id ? editableStory.dependsOn : '' }}"
                            ng-model="editableStory.dependsOn"
                            ui-select2="selectDependsOnOptions"
                            data-placeholder="${message(code: 'is.ui.story.nodependence')}"/>
                    <span class="input-group-btn" ng-show="editableStory.dependsOn.id">
                        <a href="#story/{{ editableStory.dependsOn.id }}"
                           title="{{ editableStory.dependsOn.name }}"
                           class="btn btn-default">
                            <i class="fa fa-external-link"></i>
                        </a>
                    </span>
                </div>
                <div class="clearfix" style="margin-top: 15px;" ng-if="editableStory.dependences.length">
                    <strong>${message(code:'is.story.dependences')} :</strong>
                    <a class="scrum-link" title="{{ dependence.name }}" ng-repeat="dependence in editableStory.dependences">{{ dependence.name }}</a>
                </div>
            </div>
            <div class="form-group">
                <label for="story.description">${message(code:'is.backlogelement.description')}</label>
                <textarea class="form-control"
                          ng-maxlength="3000"
                          ng-model="editableStory.description"
                          ng-show="showDescriptionTextarea"
                          ng-blur="showDescriptionTextarea = false"
                          focus-me="{{ showDescriptionTextarea }}"
                          data-at
                          data-at-at="a"
                          data-at-matcher="$.icescrum.story.formatters.description"
                          data-at-default="${is.generateStoryTemplate(newLine: '\\n')}"
                          placeholder="${message(code: 'is.ui.backlogelement.nodescription')}"
                          data-at-change="${updateUrl}"
                          data-at-tpl="<li data-value='A[<%='${uid}'%>-<%='${name}'%>]'><%='${name}'%></li>"
                          data-at-data="${g.createLink(controller:'actor', action: 'search', params:[product:'** jQuery.icescrum.product.pkey **'], absolute: true)}"></textarea>
                <div class="atwho-preview form-control-static"
                     ng-disabled="!getEditableStoryMode(story)"
                     ng-show="!showDescriptionTextarea"
                     ng-click="showDescriptionTextarea = getEditableStoryMode(story)"
                     ng-focus="showDescriptionTextarea = getEditableStoryMode(story)"
                     ng-class="{'placeholder': !editableStory.description}"
                     tabindex="0"
                     ng-bind-html="(editableStory.description ? (editableStory | descriptionHtml) : '${message(code: 'is.ui.backlogelement.nodescription')}') | sanitize"></div>
            </div>
            <div class="form-group">
                <label for="story.tags">${message(code:'is.backlogelement.tags')}</label>
                <input type="hidden"
                       ng-disabled="!getEditableStoryMode(story)"
                       class="form-control"
                       value="{{ editableStory.tags.join(',') }}"
                       ng-model="editableStory.tags"
                       data-placeholder="${message(code:'is.ui.backlogelement.notags')}"
                       ui-select2="selectTagsOptions"/>
            </div>
            <div class="form-group">
                <label for="story.notes">${message(code:'is.backlogelement.notes')}</label>
                <textarea is-markitup
                          ng-maxlength="5000"
                          class="form-control"
                          ng-model="editableStory.notes"
                          is-model-html="editableStory.notes_html"
                          ng-show="showNotesTextarea"
                          ng-blur="showNotesTextarea = false"
                          placeholder="${message(code: 'is.ui.backlogelement.nonotes')}"></textarea>
                <div class="markitup-preview"
                     ng-disabled="!getEditableStoryMode(story)"
                     ng-show="!showNotesTextarea"
                     ng-click="showNotesTextarea = getEditableStoryMode(story)"
                     ng-focus="showNotesTextarea = getEditableStoryMode(story)"
                     ng-class="{'placeholder': !editableStory.notes_html}"
                     tabindex="0"
                     ng-bind-html="(editableStory.notes_html ? editableStory.notes_html : '<p>${message(code: 'is.ui.backlogelement.nonotes')}</p>') | sanitize"></div>
            </div>
            <div class="btn-toolbar" ng-if="getEditableStoryMode(story)">
                <button class="btn btn-primary pull-right"
                        ng-class="{ disabled: !isDirty() || formHolder.storyForm.$invalid }"
                        tooltip="${message(code:'todo.is.ui.update')} (RETURN)"
                        tooltip-append-to-body="true"
                        type="submit">
                    ${message(code:'todo.is.ui.update')}
                </button>
                <button class="btn confirmation btn-default pull-right"
                        ng-class="{ disabled: !isDirty() }"
                        tooltip-append-to-body="true"
                        tooltip="${message(code:'is.button.cancel')}"
                        type="button"
                        ng-click="resetStoryForm()">
                    ${message(code:'is.button.cancel')}
                </button>
            </div>
        </form>

    <tabset type="{{ tabsType }}">
            <tab select="activities(story); ($state.params.tabId ? setTabSelected('activities') : '');"
                 heading="${message(code: 'is.ui.backlogelement.activity')}"
                 active="tabSelected.activities">
                <table class="table table-striped">
                    <tbody ng-include="'activity.list.html'" ng-init="selected = story"></tbody>
                </table>
            </tab>
            <tab select="setTabSelected('attachments');"
                 heading="${message(code: 'is.ui.backlogelement.attachment')}"
                 active="tabSelected.attachments">
            </tab>
            <tab select="comments(story); setTabSelected('comments');"
                 heading="${message(code: 'is.ui.backlogelement.activity.comments')}"
                 active="tabSelected.comments">
                <table class="table table-striped">
                    <tbody ng-include="'comment.list.html'" ng-init="selected = story"></tbody>
                </table>
                <table class="table" ng-controller="commentCtrl">
                    <tbody>
                    <tr ng-if="authorizedComment('create')">
                        <td ng-switch="getShowCommentForm()">
                            <button ng-switch-default
                                    class="btn btn-sm btn-primary pull-right"
                                    type="button"
                                    ng-click="setShowCommentForm(true)"
                                    tooltip="${message(code:'todo.is.ui.comment.new')}'"
                                    tooltip-append-to-body="body"
                                    tooltip-placement="left">
                                <span class="fa fa-plus"></span>
                            </button>
                            <button ng-switch-when="true"
                                    class="btn btn-sm btn-default pull-right "
                                    type="button"
                                    ng-click="setShowCommentForm(false)"
                                    tooltip="${message(code:'todo.is.ui.hide')}"
                                    tooltip-append-to-body="body"
                                    tooltip-placement="left">
                                <span class="fa fa-minus"></span>
                            </button>
                        </td>
                    </tr>
                    <tr ng-show="getShowCommentForm()">
                        <td><div ng-init="formType='save'" ng-include="'comment.editor.html'"></div></td>
                    </tr>
                    </tbody>
                </table>
            </tab>
            <tab select="tasks(story); setTabSelected('tasks');"
                 heading="${message(code: 'is.ui.backlogelement.activity.task')}"
                 active="tabSelected.tasks">
                <div ng-include="'story.task.new.html'" ng-controller="taskCtrl"></div>
                <table class="table table-striped">
                    <tbody ng-include="'story.tasks.html'"></tbody>
                </table>
            </tab>
            <tab select="acceptanceTests(story); setTabSelected('tests');"
                 heading="${message(code: 'is.ui.backlogelement.activity.test')}"
                 active="tabSelected.tests">
                <table class="table" ng-controller="acceptanceTestCtrl">
                    <tbody>
                    <tr ng-if="authorizedAcceptanceTest('create', editableAcceptanceTest)">
                        <td ng-switch="getShowAcceptanceTestForm()">
                            <button ng-switch-default
                                    class="btn btn-sm btn-primary pull-right"
                                    type="button"
                                    ng-click="setShowAcceptanceTestForm(true)"
                                    tooltip="${message(code:'todo.is.ui.acceptanceTest.new')}'"
                                    tooltip-append-to-body="body"
                                    tooltip-placement="left">
                                <span class="fa fa-plus"></span>
                            </button>
                            <button ng-switch-when="true"
                                    class="btn btn-sm btn-default pull-right "
                                    type="button"
                                    ng-click="setShowAcceptanceTestForm(false)"
                                    tooltip="${message(code:'todo.is.ui.hide')}"
                                    tooltip-append-to-body="body"
                                    tooltip-placement="left">
                                <span class="fa fa-minus"></span>
                            </button>
                        </td>
                    </tr>
                    <tr ng-show="getShowAcceptanceTestForm()">
                        <td><div ng-init="formType='save'" ng-include="'story.acceptanceTest.editor.html'"></div></td>
                    </tr>
                    </tbody>
                </table>
                <table class="table table-striped">
                    <tbody ng-include="'story.acceptanceTests.html'"></tbody>
                </table>
            </tab>
        </tabset>
    </div>
</div>
</script>
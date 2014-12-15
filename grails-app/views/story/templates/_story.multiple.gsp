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
<script type="text/ng-template" id="story.multiple.html">

<div class="panel panel-default">
    <div class="panel-heading">
        <h3 class="panel-title">${message(code: "todo.is.ui.stories")} ({{ stories.length }})</h3>
    </div>
    <div class="panel-body">
        <div class="postits standalone">
            <div class="postit-container stack twisted">
                <div style="{{ (storyPreview.feature ? storyPreview.feature.color : '#f9f157') | createGradientBackground }}"
                     class="postit story {{ (storyPreview.feature ? storyPreview.feature.color : '#f9f157') | contrastColor }}  {{ storyPreview.type | storyType }}">
                    <div class="head">
                        <a class="follow"
                           tooltip="{{ topStory.followers_count }} ${message(code: 'todo.is.ui.followers')}"
                           tooltip-append-to-body="true"
                           ng-switch="topStory.followed"><i class="fa fa-star-o" ng-switch-default></i><i class="fa fa-star" ng-switch-when="true"></i></a>
                        <span class="id">{{ topStory.id }}</span>
                        <span class="value" ng-if="topStory.value">{{ topStory.value }} <i class="fa fa-line-chart"></i></span>
                        <span class="estimation ui-selectable-cancel" ng-if="topStory.state > 1">{{ topStory.effort != undefined ? topStory.effort : '?' }} <i class="fa fa-dollar"></i></span>
                    </div>
                    <div class="content">
                        <h3 class="title"
                            ng-model="topStory.name"
                            ng-bind-html="topStory.name | sanitize"
                            ellipsis></h3>
                        <div class="description"
                             ng-model="topStory.description"
                             ng-bind-html="topStory.description | sanitize"
                             ellipsis></div>
                    </div>
                    <div class="tags">
                        <a ng-repeat="tag in topStory.tags" href><span class="tag">{{ tag }}</span></a>
                    </div>
                    <div class="actions">
                        <span class="action">
                            <a tooltip="${message(code: 'todo.is.ui.actions')}" tooltip-append-to-body="true">
                                <i class="fa fa-cog"></i>
                            </a>
                        </span>
                        <span class="action" ng-class="{'active':topStory.attachments.length}">
                            <a tooltip="{{ topStory.attachments.length }} ${message(code:'todo.is.backlogelement.attachments')}"
                               tooltip-append-to-body="true">
                                <i class="fa fa-paperclip"></i>
                            </a>
                        </span>
                        <span class="action" ng-class="{'active':topStory.comments_count}">
                            <a tooltip="{{ topStory.comments_count }} ${message(code:'todo.is.story.comments')}"
                               tooltip-append-to-body="true"
                               ng-switch="topStory.comments_count">
                                <i class="fa fa-comment-o" ng-switch-when="0"></i>
                                <i class="fa fa-comment" ng-switch-default></i>
                                <span class="badge" ng-show="topStory.comments_count">{{ topStory.comments_count }}</span>
                            </a>
                        </span>
                        <span class="action" ng-class="{'active':topStory.tasks_count}">
                            <a tooltip="{{ topStory.tasks_count }} ${message(code:'todo.is.story.tasks')}"
                               tooltip-append-to-body="true">
                                <i class="fa fa-tasks"></i>
                                <span class="badge" ng-show="topStory.tasks_count">{{ topStory.tasks_count }}</span>
                            </a>
                        </span>
                        <span class="action" ng-class="{'active':topStory.acceptanceTests_count}">
                            <a tooltip="{{ topStory.acceptanceTests_count }} ${message(code:'todo.is.acceptanceTests')}"
                               tooltip-append-to-body="true"
                               ng-switch="topStory.acceptanceTests_count">
                                <i class="fa fa-check-square-o" ng-switch-when="0"></i>
                                <i class="fa fa-check-square" ng-switch-default></i>
                                <span class="badge" ng-if="topStory.acceptanceTests_count">{{ topStory.acceptanceTests_count }}</span>
                            </a>
                        </span>
                    </div>
                    <div class="progress">
                        <span class="status">3/6</span>
                        <div class="progress-bar" style="width:16.666666666666668%">
                        </div>
                    </div>
                    <div class="state">{{ topStory.state | i18n:'storyState' }}</div>
                </div>
            </div>
        </div>
        <form ng-submit="updateMultiple(storyPreview)"
              name='storyForm'
              show-validation
              novalidate>
            <div ng-if="authorizedStories('update', stories)"
                 class="clearfix no-padding">
                <div class="form-half">
                    <label for="feature">${message(code:'is.feature')}</label>
                    <div ng-class="{'input-group':storyPreview.feature.id, 'select2-border':storyPreview.feature.id}">
                        <input type="hidden"
                               class="form-control"
                               name="feature"
                               ng-model="storyPreview.feature"
                               ui-select2="selectFeatureOptions"
                               data-placeholder="${message(code: 'is.ui.story.nofeature')}"/>
                        <span class="input-group-btn" ng-show="storyPreview.feature.id">
                            <a href="#feature/{{ storyPreview.feature.id }}"
                               title="{{ storyPreview.feature.name }}"
                               class="btn btn-default">
                                <i class="fa fa-external-link"></i>
                            </a>
                        </span>
                    </div>
                </div>
                <div class="form-half">
                    <label for="type">${message(code:'is.story.type')}</label>
                    <select class="form-control"
                            required
                            name="type"
                            ng-model="storyPreview.type"
                            data-placeholder="${message(code: 'todo.is.ui.story.type.placeholder')}"
                            ui-select2>
                        <option></option>
                        <is:options values="${is.internationalizeValues(map: BundleUtils.storyTypes)}" />
                    </select>
                </div>
            </div>
            <div class="clearfix no-padding">
                <div class="form-group"
                     ng-class="{ 'form-half' : authorizedStories('updateEstimate', stories) }">
                    <label for="value">${message(code:'is.story.value')}</label>
                    <select class="form-control"
                            name="value"
                            ng-model="storyPreview.value"
                            ng-options="i for i in integerSuite"
                            ui-select2>
                    </select>
                </div>
                <div class="form-half"
                     ng-show="authorizedStories('updateEstimate', stories)"
                     ng-switch="isEffortCustom()">
                    <label for="effort">${message(code:'is.story.effort')}</label>
                    <select ng-switch-default
                            class="form-control"
                            name="effort"
                            ng-model="storyPreview.effort"
                            ng-options="i for i in effortSuite()"
                            ui-select2>
                        <option ng-show="isEffortNullable(topStory)" value="">?</option>
                    </select>
                    <input type="number"
                           ng-switch-when="true"
                           class="form-control"
                           name="effort"
                           ng-model="storyPreview.effort"/>
                </div>
            </div>
            <div ng-if="authorizedStories('update', stories)"
                 class="btn-toolbar">
                <button class="btn btn-primary pull-right"
                        tooltip="${message(code:'todo.is.ui.save')} (RETURN)"
                        tooltip-append-to-body="true"
                        type="submit">
                    ${message(code:'todo.is.ui.save')}
                </button>
                <button class="btn confirmation btn-default pull-right"
                        tooltip-append-to-body="true"
                        tooltip="${message(code:'is.button.cancel')} (ESCAPE)"
                        type="button"
                        ng-click="goToNewStory()">
                    ${message(code:'is.button.cancel')}
                </button>
            </div>
            <hr ng-if="authorizedStories('update', stories)"/>
            <div class="btn-toolbar">
                 <div ng-if="authorizedStories('accept', stories)"
                      class="btn-group"
                      dropdown>
                    <button type="button"
                            class="btn btn-default dropdown-toggle"
                            dropdown-toggle>
                        <g:message code='is.dialog.acceptAs.acceptAs.title'/> <span class="caret"></span>
                    </button>
                    <ul class="dropdown-menu" role="menu">
                        <li>
                            <a href ng-click="acceptMultiple()">
                                <g:message code='is.ui.sandbox.menu.acceptAsStory'/>
                            </a>
                        </li>
                        <li>
                            <a href ng-click="acceptAsMultiple('Feature')">
                                <g:message code='is.ui.sandbox.menu.acceptAsFeature'/>
                            </a>
                        </li>
                        <li>
                            <a href ng-click="acceptAsMultiple('Task')">
                                <g:message code='is.ui.sandbox.menu.acceptAsUrgentTask'/>
                            </a>
                        </li>
                    </ul>
                 </div>
                <div class="btn-group">
                    <button type="button"
                            ng-if="authorizedStories('copy', stories)"
                            class="btn btn-default"
                            ng-click="copyMultiple()">
                        <g:message code='is.ui.releasePlan.menu.story.clone'/>
                    </button>
                    <button type="button"
                            ng-if="authorizedStories('delete', stories)"
                            class="btn btn-default"
                            ng-click="confirm({ message: '${message(code: 'is.confirm.delete')}', callback: deleteMultiple })">
                        <g:message code='is.ui.sandbox.menu.delete'/>
                    </button>
                </div>
                <div ng-if="authorizedStories('follow', stories)"
                     class="btn-group">
                    <button type="button"
                            ng-switch="allFollowed(stories)"
                            class="btn btn-default"
                            ng-click="followMultiple(!allFollowed(stories))">
                        <i class="fa" ng-class="noneFollowed(stories) ? 'fa-star-o' : 'fa-star-half-o'" ng-switch-default tooltip="${message(code: 'is.followable.start')}"></i>
                        <i class="fa fa-star" ng-switch-when="true" tooltip="${message(code: 'is.followable.stop')}"></i>
                    </button>
                </div>
            </div>
        </form>
    </div>
</div>
<div class="panel panel-default">
    <table class="table">
        <tr><td>${message(code: 'is.ui.story.total.effort')}</td><td>{{ sumPoints(stories) }}</td></tr>
        <tr><td>${message(code: 'is.ui.story.total.tasks')}</td><td>{{ sumTasks(stories) }}</td></tr>
        <tr><td>${message(code: 'is.ui.story.total.acceptanceTests')}</td><td>{{ sumAcceptanceTests(stories) }}</td></tr>
    </table>
</div>
</script>
%{--
- Copyright (c) 2015 Kagilum.
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
<div class="panel panel-light">
    <div class="panel-heading">
        <h3 class="panel-title">
            ${message(code: "todo.is.ui.stories")} ({{ stories.length }})
            <a class="pull-right btn btn-default"
               ui-sref="^.^"
               defer-tooltip="${message(code: 'is.ui.window.closeable')}">
                <i class="fa fa-times"></i>
            </a>
        </h3>
    </div>
    <div class="details-no-tab">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-6">
                    <div class="postits standalone">
                        <div class="postit-container stack twisted">
                            <div ng-style="(storyPreview.feature ? storyPreview.feature.color : '#f9f157') | createGradientBackground"
                                 class="postit {{ ((storyPreview.feature ? storyPreview.feature.color : '#f9f157') | contrastColor) + ' ' + (storyPreview.type | storyType) }}">
                                <div class="head">
                                    <div class="head-left">
                                        <span class="id">{{ topStory.uid }}</span>
                                        <a class="follow active"
                                           defer-tooltip="{{ topStory.followers_ids.length }} ${message(code: 'todo.is.ui.followers')}">
                                            <i class="fa" ng-class="topStory | followedByUser:'fa-star':'fa-star-o'"></i>
                                        </a>
                                    </div>
                                    <div class="head-right">
                                        <span class="value" ng-if="topStory.value">{{ topStory.value }}
                                            <i class="fa fa-line-chart"></i>
                                        </span>
                                        <span class="estimation"
                                              ng-if="topStory.state > 1">{{ topStory.effort != undefined ? topStory.effort : '?' }}
                                            <i class="fa fa-dollar"></i>
                                        </span>
                                    </div>
                                </div>
                                <div class="content">
                                    <h3 class="title">{{ topStory.name }}</h3>
                                    <div class="description"
                                         ng-bind-html="topStory.description | lineReturns | actorTag"></div>
                                </div>
                                <div class="footer">
                                    <div class="tags">
                                        <a ng-repeat="tag in topStory.tags"
                                           href="{{ tagContextUrl(tag) }}">
                                            <span class="tag">{{ tag }}</span>
                                        </a>
                                    </div>
                                    <div class="actions">
                                        <span class="action"><a><i class="fa fa-cog"></i> <i class="fa fa-caret-down"></i></a></span>
                                        <span class="action" ng-class="{'active':topStory.attachments_count}">
                                            <a defer-tooltip="${message(code: 'todo.is.ui.backlogelement.attachments')}">
                                                <i class="fa fa-paperclip"></i>
                                            </a>
                                        </span>
                                        <span class="action" ng-class="{'active':topStory.comments_count}">
                                            <a defer-tooltip="${message(code: 'todo.is.ui.comments')}">
                                                <i class="fa"
                                                   ng-class="topStory.comments_count ? 'fa-comment' : 'fa-comment-o'"></i>
                                                <span class="badge">{{ topStory.comments_count || '' }}</span>
                                            </a>
                                        </span>
                                        <span class="action" ng-class="{'active':topStory.tasks_count}">
                                            <a defer-tooltip="${message(code: 'todo.is.ui.tasks')}">
                                                <i class="fa fa-tasks"></i>
                                                <span class="badge">{{ topStory.tasks_count || '' }}</span>
                                            </a>
                                        </span>
                                        <span class="action" ng-class="{'active':topStory.acceptanceTests_count}">
                                            <a defer-tooltip="${message(code: 'todo.is.ui.acceptanceTests')}">
                                                <i class="fa"
                                                   ng-class="topStory.acceptanceTests_count ? 'fa-check-square' : 'fa-check-square-o'"></i>
                                                <span class="badge">{{ topStory.acceptanceTests_count || '' }}</span>
                                            </a>
                                        </span>
                                    </div>
                                </div>
                                <div class="state-progress">
                                    <div class="state">
                                        {{ topStory.state | i18n:'StoryStates' }}
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-6">
                    <div class="btn-toolbar buttons-margin-bottom">
                        <div class="btn-group">
                            <button type="button"
                                    ng-if="authorizedStories('accept', stories)"
                                    class="btn btn-default"
                                    ng-click="acceptToBacklogMultiple()">
                                ${message(code: 'is.ui.backlog.menu.acceptAsStory')}
                            </button>
                            <button type="button"
                                    ng-if="authorizedStories('copy', stories)"
                                    class="btn btn-default"
                                    ng-click="copyMultiple()">
                                ${message(code: 'is.ui.releasePlan.menu.story.clone')}
                            </button>
                            <button type="button"
                                    ng-if="authorizedStories('returnToSandbox', stories)"
                                    class="btn btn-default"
                                    ng-click="returnToSandboxMultiple()">
                                ${message(code: 'is.ui.backlog.menu.returnToSandbox')}
                            </button>
                            <button type="button"
                                    ng-if="authorizedStories('delete', stories)"
                                    class="btn btn-default"
                                    ng-click="confirmDelete({ callback: deleteMultiple })">
                                ${message(code: 'is.ui.backlog.menu.delete')}
                            </button>
                        </div>
                        <entry:point id="story-multiple-toolbar"/>
                        <div ng-if="authorizedStories('follow', stories)"
                             class="btn-group">
                            <button type="button"
                                    ng-switch="allFollowed(stories)"
                                    class="btn btn-default"
                                    ng-click="followMultiple(!allFollowed(stories))">
                                <i class="fa"
                                   ng-class="noneFollowed(stories) ? 'fa-star-o' : 'fa-star-half-o'"
                                   ng-switch-default defer-tooltip="${message(code: 'is.followable.start')}"></i>
                                <i class="fa fa-star"
                                   ng-switch-when="true"
                                   defer-tooltip="${message(code: 'is.followable.stop')}"></i>
                            </button>
                        </div>
                        <div ng-if="authorizedStories('accept', stories)"
                             class="btn-group"
                             uib-dropdown>
                            <button type="button"
                                    class="btn btn-default"
                                    uib-dropdown-toggle>
                                ${message(code: 'is.ui.story.turnInto')} <i class="fa fa-caret-down"></i>
                            </button>
                            <ul uib-dropdown-menu role="menu">
                                <li>
                                    <a href ng-click="confirm({message: message('is.ui.story.turnIntoFeature.confirm.multiple'), callback: turnIntoMultiple, args: ['Feature']})">
                                        ${message(code: 'is.ui.story.turnIntoFeature')}
                                    </a>
                                </li>
                                <li>
                                    <a href ng-click="confirm({message: message('is.ui.story.turnIntoTask.confirm.multiple'), callback: turnIntoMultiple, args: ['Task']})">
                                        ${message(code: 'is.ui.story.turnIntoTask')}
                                    </a>
                                </li>
                            </ul>
                        </div>
                    </div>
                    <br>
                    <div ng-include="'story.table.multiple.sum.html'"></div>
                </div>
            </div>
            <form ng-submit="updateMultiple(storyPreview)"
                  ng-if="authorizedStories('update', stories)"
                  name='storyForm'
                  show-validation
                  novalidate>
                <div class="form-group">
                    <label for="feature">${message(code: 'is.feature')}</label>
                    <div ng-class="{'input-group':storyPreview.feature.id}">
                        <ui-select class="form-control"
                                   input-group-fix-width="38"
                                   name="feature"
                                   search-enabled="true"
                                   ng-model="storyPreview.feature">
                            <ui-select-match allow-clear="true" placeholder="${message(code: 'is.ui.story.nofeature')}">
                                <i class="fa fa-sticky-note"
                                   ng-style="{color: $select.selected.color}"></i> {{ $select.selected.name }}
                            </ui-select-match>
                            <ui-select-choices repeat="feature in features | orFilter: { name: $select.search, uid: $select.search }">
                                <i class="fa fa-sticky-note" ng-style="{color: feature.color}"></i> <span ng-bind-html="feature.name | highlight: $select.search"></span>
                            </ui-select-choices>
                        </ui-select>
                        <span class="input-group-btn" ng-if="storyPreview.feature.id">
                            <a ui-sref=".feature.details({featureId: storyPreview.feature.id})"
                               class="btn btn-default">
                                <i class="fa fa-info-circle"></i>
                            </a>
                        </span>
                    </div>
                </div>
                <div class="form-group">
                    <label for="type">${message(code: 'is.story.type')}</label>
                    <ui-select class="form-control"
                               name="type"
                               ng-model="storyPreview.type">
                        <ui-select-match placeholder="${message(code: 'todo.is.ui.story.type.placeholder')}">{{ $select.selected | i18n:'StoryTypes' }}</ui-select-match>
                        <ui-select-choices repeat="storyType in storyTypes | newStoryTypes">{{ storyType | i18n:'StoryTypes' }}</ui-select-choices>
                    </ui-select>
                </div>
                <div class="form-group">
                    <label for="tags">${message(code: 'is.backlogelement.tags')}</label>
                    <ui-select ng-click="retrieveTags()"
                               class="form-control"
                               name="tags"
                               multiple
                               tagging
                               tagging-tokens="SPACE|,"
                               tagging-label="${message(code: 'todo.is.ui.tag.create')}"
                               ng-model="storyPreview.tags">
                        <ui-select-match placeholder="${message(code: 'is.ui.backlogelement.notags')}">{{ $item }}</ui-select-match>
                        <ui-select-choices repeat="tag in tags | filter: $select.search">
                            <span ng-bind-html="tag | highlight: $select.search"></span>
                        </ui-select-choices>
                    </ui-select>
                </div>
                <div class="clearfix no-padding">
                    <div class="form-group"
                         ng-class="{ 'form-half' : authorizedStories('updateEstimate', stories) }">
                        <label for="value">${message(code: 'is.story.value')}</label>
                        <ui-select class="form-control"
                                   name="value"
                                   search-enabled="true"
                                   ng-model="storyPreview.value">
                            <ui-select-match>{{ $select.selected }}</ui-select-match>
                            <ui-select-choices repeat="i in integerSuite | filter: $select.search">
                                <span ng-bind-html="'' + i | highlight: $select.search"></span>
                            </ui-select-choices>
                        </ui-select>
                    </div>
                    <div class="form-half"
                         ng-if="authorizedStories('updateEstimate', stories)">
                        <label for="effort">${message(code: 'is.story.effort')}</label>
                        <ui-select ng-if="!isEffortCustom()"
                                   class="form-control"
                                   name="effort"
                                   search-enabled="true"
                                   ng-model="storyPreview.effort">
                            <ui-select-match>{{ $select.selected }}</ui-select-match>
                            <ui-select-choices repeat="i in effortSuite(isEffortNullable(topStory)) | filter: $select.search">
                                <span ng-bind-html="'' + i | highlight: $select.search"></span>
                            </ui-select-choices>
                        </ui-select>
                        <input type="number"
                               ng-if="isEffortCustom()"
                               min="0"
                               class="form-control"
                               name="effort"
                               ng-model="storyPreview.effort"/>
                    </div>
                </div>
                <div class="form-group"
                     ng-if="authorizedStories('updateParentSprint', stories)">
                    <label for="parentSprint">${message(code: 'is.sprint')}</label>
                    <ui-select ng-click="retrieveParentSprintEntries()"
                               class="form-control"
                               name="parentSprint"
                               search-enabled="true"
                               ng-model="storyPreview.parentSprint">
                        <ui-select-match allow-clear="true"
                                         placeholder="${message(code: 'is.ui.story.noparentsprint')}">
                            {{ $select.selected.parentReleaseName + ' - ' + ($select.selected | sprintName) }}
                        </ui-select-match>
                        <ui-select-choices group-by="'parentReleaseName'"
                                           repeat="parentSprintEntry in parentSprintEntries | filter: { index: $select.search }">
                            <span ng-bind-html="parentSprintEntry | sprintNameWithState | highlight: $select.search"></span>
                        </ui-select-choices>
                    </ui-select>
                </div>
                <div class="btn-toolbar">
                    <button class="btn btn-primary pull-right"
                            type="submit"
                            ng-disabled="!storyForm.$dirty || storyForm.$invalid || application.submitting">
                        ${message(code: 'default.button.update.label')}
                    </button>
                    <a class="btn btn-default pull-right"
                       ui-sref="^.^">
                        ${message(code: 'is.button.cancel')}
                    </a>
                </div>
            </form>
        </div>
    </div>
</div>
</script>
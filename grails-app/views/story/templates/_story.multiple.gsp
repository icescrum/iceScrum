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
<div class="card">
    <div class="details-header">
        <a class="btn btn-icon btn-icon-close" ui-sref="^.^"></a>
    </div>
    <div class="card-header">
        <div class="card-title">
            ${message(code: "todo.is.ui.stories")} ({{ stories.length }})
        </div>
    </div>
    <div class="details-no-tab">
        <div class="card-body">
            <div class="row">
                <div class="col-md-6">
                    <div class="sticky-notes grid-group">
                        <div class="sticky-note-container sticky-note-story stack twisted">
                            <div ng-style="(storyPreview.feature ? storyPreview.feature.color : '#f9f157') | createGradientBackground"
                                 class="sticky-note {{ ((storyPreview.feature ? storyPreview.feature.color : '#f9f157') | contrastColor) + ' ' + (storyPreview.type | storyType) }}">
                                <div class="sticky-note-head">
                                    <span class="id">{{ topStory.uid }}</span>
                                    <div class="sticky-note-type"></div>
                                </div>
                                <div class="sticky-note-content">
                                    <div class="item-values">
                                        <span ng-if="topStory.state > 1">@
                                        ${message(code: 'is.story.effort')} <strong>{{ topStory.effort != undefined ? topStory.effort : '?' }}</strong>
                                        </span>
                                        <span ng-if="topStory.state > 1 && topStory.value">|</span>
                                        <span ng-if="topStory.value">
                                            ${message(code: 'is.story.value')} <strong>{{ topStory.value }}</strong>
                                        </span>
                                    </div>
                                    <div class="title">{{ topStory.name }}</div>
                                    <div class="description"
                                         ng-bind-html="topStory.description | lineReturns | actorTag"></div>
                                </div>
                                <div class="sticky-note-tags">
                                    <a ng-repeat="tag in topStory.tags"
                                       href="{{ tagContextUrl(tag) }}">
                                        <span class="tag {{ getTagColor(tag, 'story') | contrastColor }}"
                                              ng-style="{'background-color': getTagColor(tag, 'story') }">{{:: tag }}</span>
                                    </a>
                                </div>
                                <div class="sticky-note-actions">
                                    <span class="action" ng-class="{'active':topStory.attachments_count}">
                                        <a class="action-link" defer-tooltip="${message(code: 'todo.is.ui.backlogelement.attachments')}">
                                            <span class="action-icon action-icon-attach"></span>
                                        </a>
                                    </span>
                                    <span class="action" ng-class="{'active':topStory.comments_count}">
                                        <a class="action-link" defer-tooltip="${message(code: 'todo.is.ui.comments')}">
                                            <span class="action-icon action-icon-comment"></span>
                                            <span class="badge">{{ topStory.comments_count || '' }}</span>
                                        </a>
                                    </span>
                                    <span class="action" ng-class="{'active':topStory.tasks_count}">
                                        <a class="action-link" defer-tooltip="${message(code: 'todo.is.ui.tasks')}">
                                            <span class="action-icon action-icon-task"></span>
                                            <span class="badge">{{ topStory.tasks_count || '' }}</span>
                                        </a>
                                    </span>
                                    <span class="action" ng-class="{'active':topStory.acceptanceTests_count}">
                                        <a class="action-link" defer-tooltip="${message(code: 'todo.is.ui.acceptanceTests')}">
                                            <span class="action-icon action-icon-test"></span>
                                            <span class="badge">{{ topStory.acceptanceTests_count || '' }}</span>
                                        </a>
                                    </span>
                                    <span class="action">
                                        <a class="action-link">
                                            <span class="action-icon action-icon-menu"></span>
                                        </a>
                                    </span>
                                </div>
                                <div class="sticky-note-state-progress">
                                    <div class="state">
                                        {{ topStory.state | i18n:'StoryStates' }}
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-6">
                    <div class="btn-toolbar">
                        <div class="btn-group">
                            <button type="button"
                                    ng-if="authorizedStories('accept', stories)"
                                    class="btn btn-secondary"
                                    ng-click="acceptToBacklogMultiple()">
                                ${message(code: 'is.ui.story.state.markAs')} {{ storyStatesByName.ACCEPTED | i18n:'StoryStates' }}
                            </button>
                            <button type="button"
                                    ng-if="authorizedStories('copy', stories)"
                                    class="btn btn-secondary"
                                    ng-click="copyMultiple()">
                                ${message(code: 'is.ui.copy')}
                            </button>
                            <button type="button"
                                    ng-if="authorizedStories('returnToSandbox', stories)"
                                    class="btn btn-secondary"
                                    ng-click="returnToSandboxMultiple()">
                                ${message(code: 'is.ui.story.state.markAs')} {{ storyStatesByName.SUGGESTED | i18n:'StoryStates' }}
                            </button>
                            <button type="button"
                                    ng-if="authorizedStories('delete', stories)"
                                    class="btn btn-secondary"
                                    ng-click="confirmDelete({ callback: deleteMultiple })">
                                ${message(code: 'is.ui.backlog.menu.delete')}
                            </button>
                        </div>
                        <entry:point id="story-multiple-toolbar"/>
                        <div ng-if="authorizedStories('follow', stories)"
                             class="btn-group">
                            <button type="button"
                                    ng-switch="allFollowed(stories)"
                                    class="btn btn-secondary"
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
                                    class="btn btn-secondary"
                                    uib-dropdown-toggle>
                                ${message(code: 'is.ui.story.turnInto')}
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
                        <span class="input-group-append" ng-if="storyPreview.feature.id">
                            <a ui-sref=".feature.details({featureId: storyPreview.feature.id})"
                               class="btn btn-secondary btn-sm">
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
                <div class="form-group" ng-if="showTags">
                    <label for="tags">
                        <entry:point id="item-properties-inside-tag"/>
                        ${message(code: 'is.backlogelement.tags')}
                    </label>
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
                <entry:point id="story-multiple-properties-after-tag"/>
                <div class="row is-form-row">
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
                    <button class="btn btn-primary float-right"
                            type="submit"
                            ng-disabled="!storyForm.$dirty || storyForm.$invalid || application.submitting">
                        ${message(code: 'default.button.update.label')}
                    </button>
                    <a class="btn btn-secondary float-right"
                       ui-sref="^.^">
                        ${message(code: 'is.button.cancel')}
                    </a>
                </div>
            </form>
        </div>
    </div>
</div>
</script>
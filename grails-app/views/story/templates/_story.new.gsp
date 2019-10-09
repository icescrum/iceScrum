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
<script type="text/ng-template" id="story.new.html">
<div class="card">
    <div class="details-header">
        <details-layout-buttons remove-ancestor="true"/>
    </div>
    <div class="card-header">
        <div class="card-title">
            <div class="details-title">
                <span class="item-name" title="${message(code: 'todo.is.ui.story.new')}">${message(code: 'todo.is.ui.story.new')}</span>
            </div>
        </div>
        <div class="form-text">
            ${message(code: 'is.ui.sandbox.help')}
            <documentation doc-url="features-stories-tasks#stories"/>
        </div>
        <div class="sticky-notes size-sm sticky-notes-standalone grey-sticky-notes grid-group">
            <div class="sticky-note-container sticky-note-story">
                <div sticky-note-color-watch="{{ storyPreview | storyColor }}"
                     class="sticky-note {{ ((storyPreview | storyColor) | contrastColor) + ' ' + (storyPreview.type | storyType)}}">
                    <div class="sticky-note-head">
                        <span class="id">42</span>
                        <div class="sticky-note-type-icon"></div>
                    </div>
                    <div class="sticky-note-content">
                        <div class="item-values"></div>
                        <div class="title">{{ story.name }}</div>
                        <div class="description-template"
                             ng-bind-html="storyPreview.description"></div>
                    </div>
                    <div class="sticky-note-tags">
                        <a ng-repeat="tag in storyPreview.tags"
                           href="{{ tagContextUrl(tag) }}">
                            <span class="tag {{ getTagColor(tag) | contrastColor }}"
                                  ng-style="{'background-color': getTagColor(tag) }">{{:: tag }}</span>
                        </a>
                    </div>
                    <div class="sticky-note-actions">
                        <span class="action">
                            <a class="action-link"><span class="action-icon action-icon-attach"></span></a>
                        </span>
                        <span class="action">
                            <a class="action-link"><span class="action-icon action-icon-comment"></span></a>
                        </span>
                        <span class="action" ng-class="{'active':storyPreview.tasks_count}">
                            <a class="action-link"
                               defer-tooltip="${message(code: 'todo.is.ui.tasks')}">
                                <span class="action-icon action-icon-task"></span>
                                <span class="badge">{{ storyPreview.tasks_count || '' }}</span>
                            </a>
                        </span>
                        <span class="action" ng-class="{'active':storyPreview.acceptanceTests_count}">
                            <a class="action-link"
                               defer-tooltip="${message(code: 'todo.is.ui.acceptanceTests')}">
                                <span class="action-icon action-icon-test"></span>
                                <span class="badge">{{ storyPreview.acceptanceTests_count || '' }}</span>
                            </a>
                        </span>
                        <span class="action">
                            <a class="action-link"><span class="action-icon action-icon-menu"></span></a>
                        </span>
                    </div>
                    <div class="sticky-note-state-progress">
                        <div class="state">{{ story.state | i18n:'StoryStates' }}
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="details-no-tab">
        <form ng-if="authorizedStory('create')"
              ng-submit="save(story, false)"
              name='formHolder.storyForm'
              novalidate>
            <div class="card-body">
                <div class="row is-form-row">
                    <div class="form-half">
                        <label for="name">${message(code: 'is.story.name')}</label>
                        <input required
                               name="name"
                               type="text"
                               class="form-control"
                               autofocus
                               placeholder="${message(code: 'is.ui.story.noname')}"
                               ng-maxlength="100"
                               ng-model="story.name"
                               autocomplete="off"
                               ng-change="findDuplicates(story.name)"/>
                    </div>
                    <entry:point id="story-new-form"/>
                </div>
                <div class="row is-form-row">
                    <div ng-if="authorizedStory('createAccepted')"
                         class="form-half">
                        <label for="state">${message(code: 'is.story.state')}</label>
                        <ui-select name="story.state"
                                   required
                                   class="form-control"
                                   ng-model="story.state">
                            <ui-select-match>{{ $select.selected | i18n:'StoryStates' }}</ui-select-match>
                            <ui-select-choices repeat="storyState in newStoryStates">{{ ::storyState | i18n:'StoryStates' }}</ui-select-choices>
                        </ui-select>
                    </div>
                    <div class="form-half">
                        <label for="feature">${message(code: 'is.feature')}</label>
                        <ui-select class="form-control"
                                   name="feature"
                                   search-enabled="true"
                                   ng-change="featureChanged()"
                                   ng-disabled="formHolder.featureDisabled"
                                   ng-model="story.feature">
                            <ui-select-match allow-clear="true" placeholder="${message(code: 'is.ui.story.nofeature')}">
                                <i class="fa fa-sticky-note" ng-style="{color: $select.selected.color}"></i> {{ $select.selected.name }}
                            </ui-select-match>
                            <ui-select-choices repeat="feature in features | orFilter: { name: $select.search, uid: $select.search }">
                                <i class="fa fa-sticky-note" ng-style="{color: feature.color}"></i> <span ng-bind-html="feature.name | highlight: $select.search"></span>
                            </ui-select-choices>
                        </ui-select>
                    </div>
                </div>
                <div ng-if="messageDuplicate"
                     class="form-text alert bg-warning"
                     ng-bind-html="messageDuplicate"></div>
            </div>
            <div class="card-footer">
                <div class="btn-toolbar">
                    <button class="btn btn-primary"
                            ng-disabled="formHolder.storyForm.$invalid || application.submitting"
                            defer-tooltip="${message(code: 'todo.is.ui.create.and.continue')} (SHIFT+RETURN)"
                            hotkey="{'shift+return': hotkeyClick }"
                            hotkey-allow-in="INPUT"
                            hotkey-description="${message(code: 'todo.is.ui.create.and.continue')}"
                            type='button'
                            ng-click="save(story, true)">
                        ${message(code: 'todo.is.ui.create.and.continue')}
                    </button>
                    <button class="btn btn-primary"
                            ng-disabled="formHolder.storyForm.$invalid || application.submitting"
                            type="submit">
                        ${message(code: 'default.button.create.label')}
                    </button>
                </div>
            </div>
        </form>
    </div>
</div>
</script>

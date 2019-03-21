%{--
- Copyright (c) 2015 Kagilum SAS
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
<is:window windowDefinition="${windowDefinition}">
    <div ng-if="releases.length > 0"
         class="card card-view">
        <div class="card-header">
            <div>
                <a class="card-title" ng-href="{{ openReleaseUrl(release) }}">
                    {{ release.name }}
                </a>
                <span class="state-title">
                    <span class="state-dot" ng-class="'state-dot-' + release.state"></span>
                    <span>{{ (release.state | i18n: 'ReleaseStates') }}</span>
                </span>
            </div>
            <div class="btn-toolbar">
                <div class="btn-group">
                    <button class="btn btn-icon btn-caret-left"
                            ng-style="{'visibility': !hasPreviousVisibleSprints() ? 'hidden' : 'visible'}"
                            ng-click="visibleSprintsPrevious()">
                    </button>
                    <button class="btn btn-icon btn-caret-right"
                            ng-style="{'visibility': !hasNextVisibleSprints() ? 'hidden' : 'visible'}"
                            ng-click="visibleSprintsNext()">
                    </button>
                </div>
                <div class="btn-group">
                    <button type="button"
                            class="btn btn-secondary btn-sm hidden-xs hidden-sm"
                            defer-tooltip="${message(code: 'todo.is.ui.stickynote.size')}"
                            ng-click="setStickyNoteSize(viewName)"><i class="fa {{ iconCurrentStickyNoteSize(viewName) }}"></i>
                    </button>
                    <button type="button"
                            class="btn btn-secondary btn-sm hidden-xs"
                            ng-click="fullScreen()"
                            defer-tooltip="${message(code: 'is.ui.window.fullscreen')}"><i class="fa fa-arrows-alt"></i>
                    </button>
                </div>
                <div class="btn-menu" ng-controller="releaseCtrl" uib-dropdown>
                    <shortcut-menu ng-model="release" model-menus="menus"></shortcut-menu>
                    <div uib-dropdown-toggle></div>
                    <div uib-dropdown-menu ng-init="itemType = 'release'" template-url="item.menu.html"></div>
                </div>
                <a class="btn btn-secondary btn-sm" ng-href="{{ openReleaseUrl(release) }}">
                    <i class="fa fa-pencil"></i>
                </a>
            </div>
        </div>
        <div class="card-body release-plan row"
             selectable="selectableOptions">
            <div class="sprint col"
                 ng-repeat="sprint in visibleSprints"
                 ng-controller="sprintBacklogCtrl">
                <div class="d-flex justify-content-between">
                    <div>
                        <a href="{{ openSprintUrl(sprint) }}" class="sprint-title">
                            {{ (sprint | sprintName) }}
                        </a>
                        <span class="state-title state-title-small">
                            <span class="state-dot" ng-class="'state-dot-' + sprint.state"></span>
                            <span>{{ (sprint.state | i18n: 'SprintStates') }}</span>
                        </span>
                    </div>
                    <div class="btn-menu" uib-dropdown>
                        <shortcut-menu ng-model="sprint" model-menus="menus" btn-sm="true"></shortcut-menu>
                        <div uib-dropdown-toggle></div>
                        <div uib-dropdown-menu ng-init="itemType = 'sprint'" template-url="item.menu.html"></div>
                    </div>
                </div>
                <span>
                    <span class="timebox-dates timebox-dates-small">
                        <span class="start-date" title="{{ sprint.startDate | dayShort }}">{{ sprint.startDate | dayShorter }}</span><span class="end-date" title="{{ sprint.endDate | dayShort }}">{{ sprint.endDate | dayShorter }}</span>
                    </span>
                    <span class="sprint-values">
                        <span>
                            ${message(code: 'is.sprint.velocity')}
                            <strong ng-if="sprint.state > sprintStatesByName.TODO"
                                    defer-tooltip="${message(code: 'is.sprint.velocity')}">{{ sprint.velocity | roundNumber:2 }} /</strong>
                            <strong defer-tooltip="${message(code: 'is.sprint.plannedVelocity')}">{{ sprint.capacity | roundNumber:2 }}</strong>
                        </span>
                    </span>
                </span>
                <a class="btn btn-secondary btn-sm" href="{{ openSprintUrl(sprint) }}">
                    <i class="fa fa-pencil"></i>
                </a>
                <div class="sticky-notes {{ stickyNoteClass }}"
                     ng-class="{'sortable-moving':application.sortableMoving, 'has-selected' : hasSelected()}"
                     ng-controller="storyBacklogCtrl"
                     as-sortable="sprintSortableOptions | merge: sortableScrollOptions()"
                     is-disabled="!isSortingSprint(sprint)"
                     ng-model="backlog.stories"
                     ng-init="emptyBacklogTemplate = 'story.backlog.planning.empty.html'"
                     ng-include="'story.backlog.html'">
                </div>
            </div>
            <div ng-if="!sprints || sprints.length == 0"
                 class="text-center">
                <div class="empty-view">
                    <p class="form-text">${message(code: 'is.ui.sprint.help')}<p>
                </div>
            </div>
        </div>
    </div>
    <div ng-if="releases.length == 0">
        <div class="empty-view" ng-controller="releaseCtrl">
            <p class="form-text">${message(code: 'is.ui.release.help')}<p>
            <a class="btn btn-primary"
               ng-if="authorizedRelease('create')"
               href="#{{ ::viewName }}/new">
                ${message(code: 'todo.is.ui.release.new')}
            </a>
        </div>
    </div>
    <div class="timeline" ng-show="releases.length" timeline="releases" on-select="timelineSelected" selected="selectedItems"></div>
</is:window>
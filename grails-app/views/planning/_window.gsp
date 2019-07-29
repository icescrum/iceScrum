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
        <div class="card-header row">
            <div class="card-header-left order-0 col-auto flex-grow-1">
                <a class="card-title" ng-href="{{ openReleaseUrl(release) }}">
                    {{ release.name }}
                </a>
                <span class="state-title">
                    <span class="state-dot" ng-class="'state-dot-' + release.state"></span>
                    <span>{{ (release.state | i18n: 'ReleaseStates') }}</span>
                </span>
            </div>
            <div class="w-100 order-2 d-block d-sm-none col-auto"></div>
            <div class="btn-toolbar align-items-center order-3 order-sm-1 col-12 col-sm-auto justify-content-between">
                <div>
                    <button class="btn btn-icon"
                            ng-style="{'visibility': !hasNextVisibleSprints() ? 'd-none' : 'd-inline-block'}"
                            ng-click="visibleSprintsPrevious()">
                        <span class="icon icon-caret-left"></span>
                    </button>
                    <button class="btn btn-icon"
                            ng-style="{'visibility': !hasNextVisibleSprints() ? 'd-none' : 'd-inline-block'}"
                            ng-click="visibleSprintsNext()">
                        <span class="icon icon-caret-right"></span>
                    </button>
                </div>
                <div class="btn-group d-none d-lg-block sticky-note-size" uib-dropdown>
                    <button class="btn btn-secondary btn-sm with-icon"
                            uib-dropdown-toggle
                            type="button">
                        <span class="icon icon-{{ iconCurrentStickyNoteSize(viewName) }}"></span>
                    </button>
                    <div uib-dropdown-menu role="menu">
                        <div class="dropdown-header">${message(code: 'todo.is.ui.stickynote.display')}</div>
                        <div role="menuitem"
                             class="dropdown-item clearfix"
                             ng-click="setStickyNoteSize(viewName,'list-group')"
                             ng-class="{'active': iconCurrentStickyNoteSize(viewName) == 'list-group'}">${message(code: 'todo.is.ui.stickynote.display.list')}&nbsp;<span class="float-right icon icon-list-group icon-highlight"></span></div>
                        <div role="menuitem"
                             class="dropdown-item clearfix"
                             ng-click="setStickyNoteSize(viewName,'grid-group size-sm')"
                             ng-class="{'active': iconCurrentStickyNoteSize(viewName) == 'grid-group size-sm'}">${message(code: 'todo.is.ui.stickynote.display.grid.sm')}&nbsp;<span class="float-right icon icon-grid-group-sm icon-highlight"></span>
                        </div>
                        <div role="menuitem"
                             class="dropdown-item clearfix"
                             ng-click="setStickyNoteSize(viewName,'grid-group')"
                             ng-class="{'active': iconCurrentStickyNoteSize(viewName) == 'grid-group'}">${message(code: 'todo.is.ui.stickynote.display.grid')}&nbsp;<span class="float-right icon icon-grid-group icon-highlight"></span></div>
                    </div>
                </div>
                <div>
                    <a class="btn btn-icon btn-sm ml-1 mr-1"
                       ng-href="{{ openReleaseUrl(release) }}">
                        <span class="icon icon-details"></span>
                    </a>
                </div>
            </div>
            <div class="order-1 order-sm-3 col-auto">
                <div class="btn-menu" ng-controller="releaseCtrl" uib-dropdown>
                    <shortcut-menu ng-model="release" model-menus="menus"></shortcut-menu>
                    <div uib-dropdown-toggle></div>
                    <div uib-dropdown-menu ng-init="itemType = 'release'" template-url="item.menu.html"></div>
                </div>
            </div>
        </div>
        <div class="card-body release-plan" ng-class="{'has-selected': hasSelected()}"
             selectable="selectableOptions">
            <div class="sprint col"
                 ng-repeat="sprint in visibleSprints"
                 ng-controller="sprintBacklogCtrl">
                <div>
                    <div class="d-flex justify-content-between">
                        <div class="sprint-header-left">
                            <a href="{{ openSprintUrl(sprint) }}" class="sprint-title">
                                {{ (sprint | sprintName) }}
                            </a>
                            <span class="state-title state-title-small">
                                <span class="state-dot" ng-class="'state-dot-' + sprint.state"></span>
                                <span>{{ (sprint.state | i18n: 'SprintStates') }}</span>
                            </span>
                            <span class="timebox-dates timebox-dates-small">
                                <span class="start-date" title="{{ sprint.startDate | dayShort }}">{{ sprint.startDate | dayShorter }}</span><span class="end-date" title="{{ sprint.endDate | dayShort }}">{{ sprint.endDate | dayShorter }}</span>
                            </span>
                            <span class="sprint-values sprint-values-small">
                                <span ng-if="sprint.velocity || sprint.capacity">
                                    <span>{{ message('is.sprint.' + (sprint.state > sprintStatesByName.TODO ? 'velocity' : 'plannedVelocity')) }}</span>
                                    <strong ng-if="sprint.state > sprintStatesByName.TODO"
                                            defer-tooltip="${message(code: 'is.sprint.velocity')}">{{ sprint.velocity | roundNumber:2 }} /</strong>
                                    <strong defer-tooltip="${message(code: 'is.sprint.plannedVelocity')}">{{ sprint.capacity | roundNumber:2 }}</strong>
                                </span>
                            </span>
                        </div>
                        <div class="btn-menu" uib-dropdown>
                            <shortcut-menu ng-model="sprint" model-menus="menus" btn-sm="true"></shortcut-menu>
                            <div uib-dropdown-toggle></div>
                            <div uib-dropdown-menu ng-init="itemType = 'sprint'" template-url="item.menu.html"></div>
                        </div>
                    </div>
                </div>
                <div class="sticky-notes {{ currentStickyNoteSize(viewName, 'grid-group size-sm') }} scrollable-selectable-container"
                     s ng-class="{'sortable-moving':application.sortableMoving}"
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
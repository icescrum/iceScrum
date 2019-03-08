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
                    {{ release.name + ' - ' + (release.state | i18n: 'ReleaseStates') }}</i>
                </a>
            </div>
            <div class="btn-toolbar">
                <div class="btn-group">
                    <button class="btn btn-secondary btn-sm"
                            ng-style="{'visibility': !hasPreviousVisibleSprints() ? 'hidden' : 'visible'}"
                            ng-click="visibleSprintsPrevious()">
                        <i class="fa fa-caret-left"></i>
                    </button>
                    <button class="btn btn-secondary btn-sm"
                            ng-style="{'visibility': !hasNextVisibleSprints() ? 'hidden' : 'visible'}"
                            ng-click="visibleSprintsNext()">
                        <i class="fa fa-caret-right"></i>
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
                    <div uib-dropdown-menu class="float-right" ng-init="itemType = 'release'" template-url="item.menu.html"></div>
                </div>
                <a class="btn btn-secondary btn-sm" ng-href="{{ openReleaseUrl(release) }}">
                    <i class="fa fa-pencil"
                       defer-tooltip="${message(code: 'todo.is.ui.details')}"></i>
                </a>
            </div>
        </div>
        <div class="card-body release-plan row"
             selectable="selectableOptions">
            <div class="sprint col"
                 ng-repeat="sprint in visibleSprints"
                 ng-controller="sprintBacklogCtrl">
                <div>
                    <a href="{{ openSprintUrl(sprint) }}" class="link"><i class="fa fa-tasks"></i> {{ (sprint | sprintName) + ' - ' + (sprint.state | i18n: 'SprintStates') }}</a>
                    <br/>
                    <span>
                        <span title="{{ sprint.startDate | dayShort }}">{{ sprint.startDate | dayShorter }}</span>
                        <i class="fa fa-angle-right"></i>
                        <span title="{{ sprint.endDate | dayShort }}">{{ sprint.endDate | dayShorter }}</span>
                        <span class="sprint-numbers">
                            <span ng-if="sprint.state > sprintStatesByName.TODO"
                                  defer-tooltip="${message(code: 'is.sprint.velocity')}">{{ sprint.velocity | roundNumber:2 }} /</span>
                            <span defer-tooltip="${message(code: 'is.sprint.plannedVelocity')}">{{ sprint.capacity | roundNumber:2 }} <i class="small-icon fa fa-dollar"></i></span>
                        </span>
                    </span>
                </div>
                <div>
                    <div class="btn-group" role="group">
                        <shortcut-menu ng-model="sprint" model-menus="menus" btn-secondary="true"></shortcut-menu>
                        <div class="btn-group" uib-dropdown>
                            <button type="button" class="btn btn-secondary btn-sm" uib-dropdown-toggle>
                            </button>
                            <div uib-dropdown-menu class="float-right" ng-init="itemType = 'sprint'" template-url="item.menu.html"></div>
                        </div>
                    </div>
                    <a class="btn btn-secondary btn-sm" href="{{ openSprintUrl(sprint) }}">
                        <i class="fa fa-pencil"
                           defer-tooltip="${message(code: 'todo.is.ui.details')}"></i>
                    </a>
                </div>
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
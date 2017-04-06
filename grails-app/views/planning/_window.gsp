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
<div class="panel panel-light">
    <div ng-if="releases.length > 0"
         class="backlogs-list">
        <h4 class="btn-toolbar pull-left">
            <a class="link" href="#/planning/{{ release.id }}/details">
                {{ release.name + ' - ' + (release.state | i18n: 'ReleaseStates') }} <i class="fa fa-info-circle visible-on-hover"></i>
            </a>
        </h4>
        <div class="btn-toolbar pull-right">
            <div class="btn-group">
                <button class="btn btn-default"
                        ng-style="{'visibility': !hasPreviousVisibleSprints() ? 'hidden' : 'visible'}"
                        ng-click="visibleSprintsPrevious()">
                    <i class="fa fa-caret-left"></i>
                </button>
                <button class="btn btn-default"
                        ng-style="{'visibility': !hasNextVisibleSprints() ? 'hidden' : 'visible'}"
                        ng-click="visibleSprintsNext()">
                    <i class="fa fa-caret-right"></i>
                </button>
            </div>

            <div class="btn-group">
                <button type="button"
                        class="btn btn-default hidden-xs hidden-sm"
                        uib-tooltip="${message(code: 'todo.is.ui.postit.size')}"
                        ng-click="setPostitSize(viewName)"><i class="fa {{ iconCurrentPostitSize(viewName, 'grid-group size-l') }}"></i>
                </button>
                <button type="button"
                        class="btn btn-default hidden-xs"
                        ng-click="fullScreen()"
                        uib-tooltip="${message(code:'is.ui.window.fullscreen')}"><i class="fa fa-arrows-alt"></i>
                </button>
            </div>
            <div class="btn-group" role="group" ng-controller="releaseCtrl">
                <shortcut-menu ng-model="release" model-menus="menus"></shortcut-menu>
                <div class="btn-group" uib-dropdown>
                    <button type="button" class="btn btn-default" uib-dropdown-toggle>
                        <i class="fa fa-ellipsis-h"></i>
                    </button>
                    <ul uib-dropdown-menu class="pull-right" ng-init="itemType = 'release'" template-url="item.menu.html"></ul>
                </div>
            </div>
        </div>
        <div class="clearfix"></div>
        <hr>
    </div>
    <div ng-if="releases.length > 0"
         class="backlogs-list-details"
         selectable="selectableOptions">
        <div class="panel panel-light"
             ng-repeat="sprint in visibleSprints"
             ng-controller="sprintBacklogCtrl">
            <div class="panel-heading" style="padding-bottom:5px;">
                <h3 class="panel-title small-title">
                    <div class="pull-left">
                        <a class="link" href="{{ openSprintUrl(sprint) }}">
                            {{ (sprint | sprintName) + ' - ' + (sprint.state | i18n: 'SprintStates') }} <i class="fa fa-info-circle visible-on-hover"></i>
                        </a>
                        <br/>
                        <span class="sub-title text-muted">
                            <i class="fa fa-calendar"></i> <span title="{{ sprint.startDate | dayShort }}">{{ sprint.startDate | dayShorter }}</span> <i class="fa fa-angle-right"></i> <span title="{{ sprint.endDate | dayShort }}">{{ sprint.endDate | dayShorter }}</span>
                            <span class="sprint-numbers">
                                <span ng-if="sprint.state > sprintStatesByName.TODO"
                                      uib-tooltip="${message(code: 'is.sprint.velocity')}">{{ sprint.velocity | roundNumber:2 }} /</span>
                                <span uib-tooltip="${message(code: 'is.sprint.capacity')}">{{ sprint.capacity | roundNumber:2 }}</span>
                                <i class="small-icon fa fa-dollar"></i>
                            </span>
                        </span>
                    </div>
                    <div class="pull-right">
                        <div class="btn-group" role="group">
                            <shortcut-menu ng-model="sprint" model-menus="menus"></shortcut-menu>
                            <div class="btn-group" uib-dropdown>
                                <button type="button" class="btn btn-default" uib-dropdown-toggle>
                                    <i class="fa fa-ellipsis-h"></i></i>
                                </button>
                                <ul uib-dropdown-menu class="pull-right" ng-init="itemType = 'sprint'" template-url="item.menu.html"></ul>
                            </div>
                        </div>
                    </div>
                </h3>
            </div>
            <div class="panel-body">
                <div class="postits"
                     ng-class="{'sortable-moving':application.sortableMoving, 'has-selected' : hasSelected(), 'sortable-disabled':!isSortingSprint(sprint)}"
                     postits-screen-size
                     ng-controller="storyCtrl"
                     as-sortable="sprintSortableOptions | merge: sortableScrollOptions()"
                     is-disabled="!isSortingSprint(sprint)"
                     ng-model="backlog.stories"
                     ng-init="emptyBacklogTemplate = 'story.backlog.planning.empty.html'"
                     ng-include="'story.backlog.html'">
                </div>
            </div>
        </div>
        <div ng-if="!sprints || sprints.length == 0"
             class="panel panel-light text-center">
            <div class="panel-body">
                <div class="empty-view">
                    <p class="help-block">${message(code: 'is.ui.sprint.help')}<p>
                </div>
            </div>
        </div>
    </div>
    <div ng-if="releases.length == 0"
         class="panel panel-light">
        <div class="panel-body">
            <div class="empty-view" ng-controller="releaseCtrl">
                <p class="help-block">${message(code: 'is.ui.release.help')}<p>
                <a class="btn btn-primary"
                   ng-if="authorizedRelease('create')"
                   href="#{{ ::viewName }}/new">
                    ${message(code: 'todo.is.ui.release.new')}
                </a>
            </div>
        </div>
    </div>
    <div class="timeline" ng-show="releases.length" timeline="releases" on-select="timelineSelected" selected="selectedItems"></div>
</div>
</is:window>
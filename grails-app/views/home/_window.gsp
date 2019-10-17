%{--
- Copyright (c) 2019 Kagilum.
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
<div id="view-home" class="view widget-view">
    <div class="content">
        <div class="home-header">
            <div class="home-header-title">
                <h1>${message(code: 'is.ui.your')} <span class="sharpie-highlight">${message(code: 'is.ui.projects').toLowerCase()}</span></h1>
                <div uib-dropdown>
                    <button class="btn btn-link"
                            uib-dropdown-toggle
                            type="button">
                        ${message(code: 'todo.is.ui.profile')}
                    </button>
                    <div uib-dropdown-menu class="dropdown-menu-right profile-dropdown">
                        <div class="dropdown-item">
                            <div class="media">
                                <img class="rounded-circle mr-2"
                                     ng-src="{{ currentUser | userAvatar }}"
                                     height="37px"
                                     width="37px"/>
                                <div class="media-body text-truncate-fix2">
                                    <div class="text-truncate">{{ (currentUser | userFullName) }}</div>
                                    <div class="text-muted profile-subtitle text-truncate">
                                        <div>{{currentUser.email}}</div>
                                        <entry:point id="user-profile-panel"/>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="dropdown-item">
                            <a href
                               ng-if="getColorScheme() == 'dark'"
                               style="background: white; color: #111111;"
                               class="btn btn-secondary dropdown-button"
                               uib-tooltip="${message(code: 'is.ui.colorScheme.toggle')} (SHIFT+D)"
                               tooltip-placement="left"
                               ng-click="$event.stopPropagation(); toggleColorScheme()">
                                <i class="color-scheme-icon icon-sun"></i> ${message(code: 'is.ui.colorScheme.light')}
                            </a>
                            <a href
                               ng-if="getColorScheme() == 'light'"
                               style="background: #282829; color: white;"
                               class="btn btn-secondary dropdown-button"
                               uib-tooltip="${message(code: 'is.ui.colorScheme.toggle')} (SHIFT+D)"
                               tooltip-placement="left"
                               ng-click="$event.stopPropagation(); toggleColorScheme()">
                                <i class="color-scheme-icon icon-moon"></i> ${message(code: 'is.ui.colorScheme.dark')}
                            </a>
                        </div>
                        <div class="dropdown-item">
                            <a href
                               class="btn btn-secondary dropdown-button"
                               hotkey="{'shift+u':showProfile}"
                               hotkey-description="${message(code: 'is.dialog.profile')}"
                               ng-click="showProfile()">${message(code: 'is.dialog.profile')}
                            </a>
                        </div>
                        <div class="dropdown-divider"></div>
                        <a class="dropdown-item text-center text-danger" href="${createLink(controller: 'logout')}" class="delete-link">
                            <strong>${message(code: 'is.logout')}</strong>
                        </a>
                    </div>
                </div>
            </div>
            <div class="home-projects">
                <div class="home-project d-flex justify-content-between"
                     ng-repeat="project in projects | search">
                    <div class="d-flex flex-column justify-content-between w-100 text-truncate-fix2">
                        <div>
                            <a ng-href="{{:: getProjectUrl(project) }}">
                                <h3 class="text-truncate">{{ ::project.name }}</h3>
                                <div class="text-truncate">{{ ::project.team.name }}</div>
                            </a>
                        </div>
                        <div class="project-stats d-flex">
                            <div class="mr-3"><strong>{{ ::project.stories_count }}</strong> ${message(code: 'todo.is.ui.stories')}</div>
                            <div><strong>{{ ::project.releases_count }}</strong> ${message(code: 'todo.is.ui.releases')}</div>
                        </div>
                    </div>
                    <div>
                        <a href="{{:: getProjectUrl(project, 'backlog') }}"
                           class="btn btn-secondary btn-sm mb-2"
                           role="button">
                            <span class="icon-main-menu icon-main-menu-backlog d-inline-block"></span> ${message(code: 'is.ui.backlogs')}
                        </a>
                        <a href="{{:: getProjectUrl(project, 'taskBoard') }}"
                           class="btn btn-secondary btn-sm"
                           role="button">
                            <span class="icon-main-menu icon-main-menu-taskBoard d-inline-block"></span> ${message(code: 'todo.is.ui.taskBoard')}
                        </a>
                    </div>
                </div>
                <div class="home-project-add"
                     ui-sref="new"
                     ng-if="projectCreationEnabled">
                    <strong>${message(code: 'todo.is.ui.project.createNew')}</strong>
                </div>
            </div>
        </div>
        <div class="row widgets"
             as-sortable="widgetSortableOptions | merge: sortableScrollOptions('#view-home')"
             is-disabled="!authorizedWidget('move')"
             ng-model="widgets">
            <div as-sortable-item
                 ng-include src="templateWidgetUrl(widget)"
                 id="{{ widget.id }}"
                 ng-controller="widgetCtrl"
                 class="widget widget-{{ widget.widgetDefinitionId }} widget-height-{{ widget.height? widget.height :'auto' }} widget-width-{{ widget.width }}"
                 ng-repeat="widget in widgets"></div>
        </div>
        <div class="add-widget" ng-if="authorizedWidget('create')">
            <button class="btn btn-primary" ng-click="showAddWidgetModal()">
                ${message(code: 'is.button.add')}
            </button>
        </div>
    </div>
</div>
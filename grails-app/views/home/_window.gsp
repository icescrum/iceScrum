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
            <h1 class="home-projects-title">Your <span class="sharpie-highlight">projects</span></h1>
            <div class="home-projects">
                <div class="home-project"
                     ng-repeat="project in projects">
                    <div class="home-project-title">{{ ::project.name }}</div>
                    <a href="{{:: getProjectUrl(project, 'backlog') }}"
                       class="btn btn-secondary btn-sm"
                       role="button">${message(code: 'is.ui.backlogs')}</a>
                    <a href="{{:: getProjectUrl(project, 'taskBoard') }}"
                       class="btn btn-secondary btn-sm"
                       role="button">${message(code: 'todo.is.ui.taskBoard')}</a>
                </div>
                <div class="home-project-add"
                     ui-sref="new"
                     ng-if="projectCreationEnabled">
                    ${message(code: 'todo.is.ui.project.createNew')}
                </div>
            </div>
        </div>
        <div class="widgets"
             as-sortable="widgetSortableOptions | merge: sortableScrollOptions('#view-home')"
             is-disabled="!authorizedWidget('move')"
             ng-model="widgets">
            <div as-sortable-item
                 ng-include src="templateWidgetUrl(widget)"
                 id="{{ widget.id }}"
                 ng-controller="widgetCtrl"
                 class="widget widget-{{ widget.widgetDefinitionId }} widget-height-{{ widget.height }} widget-width-{{ widget.width }}"
                 ng-repeat="widget in widgets"></div>
        </div>
        <div class="add-widget" ng-if="authorizedWidget('create')">
            <button class="btn btn-primary" ng-click="showAddWidgetModal()">
                ${message(code: 'is.button.add')}
            </button>
        </div>
    </div>
</div>
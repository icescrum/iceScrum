%{--
- Copyright (c) 2017 Kagilum.
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
<is:widget widgetDefinition="${widgetDefinition}">
    <div class="btn-group buttons-margin-bottom" ng-repeat="project in projects">
        <a href="{{:: getProjectUrl(project) }}" class="btn btn-default" role="button">{{ ::project.name }}</a>
        <a href="{{:: getProjectUrl(project, 'backlog') }}" class="btn btn-default" uib-tooltip="${message(code: 'is.ui.backlogs')}" role="button"><i class="fa fa-inbox"></i></a>
        <a href="{{:: getProjectUrl(project, 'taskBoard') }}" class="btn btn-default" uib-tooltip="${message(code: 'todo.is.ui.taskBoard')}" role="button"><i class="fa fa-tasks"></i></a>
    </div>
    <div ng-if="!projects.length && projectsLoaded" class="buttons-margin-bottom">
        <a class="btn btn-primary"
           ui-sref="newProject">
            ${message(code: 'todo.is.ui.project.createNew')}
        </a>
        <button class="btn btn-default"
                type="button"
                click-async="createSampleProject()">
            ${message(code: 'is.ui.project.sample.create')}
        </button>
    </div>
    <hr>
</is:widget>
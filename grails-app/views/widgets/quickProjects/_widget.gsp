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
        <a href="{{:: getProjectUrl(project) }}" class="btn btn-secondary" role="button">{{ ::project.name }}</a>
        <a href="{{:: getProjectUrl(project, 'backlog') }}" class="btn btn-secondary" defer-tooltip="${message(code: 'is.ui.backlogs')}" role="button"><i class="fa fa-inbox"></i></a>
        <a href="{{:: getProjectUrl(project, 'taskBoard') }}" class="btn btn-secondary" defer-tooltip="${message(code: 'todo.is.ui.taskBoard')}" role="button"><i class="fa fa-tasks"></i></a>
    </div>
    <div ng-if="!projects.length && projectsLoaded && projectCreationEnabled" class="buttons-margin-bottom">
        <a class="btn btn-primary"
           ui-sref="new">
            ${message(code: 'todo.is.ui.project.createNew')}
        </a>
        <div>
            <documentation doc-url="getting-started-with-icescrum" title="is.ui.documentation.getting.started"/>
        </div>
    </div>
    <hr>
</is:widget>
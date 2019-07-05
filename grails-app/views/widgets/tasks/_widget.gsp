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
    <div class="task-widget"
         ng-repeat="entry in tasksByProject track by $index">
        <h4 class="sticky-header">{{ ::entry.project.name }}</h4>
        <div class="sticky-notes grid-group">
            <div ng-repeat="task in entry.tasks"
                 is-watch="task"
                 class="sticky-note-container sticky-note-task">
                <div ng-include="'task.light.html'" ng-init="link = taskUrl(task, entry.project);"></div>
            </div>
        </div>
    </div>
</is:widget>
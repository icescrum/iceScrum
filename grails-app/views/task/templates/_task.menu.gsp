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

<script type="text/ng-template" id="task.menu.html">
<ul class="dropdown-menu pull-right" uib-dropdown-menu role="menu">
    <li ng-if="authorizedTask('take', task)">
        <a href ng-click="take(task)">
            ${message(code: 'is.ui.sprintPlan.menu.task.take')}
        </a>
    </li>
    <li ng-if="authorizedTask('release', task)">
        <a href ng-click="release(task)">
            ${message(code: 'is.ui.sprintPlan.menu.task.unassign')}
        </a>
    </li>
    <li ng-if="authorizedTask('copy', task)">
        <a href ng-click="copy(task)">
            ${message(code: 'is.ui.sprintPlan.menu.task.copy')}
        </a>
    </li>
    <li ng-if="authorizedTask('makeStory', task)">
        <a href ng-click="makeStory(task)">
            ${message(code: 'todo.is.ui.task.makeStory')}
        </a>
    </li>
    <li>
        <a href ng-click="showCopyModal('${message(code:'is.permalink')}', (task.uid | permalink: 'task'))">
            ${message(code: 'todo.is.ui.permalink.copy')}
        </a>
    </li>
    <li ng-if="authorizedTask('delete', task)">
        <a href ng-click="delete(task)">
            ${message(code: 'is.ui.sprintPlan.menu.task.delete')}
        </a>
    </li>
    <li ng-if="authorizedTask('block', task)">
        <a href ng-click="block(task)">
            ${message(code: 'is.ui.sprintPlan.menu.task.block')}
        </a>
    </li>
    <li ng-if="authorizedTask('unBlock', task)">
        <a href ng-click="unBlock(task)">
            ${message(code: 'is.ui.sprintPlan.menu.task.unblock')}
        </a>
    </li>
</ul>
</script>

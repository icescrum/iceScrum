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

<script type="text/ng-template" id="sprint.menu.html">
<li ng-if="authorizedSprint('activate', sprint)">
    <a href ng-click="confirm({ message: '${message(code: 'is.ui.releasePlan.menu.sprint.activate.confirm')}', callback: activate, args: [sprint] })">
        ${message(code:'is.ui.releasePlan.menu.sprint.activate')}
    </a>
</li>
<li ng-if="authorizedSprint('close', sprint)">
    <a href ng-click="confirm({ message: '${message(code: 'is.ui.releasePlan.menu.sprint.close.confirm')}', callback: close, args: [sprint] })">
        ${message(code:'is.ui.releasePlan.menu.sprint.close')}
    </a>
</li>
<li ng-if="authorizedSprint('autoPlan', sprint)">
    <a href ng-click="showAutoPlanModal({callback: autoPlan, args: [sprint]})">
        ${message(code:'is.ui.releasePlan.toolbar.autoPlan')}
    </a>
</li>
<li ng-if="authorizedSprint('unPlan', sprint)">
    <a href ng-click="unPlan(sprint)">
        ${message(code:'is.ui.releasePlan.menu.sprint.dissociateAll')}
    </a>
</li>
<li ng-if="authorizedSprint('delete', sprint)">
    <a href ng-click="confirm({ message: '${message(code: 'is.confirm.delete')}', callback: delete, args: [sprint] })">
        ${message(code:'is.ui.releasePlan.menu.sprint.delete')}
    </a>
</li>
</script>

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

<script type="text/ng-template" id="release.menu.html">
<li ng-if="authorizedRelease('activate', release)">
    <a href ng-click="confirm({ message: '${message(code: 'is.ui.timeline.menu.activate.confirm')}', callback: activate, args: [release] })">
        ${message(code:'is.ui.timeline.menu.activate')}
    </a>
</li>
<li ng-if="authorizedRelease('close', release)">
    <a href ng-click="confirm({ message: '${message(code: 'is.ui.timeline.menu.close.confirm')}', callback: close, args: [release] })">
        ${message(code:'is.ui.timeline.menu.close')}
    </a>
</li>
<li ng-if="authorizedRelease('generateSprints', release)">
    <a href ng-click="generateSprints(release)">
        ${message(code:'is.ui.releasePlan.toolbar.generateSprints')}
    </a>
</li>
<li ng-if="authorizedRelease('autoPlan', release)">
    <a href ng-click="showAutoPlanModal({callback: autoPlan, args: [release]})">
        ${message(code:'is.ui.releasePlan.toolbar.autoPlan')}
    </a>
</li>
<li ng-if="authorizedRelease('unPlan', release)">
    <a href ng-click="unPlan(release)">
        ${message(code:'is.ui.releasePlan.toolbar.dissociateAll')}
    </a>
</li>
<li ng-if="authorizedRelease('delete', release)">
    <a href ng-click="delete(release)">
        ${message(code:'is.ui.timeline.menu.delete')}
    </a>
</li>
</script>
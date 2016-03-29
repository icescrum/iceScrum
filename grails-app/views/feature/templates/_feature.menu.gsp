%{--
- Copyright (c) 2014 Kagilum.
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

<script type="text/ng-template" id="feature.menu.html">
<ul class="dropdown-menu" uib-dropdown-menu role="menu">
    <li>
        <a href ng-click="setFeatureContext(feature)">
            ${message(code: 'todo.is.ui.context.set')}
        </a>
    </li>
    <li ng-if="authorizedFeature('copyToBacklog')">
        <a href ng-click="copyToBacklog(feature)">
            ${message(code: 'is.ui.feature.menu.copy')}
        </a>
    </li>
    <li>
        <a href ng-click="showCopyModal('${message(code:'is.permalink')}', (feature.uid | permalink: 'feature'))">
            ${message(code: 'todo.is.ui.permalink.copy')}
        </a>
    </li>
    <li ng-if="authorizedFeature('delete')">
        <a href ng-click="confirm({ message: '${message(code: 'is.confirm.delete')}', callback: delete, args: [feature] })">
            ${message(code: 'is.ui.feature.menu.delete')}
        </a>
    </li>
</ul>
</script>

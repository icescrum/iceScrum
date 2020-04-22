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

<script type="text/ng-template" id="app.list.html">
<div class="modal-search text-center">
    <input type="text"
           ng-model="holder.appSearch"
           class="form-control search-input"
           placeholder="${message(code: 'todo.is.ui.search.action')}">
</div>
<entry:point id="app-list-before-list"></entry:point>
<div class="app-list text-center">
    <div class="align-self-start" ng-repeat="currentAppDefinition in filteredApps = (appDefinitions | filter:appDefinitionFilter | orderBy: appsOrder)">
        <div ng-click="openAppDefinition(currentAppDefinition)"
             class="app-logo app-{{:: currentAppDefinition.id}}">
            <div class="app-enabled" ng-if="isEnabledApp(currentAppDefinition)" title="${message(code: 'is.ui.apps.enabled')}"></div>
            <div class="app-new" ng-if="currentAppDefinition.isNew && !isEnabledApp(currentAppDefinition)">${message(code: 'is.ui.apps.new')}</div>
            <img ng-src="{{:: currentAppDefinition.logo }}"
                 class="img-fluid"
                 alt="{{:: currentAppDefinition.name }}">
            <div ng-click="openAppDefinition(currentAppDefinition)"
                 class="text-truncate app-name">
                {{:: currentAppDefinition.name }}
            </div>
        </div>
    </div>
    <div class="my-5 mx-auto" ng-if="appDefinitions.length > 0 && filteredApps.length == 0">
        <a href="${message(code: 'is.ui.apps.store.query')}{{ holder.appSearch }}">${message(code: 'is.ui.apps.store.search')}</a>
    </div>
</div>
</script>
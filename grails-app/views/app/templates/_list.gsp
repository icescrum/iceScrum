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

<script type="text/ng-template" id="app.list.html">
<div class="row">
    <div class="col-md-offset-1 col-md-10 text-center">
        <div class="input-group">
            <input type="text"
                   ng-model="holder.appSearch"
                   name="app-search-input"
                   class="form-control"
                   placeholder="${message(code: 'todo.is.ui.search.action')}">
            <span class="input-group-btn">
                <button class="btn btn-default"
                        type="button"
                        ng-click="searchApp('')">
                    <i class="fa" ng-class="holder.appSearch ? 'fa-times' : 'fa-search'"></i>
                </button>
            </span>
        </div>
    </div>
</div>
<div class="row app-list">
    <div class="col-xs-6 col-md-3 text-center" ng-repeat="currentAppDefinition in filteredApps = (appDefinitions | filter:appDefinitionFilter | orderBy: appsOrder)">
        <div ng-click="openAppDefinition(currentAppDefinition)" class="app-logo" uib-tooltip="{{ currentAppDefinition.baseline }}">
            <div class="ribbon">
                <div class="new-app" ng-if="currentAppDefinition.isNew && !isEnabledApp(currentAppDefinition)">${message(code: 'is.ui.apps.new')}</div>
                <div class="enabled-app" ng-if="isEnabledApp(currentAppDefinition)">${message(code: 'is.ui.apps.enabled')}</div>
            </div>
            <img ng-src="{{ currentAppDefinition.logo }}"
                 alt="{{ currentAppDefinition.name }}">
        </div>
        <h5 ng-click="openAppDefinition(currentAppDefinition)">
            {{ currentAppDefinition.name }}
        </h5>
    </div>
    <div class="text-center more-results" ng-hide="filteredApps.length">
        <a href="${message(code: 'is.ui.apps.store.query')}{{ holder.appSearch }}">${message(code: 'is.ui.apps.store.search')}</a>
    </div>
</div>
</script>
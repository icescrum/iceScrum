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

<script type="text/ng-template" id="apps.modal.html">
<is:modal title="${message(code: 'is.ui.apps.title')}"
          class="apps-modal split-modal">
    <div class="row" ng-class="{'hide-left-panel': !appDefinition}">
        <div class="left-panel">
            <div class="left-panel-header">
                <div class="input-group">
                    <input type="text"
                           ng-model="holder.appSearch"
                           name="app-search-input"
                           value="{{ holder.appSearch }}"
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
            <ul class="left-panel-body nav nav-list">
                <div class="text-center more-results" ng-hide="filteredApps.length">
                    <a href="${message(code: 'is.ui.apps.store.query')}{{ holder.appSearch }}">${message(code:'is.ui.apps.store.search')}</a>
                </div>
                <li ng-class="{'current': currentAppDefinition == appDefinition}"
                    ng-repeat="currentAppDefinition in filteredApps = (appDefinitions | filter:appDefinitionFilter)">
                    <a ng-click="openAppDefinition(currentAppDefinition)" href>
                        <i class="fa fa-{{ currentAppDefinition.icon }}"></i>
                        {{ currentAppDefinition.name }}
                        <i ng-if="currentAppDefinition.installed" class="fa fa-check text-success"></i>
                    </a>
                </li>
            </ul>
        </div>
        <div class="right-panel">
            <div ng-if="appDefinition" class="app-details">
                <div ng-include="'app.details.html'"></div>
            </div>
            <div ng-if="!appDefinition">
                <div ng-include="'app.list.html'"></div>
            </div>
        </div>
    </div>
</is:modal>
</script>
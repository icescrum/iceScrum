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

<script type="text/ng-template" id="apps.modal.html">
<is:modal title="${message(code: 'is.ui.apps')}"
          footer="${false}"
          class="modal-split">
    <div class="row" ng-if="appDefinition">
        <div class="col-sm-3 modal-split-left">
            <div class="modal-split-search">
                <input type="text"
                       ng-model="holder.appSearch"
                       value="{{ holder.appSearch }}"
                       class="form-control search-input"
                       placeholder="${message(code: 'todo.is.ui.search.action')}">
            </div>
            <ul class="nav nav-pills nav-fill flex-column">
                <div class="text-center more-results" ng-hide="filteredApps.length">
                    <a href="${message(code: 'is.ui.apps.store.query')}{{ holder.appSearch }}">${message(code: 'is.ui.apps.store.search')}</a>
                </div>
                <li class="nav-item"
                    ng-repeat="currentAppDefinition in filteredApps = (appDefinitions | filter:appDefinitionFilter | orderBy: appsOrder)">
                    <a ng-click="openAppDefinition(currentAppDefinition)"
                       ng-class="{'active': currentAppDefinition == appDefinition}"
                       href
                       class="nav-link text-ellipsis">
                        {{:: currentAppDefinition.name }}
                        <i ng-if="isEnabledApp(currentAppDefinition)" class="fa fa-check text-success"></i>
                        <div class="app-state">
                            <div class="new-app" ng-if="currentAppDefinition.isNew && !isEnabledApp(currentAppDefinition)">${message(code: 'is.ui.apps.new')}</div>
                            <div class="enabled-app" ng-if="isEnabledApp(currentAppDefinition)">${message(code: 'is.ui.apps.enabled')}</div>
                        </div>
                    </a>
                </li>
            </ul>
        </div>
        <div class="col-sm-9 modal-split-right">
            <div ng-include="'app.details.html'"></div>
        </div>
    </div>
    <div class="row" ng-if="!appDefinition" ng-include="'app.list.html'"></div>
</is:modal>
</script>
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
<is:modal title="${message(code: 'is.dialog.manageApps.title')}"
          validate="true"
          name="manageAppsForm"
          form="manageApp(app)"
          class="manage-apps split-modal">
    <div class="row" ng-class="{ 'hide-left-panel': viewApp == 'list' }">
        <div class="left-panel">
            <div class="left-panel-header">
                <div class="input-group">
                    <input type="text"
                           ng-model="appSearch"
                           name="app-search-input"
                           value="{{ appSearch }}"
                           class="form-control"
                           placeholder="${message(code: 'todo.is.ui.search.action')}">
                    <span class="input-group-btn">
                        <button class="btn btn-default" type="button"><i class="fa fa-search"></i></button>
                    </span>
                </div>
            </div>
            <ul class="left-panel-body nav nav-list">
                <div class="text-center more-results" ng-hide="filteredApps.length">
                    <a href="${message(code: 'is.dialog.manageApps.store.query')}{{ appSearch }}">${message(code:'is.dialog.manageApps.store.search')}</a>
                </div>
                <li ng-class="{ 'current': currentApp == holder.app }"
                    ng-repeat="currentApp in filteredApps = (apps | filter:appSearch)">
                    <a ng-click="detailsApp(currentApp)" href>
                        <i class="fa fa-{{ currentApp.icon }}"></i>
                        {{ currentApp.name }}
                        <i ng-if="currentApp.installed" class="fa fa-check text-success"></i>
                    </a>
                </li>
            </ul>
        </div>
        <div class="right-panel" ng-switch on="viewApp">
            <div ng-switch-when="details" class="details-app">
                <div ng-include="'app.details.html'"></div>
            </div>
            <div ng-switch-when="empty" class="more-results">
                <a href="${message(code: 'is.dialog.manageApps.store.query')}">${message(code:'is.dialog.manageApps.store.search')}</a>
            </div>
            <div ng-switch-default>
                <div ng-include="'app.list.html'"></div>
            </div>
        </div>
    </div>
</is:modal>
</script>
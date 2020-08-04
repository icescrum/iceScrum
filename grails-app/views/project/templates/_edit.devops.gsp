%{--
- Copyright (c) 2020 Kagilum.
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

<script type="text/ng-template" id="edit.devops.project.html">
<div ng-controller="devopsCtrl">
    <g:include view="project/templates/_devops.diagram.gsp"/>
    <div class="devops-details mt-3">
        <div class="text-accent"><strong>{{ devopsActivity.name }}</strong></div>
        <p>{{ devopsActivity.description }}</p>
        <div class="d-flex flex-wrap">
            <div ng-repeat="devopsApp in devopsActivity.apps"
                 ng-click="showAppsModal(devopsApp.id)"
                 class="devops-app app-{{:: devopsApp.id}} mt-1 mb-3"
                 ng-class="{ 'devops-app-enabled': isEnabledApp(devopsApp) }">
                <div class="devops-app-new" ng-if="devopsApp.isNew && !isEnabledApp(devopsApp)">${message(code: 'is.ui.apps.new')}</div>
                <div class="devops-app-img">
                    <img ng-src="{{:: devopsApp.logo }}"
                         class=""
                         alt="{{:: devopsApp.name }}">
                </div>
                <div class="devops-app-name text-truncate text-center mt-2">
                    {{:: devopsApp.name }}
                </div>
            </div>
            <div ng-if="devopsActivity.apps && !devopsActivity.apps.length">
                <em>New Apps coming soon!</em>
            </div>
        </div>
    </div>
</div>
</script>

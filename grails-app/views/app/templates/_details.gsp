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

<script type="text/ng-template" id="app.details.html">
<h3>
    <button ng-click="openAppDefinition()"
            class="btn btn-default">
        <i class="fa fa-arrow-left"></i>
    </button>
    {{ appDefinition.name }}
    <i ng-if="isEnabledApp(appDefinition)"
       class="fa fa-check text-success pull-right"></i>
</h3>
<div ng-if="appDefinition.availableForServer && !appDefinition.enabledForServer">
    <div class="alert alert-warning" role="alert">
        ${message(code: 'is.ui.apps.server.disabled')}
    </div>
    <hr/>
</div>
<div ng-if="appDefinition.id == holder.displaySettingsWarning">
    <div class="alert alert-warning" role="alert">
        ${message(code: 'is.ui.apps.settings.warning')}
    </div>
    <hr/>
</div>
<div ng-if="appDefinition.id == holder.displayRefresh">
    <div class="alert alert-info" role="alert">
        ${message(code: 'is.ui.apps.settings.refresh')}
    </div>
    <hr/>
</div>
<entry:point id="app-details-before"/>
<div class="row">
    <div class="col-md-8">
        <div class="col-md-{{ 12 / appDefinition.screenshots.length }} thumbnail"
             ng-repeat="screenshot in appDefinition.screenshots">
            <img ng-src="{{ screenshot }}">
        </div>
    </div>
    <div class="col-md-4">
        <div class="text-center actions">
            <img ng-src="{{ appDefinition.logo }}"
                 alt="{{ appDefinition.name }}">
        </div>
        <div class="text-center actions"
             ng-if="authorizedApp('enableForProject', appDefinition)">
            <p ng-switch="isEnabledForProject(appDefinition)">
                <button ng-switch-when="false"
                        type="button"
                        class="btn btn-primary"
                        ng-click="updateEnabledForProject(appDefinition, true)">${message(code: 'is.ui.apps.enable')}</button>
                <button ng-switch-default
                        type="button"
                        class="btn btn-primary"
                        ng-click="updateEnabledForProject(appDefinition, false)">${message(code: 'is.ui.apps.disable')}</button>
            </p>
        </div>
        <div class="text-center actions"
             ng-if="authorizedApp('updateProjectSettings', appDefinition, project)">
            <p>
                <button type="button"
                        ng-click="openAppProjectSettings(appDefinition)"
                        class="btn btn-primary">
                    ${message(code: 'is.ui.apps.configure')}
                </button>
            </p>
        </div>
        <div class="text-center actions">
            <p>
                <a href="{{ appDefinition.docUrl }}"
                   target="_blank"
                   class="btn btn-default">
                    ${message(code: 'is.app.documentation')}
                </a>
            </p>
        </div>
    </div>
</div>
<div class="row">
    <div class="col-md-8">
        <em>{{ appDefinition.baseline }}</em>
        <p class="description" ng-bind-html="appDefinition.description"></p>
    </div>
    <div class="col-md-4">
        <h4>${message(code: 'is.ui.apps.information')}</h4>
        <table class="table information">
            <tr>
                <td class="text-right">${message(code:'is.app.author')}</td>
                <td><a href="mailto:support@kagilum.com">{{ appDefinition.author }}</a></td>
            </tr>
            <tr>
                <td class="text-right">${message(code:'is.app.version')}</td>
                <td>{{ appDefinition.version }}</td>
            </tr>
            <tr>
                <td class="text-right">${message(code:'is.app.widgets')}</td>
                <td>{{ appDefinition.hasWidgets ? '${message(code:'is.yes')}' : '${message(code:'is.no')}' }}</td>
            </tr>
            <tr>
                <td class="text-right">${message(code:'is.app.windows')}</td>
                <td>{{ appDefinition.hasWindows ? '${message(code:'is.yes')}' : '${message(code:'is.no')}' }}</td>
            </tr>
            <tr ng-if="appDefinition.websiteUrl">
                <td class="text-right"></td>
                <td>
                    <a href="{{ appDefinition.websiteUrl }}"
                       target="_blank">
                        ${message(code:'is.app.website')}
                    </a>
                </td>
            </tr>
        </table>
    </div>
</div>
<div class="row">
    <div class="col-md-12">
        <span class="text-muted" ng-repeat="tag in appDefinition.tags track by $index">
            <a href ng-click="searchApp(tag)">{{ tag }}</a>{{$last ? '' : ', '}}
        </span>
    </div>
</div>
</script>
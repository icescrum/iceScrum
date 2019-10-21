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
- Colin Bontemps (cbontemps@kagilum.com)
--}%

<script type="text/ng-template" id="app.details.html">
<div>
    <div class="mb-4">
        <a ng-click="openAppDefinition()"
           href
           class="link ">
            <i class="fa fa-arrow-left"></i> ${message(code: 'is.ui.back')}
        </a>
    </div>
    <div ng-if="appDefinition.availableForServer && !appDefinition.enabledForServer"
         class="alert bg-warning mb-3"
         role="alert">
        ${message(code: 'is.ui.apps.server.disabled')}
    </div>
    <div ng-if="appDefinition.id == holder.displaySettingsWarning"
         class="alert bg-warning mb-3"
         role="alert">
        ${message(code: 'is.ui.apps.settings.warning')}
    </div>
    <h3 class="d-flex align-items-center mb-4">
        <img ng-src="{{ appDefinition.logo }}"
             height="35"
             class="mr-1"
             alt="{{ appDefinition.name }}">
        <span class="mr-3">{{ appDefinition.name }}</span>
        <span class="app-enabled" ng-if="isEnabledApp(appDefinition)" title="${message(code: 'is.ui.apps.enabled')}"></span>
        <span class="app-new" ng-if="appDefinition.isNew && !isEnabledApp(appDefinition)">${message(code: 'is.ui.apps.new')}</span>
    </h3>
    <entry:point id="app-details-before"/>
    <div class="row">
        <div class="col-md-5 d-flex flex-column justify-content-between">
            <div>
                <strong>{{ appDefinition.baseline }}</strong>
                <div ng-bind-html="appDefinition.description"></div>
            </div>
            <div>
                <a href
                   class="link"
                   ng-repeat="tag in appDefinition.tags track by $index"
                   ng-click="searchApp(tag)">{{ tag + ($last ? '' : ', ') }}</a>
            </div>
        </div>
        <div class="col-md-7 row">
            <div class="col-md-{{ 12 / appDefinition.screenshots.length }} app-screenshot p-0"
                 ng-repeat="screenshot in appDefinition.screenshots">
                <a href
                   ng-click="showScreenshot(appDefinition, screenshot)">
                    <img ng-src="{{ screenshot }}"
                         class="img-fluid"/>
                </a>
            </div>
        </div>
        <div class="col-md-12 mt-5 d-flex justify-content-between flex-wrap">
            <div>
                <div>${message(code: 'is.app.author')}</div>
                <div><strong><a href="mailto:support@kagilum.com">{{ appDefinition.author }}</a></strong></div>
            </div>
            <div>
                <div>${message(code: 'is.app.version')}</div>
                <div><strong>{{ appDefinition.version }}</strong></div>
            </div>
            <div>
                <div>${message(code: 'is.app.widgets')}</div>
                <div><strong>{{ appDefinition.hasWidgets ? '${message(code: 'is.yes')}' : '${message(code: 'is.no')}' }}</strong></div>
            </div>
            <div>
                <div>${message(code: 'is.app.windows')}</div>
                <div><strong>{{ appDefinition.hasWindows ? '${message(code: 'is.yes')}' : '${message(code: 'is.no')}' }}</strong></div>
            </div>
            <entry:point id="app-infos-after"/>
            <div ng-if="appDefinition.websiteUrl">
                <div>${message(code: 'is.app.website')}</div>
                <div>
                    <a href="{{ appDefinition.websiteUrl }}"
                       class="link"
                       target="_blank">
                        {{ appDefinition.websiteUrl }}
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>
<div class="btn-toolbar align-self-end">
    <a href="{{ appDefinition.docUrl }}"
       target="_blank"
       class="btn btn-secondary">
        ${message(code: 'is.app.documentation')}
    </a>
    <button ng-if="authorizedApp('updateProjectSettings', appDefinition, project)"
            type="button"
            ng-click="openAppProjectSettings(appDefinition)"
            class="btn btn-primary">
        ${message(code: 'is.ui.apps.configure')}
    </button>
    <button ng-if="authorizedApp('enableForProject', appDefinition) && !isEnabledForProject(appDefinition)"
            type="button"
            class="btn btn-primary"
            ng-click="updateEnabledForProject(appDefinition, true)">${message(code: 'is.ui.apps.enable')}</button>
    <button ng-if="authorizedApp('enableForProject', appDefinition) && isEnabledForProject(appDefinition)"
            type="button"
            class="btn btn-danger"
            ng-click="updateEnabledForProject(appDefinition, false)">${message(code: 'is.ui.apps.disable')}</button>
    <a ng-if="authorizedApp('askToEnableForProject', appDefinition) && !isEnabledForProject(appDefinition)"
       href="mailto:{{ project.owner.email }}?subject=Enable {{ appDefinition.name }} app for {{ project.name }}?"
       type="button"
       class="btn btn-primary">${message(code: 'is.ui.apps.enable')}</a>
    <button ng-if="authorizedApp('askToEnableForProject', appDefinition) && !isEnabledForProject(appDefinition)"
            type="button"
            class="btn btn-success btn-sm"
            disabled="disabled"
            ng-click="updateEnabledForProject(appDefinition, false)">${message(code: 'is.ui.apps.enabled')}</button>
</div>
</script>

<script type="text/ng-template" id="app.details.screenshot.html">
<is:modal title="{{ title }}">
    <div class="text-center">
        <img ng-src="{{ srcURL }}"
             ng-click="$close()"
             style="width: 752px; border: 1px solid #ccc; cursor:pointer;"
             title="{{ title }}"/>
    </div>
</is:modal>
</script>
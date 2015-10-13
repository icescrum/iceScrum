<%@ page import="org.icescrum.core.utils.BundleUtils" %>
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
<script type="text/ng-template" id="feature.multiple.html">

<div class="panel panel-default">
    <div class="panel-heading">
        <h3 class="panel-title">${message(code: "is.ui.feature")} ({{ features.length }})</h3>
    </div>
    <div class="panel-body">
        <div class="postits standalone">
            <div class="postit-container stack twisted">
                <div style="{{ topFeature.color | createGradientBackground }}"
                     class="postit feature {{ topFeature.color | contrastColor }} {{ featurePreview.type | featureType }}">
                    <div class="head">
                        <span class="id">{{ topFeature.id }}</span>
                        <span class="estimation">{{ topFeature.value ? topFeature.value : '' }}</span>
                    </div>
                    <div class="content">
                        <h3 class="title"
                            ng-model="topFeature.name"
                            ng-bind-html="topFeature.name | sanitize"
                            ellipsis></h3>
                        <div class="description"
                             ng-model="topFeature.description"
                             ng-bind-html="topFeature.description | sanitize"
                             ellipsis></div>
                    </div>
                    <div class="tags">
                        <a ng-repeat="tag in topFeature.tags" href="#"><span class="tag">{{ tag }}</span></a>
                    </div>
                    <div class="actions">
                        <span class="action">
                            <a uib-tooltip="${message(code: 'todo.is.ui.actions')}" tooltip-append-to-body="true">
                                <i class="fa fa-cog"></i>
                            </a>
                        </span>
                        <span class="action" ng-class="{'active':topFeature.attachments.length}">
                            <a uib-tooltip="{{ topFeature.attachments.length | orElse: 0 }} ${message(code:'todo.is.ui.backlogelement.attachments.count')}"
                               tooltip-append-to-body="true">
                                <i class="fa fa-paperclip"></i>
                            </a>
                        </span>
                        <span class="action" ng-class="{'active':topFeature.stories_ids.length}">
                            <a uib-tooltip="{{ topFeature.stories_ids.length | orElse: 0 }} ${message(code:'todo.is.ui.feature.stories.count')}"
                               tooltip-append-to-body="true">
                                <i class="fa fa-tasks"></i>
                                <span class="badge" ng-show="topFeature.stories_ids.length">{{ topFeature.stories_ids.length }}</span>
                            </a>
                        </span>
                    </div>
                    <div class="progress">
                        <span class="status">3/6</span>
                        <div class="progress-bar" style="width:16.666666666666668%">
                        </div>
                    </div>
                    <div class="state">{{ topFeature.state | i18n:'FeatureStates' }}</div>
                </div>
            </div>
        </div>
        <form ng-submit="updateMultiple(featurePreview)"
              name='featureForm'
              show-validation
              novalidate>
            <div ng-if="authorizedFeature('update')"
                 class="clearfix no-padding">
                <div class="form-half">
                    <label for="type">${message(code:'is.feature.type')}</label>
                    <select class="form-control"
                            required
                            name="type"
                            ng-model="featurePreview.type"
                            data-placeholder="${message(code: 'todo.is.ui.feature.type.placeholder')}"
                            ui-select2>
                        <option></option>
                        <is:options values="${is.internationalizeValues(map: BundleUtils.featureTypes)}" />
                    </select>
                </div>
            </div>
            <div ng-if="authorizedFeature('update')"
                 class="btn-toolbar">
                <button class="btn btn-primary pull-right"
                        uib-tooltip="${message(code:'default.button.create.label')} (RETURN)"
                        tooltip-append-to-body="true"
                        type="submit">
                    ${message(code:'default.button.create.label')}
                </button>
                <button class="btn confirmation btn-default pull-right"
                        tooltip-append-to-body="true"
                        uib-tooltip="${message(code:'is.button.cancel')} (ESCAPE)"
                        type="button"
                        ng-click="goToNewFeature()">
                    ${message(code:'is.button.cancel')}
                </button>
            </div>
            <hr ng-if="authorizedFeature('update')"/>
            <div class="btn-toolbar">
                <div ng-if="authorizedFeature('copyToBacklog')"
                     class="btn-group">
                    <button type="button"
                            class="btn btn-default"
                            ng-click="copyToBacklogMultiple()">
                        <g:message code='is.ui.feature.menu.copy'/>
                    </button>
                </div>
                <div ng-if="authorizedFeature('delete')"
                     class="btn-group">
                    <button type="button"
                            class="btn btn-default"
                            ng-click="confirm({ message: '${message(code: 'is.confirm.delete')}', callback: deleteMultiple })">
                        <g:message code='is.ui.feature.menu.delete'/>
                    </button>
                </div>
            </div>
        </form>
    </div>
</div>
<div class="panel panel-default">
    <table class="table">
        <tr><td>${message(code: 'is.ui.feature.total.value')}</td><td>{{ sumValues(features) }}</td></tr>
        <tr><td>${message(code: 'is.ui.feature.total.stories')}</td><td>{{ sumStories(features) }}</td></tr>
    </table>
</div>
</script>
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
        <h3 class="panel-title">${message(code: "is.ui.feature.toolbar.new")} ${message(code: "is.feature")}</h3>
        <div class="help-block">${message(code:'is.ui.feature.help')}</div>
    </div>
    <div class="panel-body">
        <div class="postits standalone">
            <div class="postit-container stack twisted">
                <div style="{{ topFeature.color | createGradientBackground }}"
                     class="postit feature {{ topFeature.color | contrastColor }}">
                    <div class="head">
                        <span class="id">{{ topFeature.id }}</span>
                        <span class="estimation">{{ topFeature.value ? topFeature.value : '' }}</span>
                    </div>
                    <div class="content">
                        <h3 class="title" ng-bind-html="topFeature.name | sanitize" ellipsis></h3>
                        <div class="description" ng-bind-html="topFeature.description | sanitize" ellipsis></div>
                    </div>
                    <div class="tags">
                        <a ng-repeat="tag in topFeature.tags" href="#"><span class="tag">{{ tag }}</span></a>
                    </div>
                    <div class="actions">
                        <span class="action">
                            <a tooltip="${message(code: 'todo.is.ui.actions')}" tooltip-append-to-body="true">
                                <i class="fa fa-cog"></i>
                            </a>
                        </span>
                        <span class="action" ng-class="{'active':topFeature.attachments_count}">
                            <a tooltip="{{ topFeature.attachments_count }} ${message(code:'todo.is.backlogelement.attachments')}"
                               tooltip-append-to-body="true">
                                <i class="fa fa-paperclip"></i>
                            </a>
                        </span>
                        <span class="action" ng-class="{'active':topFeature.stories_count}">
                            <a tooltip="{{ topFeature.stories_count }} ${message(code:'todo.is.feature.stories')}"
                               tooltip-append-to-body="true">
                                <i class="fa fa-tasks"></i>
                                <span class="badge" ng-show="topFeature.stories_count">{{ topFeature.stories_count }}</span>
                            </a>
                        </span>
                    </div>
                    <div class="progress">
                        <span class="status">3/6</span>
                        <div class="progress-bar" style="width:16.666666666666668%">
                        </div>
                    </div>
                    <div class="state">{{ topFeature.state | i18n:'featureState' }}</div>
                </div>
            </div>
        </div>
        <form ng-submit="updateMultiple(featurePreview)"
              name='featureForm'
              show-validation
              novalidate>
            <div class="clearfix no-padding">
                <div class="form-half">
                    <label for="feature.type">${message(code:'is.feature.type')}</label>
                    <select class="form-control"
                            required
                            ng-model="featurePreview.type"
                            ng-readonly="!authorizedFeature('updateMultiple')"
                            data-placeholder="${message(code: 'todo.is.ui.feature.type.placeholder')}"
                            ui-select2>
                        <option></option>
                        <is:options values="${is.internationalizeValues(map: BundleUtils.featureTypes)}" />
                    </select>
                </div>
            </div>
            <div ng-if="authorizedFeature('updateMultiple')"
                 class="btn-toolbar">
                <button class="btn btn-primary pull-right"
                        tooltip="${message(code:'todo.is.ui.save')} (RETURN)"
                        tooltip-append-to-body="true"
                        type="submit">
                    ${message(code:'todo.is.ui.save')}
                </button>
                <button class="btn confirmation btn-default pull-right"
                        tooltip-append-to-body="true"
                        tooltip="${message(code:'is.button.cancel')} (ESCAPE)"
                        type="button"
                        ng-click="goToNewFeature()">
                    ${message(code:'is.button.cancel')}
                </button>
            </div>
            <hr/>
            <div class="btn-toolbar">
                <div ng-if="authorizedFeature('copyToBacklogMultiple')"
                     class="btn-group">
                    <button type="button"
                            class="btn btn-default"
                            ng-click="copyToBacklogMultiple()">
                        <g:message code='is.ui.feature.menu.copy'/>
                    </button>
                </div>
                <div ng-if="authorizedFeature('deleteMultiple')"
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
    <div class="panel-footer">
        ${message(code: 'is.ui.feature.total.value')} {{ totalValue(features) }}
    </div>
</div>
</script>
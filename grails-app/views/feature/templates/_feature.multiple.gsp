%{--
- Copyright (c) 2015 Kagilum.
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
<div class="panel panel-light">
    <div class="panel-heading">
        <h3 class="panel-title">
            ${message(code: "is.ui.feature")} ({{ features.length }})
            <a class="pull-right visible-on-hover btn btn-default"
               href="#/{{ ::viewName }}"
               uib-tooltip="${message(code: 'is.ui.window.closeable')}">
                <i class="fa fa-times"></i>
            </a>
        </h3>
    </div>
    <div class="panel-body">
        <div class="row">
            <div class="col-md-6">
                <div class="postits standalone">
                    <div class="postit-container stack twisted">
                        <div ng-style="topFeature.color | createGradientBackground"
                             class="postit {{ (topFeature.color | contrastColor) + ' ' + (featurePreview.type | featureType) }}">
                            <div class="head">
                                <div class="head-left">
                                    <span class="id">{{ topFeature.uid }}</span>
                                </div>
                                <div class="head-right">
                                    <span class="estimation">
                                        {{ topFeature.value ? topFeature.value : '' }} <i class="fa fa-line-chart"></i>
                                    </span>
                                </div>
                            </div>
                            <div class="content">
                                <h3 class="title"
                                    ng-model="topFeature.name"
                                    ng-bind-html="topFeature.name | sanitize"></h3>
                                <div class="description"
                                     ng-model="topFeature.description"
                                     ng-bind-html="topFeature.description | sanitize"></div>
                            </div>
                            <div class="footer">
                                <div class="tags">
                                    <a ng-repeat="tag in topFeature.tags" ng-click="setTagContext(tag)" href><span class="tag">{{ tag }}</span></a>
                                </div>
                                <div class="actions">
                                    <span class="action"><a><i class="fa fa-cog"></i> <i class="fa fa-caret-down"></i></a></span>
                                    <span class="action" ng-class="{'active':topFeature.attachments.length}">
                                        <a uib-tooltip="${message(code: 'todo.is.ui.backlogelement.attachments')}">
                                            <i class="fa fa-paperclip"></i>
                                        </a>
                                    </span>
                                    <span class="action" ng-class="{'active':topFeature.stories_ids.length}">
                                        <a uib-tooltip="${message(code: 'todo.is.ui.stories')}">
                                            <i class="fa fa-tasks"></i>
                                            <span class="badge">{{ topFeature.stories_ids.length || ''}}</span>
                                        </a>
                                    </span>
                                </div>
                                <div class="state-progress">
                                    <div class="state">{{ topFeature.state | i18n:'FeatureStates' }}</div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-6">
                <div class="btn-toolbar buttons-margin-bottom">
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
                <br/>
                <div class="table-responsive">
                    <table class="table">
                        <tr><td>${message(code: 'is.feature.value')}</td><td>{{ sumValues(features) }}</td></tr>
                        <tr><td>${message(code: 'todo.is.ui.stories')}</td><td>{{ sumStories(features) }}</td></tr>
                    </table>
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
                    <label for="type">${message(code: 'is.feature.type')}</label>
                    <ui-select class="form-control"
                               required
                               name="type"
                               ng-model="featurePreview.type">
                        <ui-select-match placeholder="${message(code: 'todo.is.ui.feature.type.placeholder')}">{{ $select.selected | i18n:'FeatureTypes' }}</ui-select-match>
                        <ui-select-choices repeat="featureType in featureTypes">{{ featureType | i18n:'FeatureTypes' }}</ui-select-choices>
                    </ui-select>
                </div>
            </div>
            <div ng-if="authorizedFeature('update')"
                 class="btn-toolbar">
                <button class="btn btn-primary pull-right"
                        type="submit">
                    ${message(code:'default.button.update.label')}
                </button>
                <a class="btn confirmation btn-default pull-right"
                   href="#/{{ ::viewName }}">
                    ${message(code: 'is.button.cancel')}
                </a>
            </div>
        </form>
    </div>
</div>
</script>
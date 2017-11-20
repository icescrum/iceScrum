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
<script type="text/ng-template" id="feature.new.html">
<div class="panel panel-light">
    <div class="panel-heading">
        <h3 class="panel-title row">
            <div class="left-title">
                <i class="fa fa-puzzle-piece" ng-style="{color: feature.color}"></i> <span class="item-name" title="${message(code: 'todo.is.ui.feature.new')}">${message(code: 'todo.is.ui.feature.new')}</span>
            </div>
            <div class="right-title">
                <details-layout-buttons ng-if="!isModal" remove-ancestor="false"/>
            </div>
        </h3>
    </div>
    <div class="details-no-tab">
        <div class="panel-body">
            <div class="help-block">${message(code: 'is.ui.feature.help')}</div>
            <div class="postits standalone">
                <div class="postit-container solo">
                    <div ng-style="feature.color | createGradientBackground"
                         class="postit {{ feature.color | contrastColor }}">
                        <div class="head">
                            <div class="head-left">
                                <span class="id">42</span>
                            </div>
                        </div>
                        <div class="content">
                            <h3 class="title">{{ feature.name }}</h3>
                        </div>
                        <div class="footer">
                            <div class="tags"></div>
                            <div class="actions">
                                <span class="action"><a><i class="fa fa-cog"></i> <i class="fa fa-caret-down"></i></a></span>
                                <span class="action"><a><i class="fa fa-paperclip"></i></a></span>
                                <span class="action"><a><i class="fa fa-tasks"></i></a></span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <form ng-submit="save(feature, false)"
                  name='formHolder.featureForm'
                  novalidate>
                <div class="clearfix no-padding">
                    <div class="form-group">
                        <label for="name">${message(code: 'is.feature.name')}</label>
                        <div class="input-group">
                            <input required
                                   name="name"
                                   autofocus
                                   ng-model="feature.name"
                                   type="text"
                                   class="form-control"
                                   ng-disabled="!authorizedFeature('create')"
                                   placeholder="${message(code: 'is.ui.feature.noname')}"/>
                            <span class="input-group-btn">
                                <button colorpicker
                                        class="btn {{ feature.color | contrastColor }}"
                                        type="button"
                                        ng-style="{'background-color': feature.color}"
                                        colorpicker-position="left"
                                        ng-click="refreshAvailableColors()"
                                        colors="availableColors"
                                        name="color"
                                        ng-model="feature.color"><i class="fa fa-pencil"></i> ${message(code: 'todo.is.ui.color')}</button>
                            </span>
                        </div>
                    </div>
                </div>
                <div ng-if="authorizedFeature('create')" class="btn-toolbar pull-right">
                    <button class="btn btn-primary"
                            ng-disabled="formHolder.featureForm.$invalid || application.submitting"
                            uib-tooltip="${message(code: 'todo.is.ui.create.and.continue')} (SHIFT+RETURN)"
                            hotkey="{'shift+return': hotkeyClick }"
                            hotkey-allow-in="INPUT"
                            type='button'
                            ng-click="save(feature, true)">
                        ${message(code: 'todo.is.ui.create.and.continue')}
                    </button>
                    <button class="btn btn-primary"
                            ng-disabled="formHolder.featureForm.$invalid || application.submitting"
                            type="submit">
                        ${message(code: 'default.button.create.label')}
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>
</script>

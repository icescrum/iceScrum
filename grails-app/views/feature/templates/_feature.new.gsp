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
<script type="text/ng-template" id="feature.new.html">
<div class="panel panel-default">
    <div class="panel-heading">
        <h3 class="panel-title">${message(code: "is.ui.feature.toolbar.new")} ${message(code: "is.feature")}</h3>
        <div class="help-block">${message(code:'is.ui.feature.help')}</div>
    </div>
    <div class="right-properties new panel-body">
        <div class="postits standalone">
            <div class="postit-container">
                <div style="{{ '#f9f157' | createGradientBackground }}"
                     class="postit feature {{ '#f9f157' | contrastColor }}">
                    <div class="head">
                        <span class="id">42</span>
                    </div>
                    <div class="content">
                        <h3 class="title" ng-bind-html="feature.name | sanitize" ellipsis></h3>
                    </div>
                    <div class="tags"></div>
                    <div class="actions">
                        <span class="action"><a><i class="fa fa-cog"></i></a></span>
                        <span class="action"><a><i class="fa fa-paperclip"></i></a></span>
                        <span class="action"><a><i class="fa fa-tasks"></i></a></span>
                    </div>
                    <div class="progress">
                        <span class="status">3/6</span>
                        <div class="progress-bar" style="width:16.666666666666668%">
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <form ng-submit="save(feature, false)"
              name='featureForm'
              show-validation
              novalidate>
            <div class="clearfix no-padding">
                <div class="form-half">
                    <label for="name">${message(code:'is.feature.name')}</label>
                    <input required
                           name="name"
                           ng-model="feature.name"
                           type="text"
                           class="form-control"
                           ng-readonly="!authorizedFeature('create')"
                           placeholder="${message(code: 'is.ui.feature.noname')}"/>
                </div>
            </div>
            <div ng-if="authorizedFeature('create')" class="btn-toolbar pull-right">
                <button class="btn btn-primary pull-right"
                        tooltip="${message(code:'todo.is.ui.save')} (RETURN)"
                        tooltip-append-to-body="true"
                        type="submit">
                    ${message(code:'todo.is.ui.save')}
                </button>
                <button class="btn btn-primary pull-right"
                        tooltip="${message(code:'todo.is.ui.save.and.continue')} (SHIFT+RETURN)"
                        tooltip-append-to-body="true"
                        hotkey="{'shift+return': hotkeyClick }"
                        hotkey-allow-in="INPUT"
                        type='button'
                        ng-click="save(feature, true)">
                    ${message(code:'todo.is.ui.save.and.continue')}
                </button>
            </div>
        </form>
    </div>
</div>
</script>

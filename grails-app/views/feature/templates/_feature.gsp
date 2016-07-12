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

<script type="text/ng-template" id="feature.html">
<div ng-style="feature.color | createGradientBackground: isAsListPostit(viewName)"
     class="postit {{ (feature.color | contrastColor) + ' ' + (feature.type | featureType) }}">
    <div class="head">
        <div class="head-left">
            <span class="id">{{ ::feature.uid }}</span>
        </div>
        <div class="head-right">
            <span class="value"
                  uib-tooltip="${message(code: 'is.feature.value')}"
                  ng-if="feature.value">
                {{ feature.value }} <i class="fa fa-line-chart"></i>
            </span>
        </div>
    </div>
    <div class="content"
         as-sortable-item-handle>
        <h3 class="title"
            ng-model="feature.name"
            ng-bind-html="feature.name | sanitize"></h3>
        <div class="description"
             ng-model="feature.description"
             ng-bind-html="feature.description | sanitize"></div>
    </div>
    <div class="footer">
        <div class="tags">
            <a ng-repeat="tag in feature.tags" ng-click="setTagContext(tag)" href><span class="tag">{{ tag }}</span></a>
        </div>
        <div class="actions">
            <span postit-menu="feature.menu.html" class="action"><a><i class="fa fa-cog"></i><i class="fa fa-caret-down"></i></a></span>
            <span class="action" ng-class="{'active':feature.attachments.length}">
                <a href="#/{{ ::viewName }}/{{ ::feature.id }}"
                   uib-tooltip="${message(code: 'todo.is.ui.backlogelement.attachments')}">
                    <i class="fa fa-paperclip"></i>
                    <span class="badge">{{ feature.attachments.length || '' }}</span>
                </a>
            </span>
            <span class="action" ng-class="{'active':feature.stories_ids.length}">
                <a href="#/{{ ::viewName }}/{{ ::feature.id }}/stories"
                   uib-tooltip="${message(code: 'todo.is.ui.stories')}">
                    <i class="fa fa-sticky-note"></i>
                    <span class="badge">{{ feature.stories_ids.length || '' }}</span>
                </a>
            </span>
        </div>
        <div class="state-progress">
            <div class="progress">
                <span class="status">{{ feature.countDoneStories + '/' + feature.stories_ids.length }}</span>
                <div class="progress-bar"
                     ng-style="{width: (feature.countDoneStories | percentProgress:feature.stories_ids.length) + '%'}">
                </div>
            </div>
            <div class="state hover-progress">{{ feature.state | i18n:'FeatureStates' }}</div>
        </div>
    </div>
</div>
</script>
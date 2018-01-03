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
     class="postit feature"
     ng-class="[(feature.color | contrastColor), (feature.type | featureType)]" is-watch="feature">
    <div class="head">
        <div class="head-left">
            <span class="id">{{:: feature.uid }}</span>
            <entry:point id="feature-postit-head-left"/>
        </div>
        <div class="head-right">
            <span class="value"
                  uib-tooltip="${message(code: 'is.feature.value')}"
                  ng-if="::feature.value">
                {{:: feature.value }} <i class="fa fa-line-chart"></i>
            </span>
        </div>
    </div>
    <div ng-class="::['content',{'without-description':!feature.description}]">
        <div as-sortable-item-handle>
            <h3 class="title">{{:: feature.name }}</h3>
            <div class="description"
                 ng-bind-html="::feature.description | lineReturns"></div>
        </div>
    </div>
    <div class="footer">
        <div class="tags">
            <icon-badge class="pull-right" tooltip="${message(code: 'is.backlogelement.tags')}"
                        href="{{:: openFeatureUrl(feature) }}"
                        icon="fa-tags"
                        max="3"
                        hide="true"
                        count="feature.tags.length"/>
            <a ng-repeat="tag in ::feature.tags"
               href="{{ tagContextUrl(tag) }}">
                <span class="tag">{{ tag }}</span>
            </a>
        </div>
        <div class="actions">
            <icon-badge tooltip="${message(code: 'todo.is.ui.backlogelement.attachments')}"
                        href="{{:: openFeatureUrl(feature) }}"
                        icon="fa-paperclip"
                        count="feature.attachments_count"/>
            <icon-badge tooltip="${message(code: 'todo.is.ui.stories')}"
                        href="{{:: openFeatureUrl(feature) }}/stories"
                        icon="fa-sticky-note"
                        count="feature.stories_ids.length"/>
            <span postit-menu="item.menu.html" ng-init="itemType = 'feature'" class="action"><a><i class="fa fa-ellipsis-h"></i></a></span>
        </div>
        <div class="state-progress">
            <div class="progress">
                <span class="status">{{:: feature.countDoneStories + '/' + feature.stories_ids.length }}</span>
                <div class="progress-bar"
                     ng-style="::{width: (feature.countDoneStories | percentProgress:feature.stories_ids.length) + '%'}">
                </div>
            </div>
            <div class="state hover-progress">{{:: feature.state | i18n:'FeatureStates' }}</div>
        </div>
    </div>
</div>
</script>
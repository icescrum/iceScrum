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
<div sticky-note-color="{{:: feature.color }}"
     class="sticky-note"
     ng-class=":: [(feature.color | contrastColor), (feature.type | featureType)]">
    <div as-sortable-item-handle>
        <div class="sticky-note-head" ng-class=":: story | idSizeClass">
            <div class="id-icon" ng-include="'feature.icon.html'"></div>
            <span class="id">{{:: feature.uid }}</span>
            <div class="sticky-note-type-icon"></div>
        </div>
        <div class="sticky-note-content" ng-class="::{'has-description':!!feature.description}">
            <div class="item-values">
                <span ng-if="::feature.value">
                    ${message(code: 'is.feature.value')} <strong>{{:: feature.value }}</strong>
                </span>
            </div>
            <div class="title">{{:: feature.name }}</div>
            <div class="description"
                 ng-bind-html="::feature.description | lineReturns"></div>
        </div>
        <div class="sticky-note-tags">
            <icon-badge class="float-right" tooltip="${message(code: 'is.backlogelement.tags')}"
                        href="{{:: openFeatureUrl(feature) }}"
                        icon="fa-tags"
                        max="3"
                        hide="true"
                        count="{{:: feature.tags.length }}"/>
            <a ng-repeat="tag in ::feature.tags"
               href="{{ tagContextUrl(tag) }}">
                <span class="tag {{ getTagColor(tag) | contrastColor }}"
                      ng-style="{'background-color': getTagColor(tag) }">{{:: tag }}</span>
            </a>
        </div>
        <div class="sticky-note-actions">
            <icon-badge tooltip="${message(code: 'todo.is.ui.backlogelement.attachments')}"
                        href="{{:: openFeatureUrl(feature) }}"
                        icon="attach"
                        count="{{:: feature.attachments_count }}"/>
            <icon-badge classes="comments"
                        tooltip="${message(code: 'todo.is.ui.comments')}"
                        href="{{:: openFeatureUrl(feature.id) }}/comments"
                        icon="comment"
                        count="{{:: feature.comments_count }}"/>
            <icon-badge tooltip="${message(code: 'todo.is.ui.stories')}"
                        href="{{:: openFeatureUrl(feature) }}/stories"
                        ng-if="feature.state >= featureStatesByName.TODO"
                        icon="story"
                        count="{{:: feature.stories_ids.length }}"/>
            <span sticky-note-menu="item.menu.html" ng-init="itemType = 'feature'" class="action"><a class="action-link"><span class="action-icon action-icon-menu"></span></a></span>
        </div>
        <div class="sticky-note-state-progress">
            <div ng-if="::showFeatureProgress(feature)" class="progress">
                <span class="status">{{:: feature.countDoneStories + '/' + feature.stories_ids.length }}</span>
                <div class="progress-bar"
                     ng-style="::{width: (feature.countDoneStories | percentProgress:feature.stories_ids.length) + '%'}">
                </div>
            </div>
            <div class="state"
                 ng-class="::{'state-hover-progress':stateHoverProgress(feature)}">{{:: feature.state | i18n:'FeatureStates' }}</div>
        </div>
    </div>
</div>
</script>
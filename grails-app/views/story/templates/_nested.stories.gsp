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

<script type="text/ng-template" id="nested.stories.html">
<div class="stories card-body">
    <table class="table" ng-controller="featureStoriesCtrl">
        <tbody ng-repeat="storyEntry in storyEntries" style="border-top: 0;">
            <tr>
                <th style="border-top: 0; padding:0">
                    <div class="text-center"
                         style="margin-top:30px;margin-bottom:10px;font-size:15px;"
                         ng-bind-html="storyEntry.label">
                    </div>
                </th>
            </tr>
            <tr ng-repeat="story in storyEntry.stories">
                <td class="content">
                    <div class="clearfix no-padding">
                        <div class="col-sm-8">
                            <span class="name">
                                <a ng-href="{{ openStoryUrl(story.id) }}" class="link"><strong>{{:: story.uid }}</strong>&nbsp;&nbsp;{{ story.name }}</a>
                            </span>
                        </div>
                        <div class="col-sm-4 text-right" ng-controller="storyCtrl">
                            <div class="btn-group">
                                <shortcut-menu ng-model="story" model-menus="menus" view-type="'list'" btn-sm="true"></shortcut-menu>
                                <div class="btn-group btn-group-sm" uib-dropdown>
                                    <button type="button" class="btn btn-secondary" uib-dropdown-toggle>
                                    </button>
                                    <ul uib-dropdown-menu class="pull-right" ng-init="itemType = 'story'" template-url="item.menu.html"></ul>
                                </div>
                                <visual-states ng-model="story" model-states="storyStatesByName"/>
                            </div>
                        </div>
                    </div>
                    <div class="clearfix no-padding" ng-if="story.description">
                        <p class="description form-control-static" ng-bind-html="story.description | lineReturns | actorTag: actors"></p>
                    </div>
                    <hr ng-if="!$last"/>
                </td>
            </tr>
            <tr>
                <td>
                    <div class="col-sm-12"
                         style="margin-top:10px;border-bottom:1px solid #eeeeee;margin-bottom:10px;">
                    </div>
                </td>
            </tr>
        </tbody>
        <tbody>
            <tr ng-show="selected.stories !== undefined && !selected.stories.length">
                <td class="empty-content">
                    <small>${message(code: 'todo.is.ui.story.empty')}</small>
                </td>
            </tr>
        </tbody>
    </table>
</div>
<div class="panel-footer" ng-controller="featureStoryCtrl">
    <div ng-if="authorizedStory('create')" ng-include="'feature.storyForm.editor.html'"></div>
</div>
</script>
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
<div class="stories panel-body">
    <table class="table">
        <tr ng-repeat="story in selected.stories">
            <td class="content">
                <div class="clearfix no-padding">
                    <div class="form-group col-sm-8">
                        <span class="name form-control-static">
                            <strong>{{:: story.uid }}</strong>&nbsp;&nbsp;{{ story.name }}
                        </span>
                    </div>
                    <div class="form-group col-sm-4" ng-controller="storyCtrl">
                        <div class="btn-group pull-right">
                            <shortcut-menu ng-model="story" model-menus="menus" view-type="'list'" btn-sm="true"></shortcut-menu>
                            <div class="btn-group btn-group-sm" uib-dropdown>
                                <button type="button" class="btn btn-default" uib-dropdown-toggle>
                                    <i class="fa fa-ellipsis-h"></i> <i class="fa fa-caret-down"></i>
                                </button>
                                <ul uib-dropdown-menu class="pull-right" ng-init="itemType = 'story'" template-url="item.menu.html"></ul>
                            </div>
                            <visual-states ng-model="story" model-states="storyStatesByName"/>
                        </div>
                    </div>
                </div>
                <div class="clearfix no-padding" ng-if="story.description">
                    <p class="description form-control-static" ng-bind-html="story.description | lineReturns | actorTag: story.actor"></p>
                </div>
                <hr ng-if="!$last"/>
            </td>
        </tr>
        <tr ng-show="selected.stories !== undefined && !selected.stories.length">
            <td class="empty-content">
                <small>${message(code:'todo.is.ui.story.empty')}</small>
            </td>
        </tr>
    </table>
</div>
</script>
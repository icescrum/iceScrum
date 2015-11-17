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
- Authors:Marwah Soltani (msoltani@kagilum.com)
-
--}%

<script type="text/ng-template" id="feed.panel.html">
<div ng-controller="FeedCtrl" class="panel panel-light">
    <div class="panel-heading">
        <h3 class="panel-title">
            <i class="fa fa-rss"></i> ${message(code: 'is.panel.feed')}
            <button class="pull-right visible-on-hover btn btn-default"
                    ng-click="toggleSettings()"
                    uib-tooltip="${message(code: 'todo.is.ui.setting')}">
                <i class="fa fa-cog"></i>
            </button>
        </h3>
    </div>
    <div class="panel-body feed" ng-switch="showSettings">
        <form ng-switch-when="true" class="form-horizontal">
            <div class="form-group">
                <label class="col-sm-2">${message(code: 'todo.is.ui.panel.feed.input')}</label>
                <div class="col-sm-7">
                    <input focus-me="true"
                           name="name"
                           class="form-control"
                           type="text"
                           placeholder="${message(code: 'todo.is.ui.panel.feed.input.add')}"
                           ng-model="feed.feedUrl"/>
                </div>
                <button type="button"
                        class="btn btn-default btn-sm"
                        ng-click="save(feed)">
                    ${message(code: 'is.button.add')}
                </button>
            </div>
            <div ng-show="hasFeeds()" class="form-group">
                <label class="col-sm-2">${message(code: 'todo.is.ui.panel.feed.list')}</label>
                <div class="col-sm-7">
                    <ui-select class="form-control"
                               ng-model="holder.selectedFeed"
                               on-select="selectFeed(holder.selectedFeed)">
                        <ui-select-match placeholder="${message(code: 'todo.is.ui.panel.feed.title.allFeed')}">{{ $select.selected.title }}</ui-select-match>
                        <ui-select-choices repeat="feed in feeds">{{feed.title}}</ui-select-choices>
                    </ui-select>
                </div>
                <button ng-disabled="disableDeleteButton"
                        type="button"
                        class="btn btn-default btn-sm"
                        ng-click="delete(holder.selectedFeed)">
                    ${message(code: 'default.button.delete.label')}
                </button>
            </div>
        </form>
        <div class="items" ng-switch-default>
            <div ng-show="!hasFeeds()">
                ${message(code: 'todo.is.ui.panel.feed.no.rss')}
            </div>
            <div ng-if="hasFeedChannel()">
                <h5><a target="_blank" href="{{feedChannel.link}}">{{feedChannel.title}}</a></h5>
                <p class="text-left">{{feedChannel.description | limitTo: 100}}{{feedChannel.description .length > 100 ? '...' : ''}}</p>
                <hr/>
            </div>
            <li ng-repeat="item in feedItems">
                {{item.item.titlefeed}}
                <h5><a target="_blank" href="{{item.item.link}}">{{item.item.title}}</a></h5>
                <p class="text-left">{{item.item.description | limitTo: 100}}{{item.item.description.length > 100 ? '...' : ''}}</p>
                <span class="small">{{item.item.pubDate | date: message('is.date.format.short.time')}}</span><hr/>
            </li>
        </div>
    </div>
</div>
</script>
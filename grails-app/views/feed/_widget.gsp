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
<is:widget widgetDefinition="${widgetDefinition}">
    <div ng-controller="feedWidgetCtrl">
        <div ng-if="holder.errorMessage" ng-bind-html="holder.errorMessage"></div>
        <div ng-if="!holder.errorMessage">
            <div ng-show="!widget.settings.feeds">
                ${message(code: 'is.ui.widget.feed.no.rss')}
            </div>
            <div ng-repeat="item in holder.feed.items">
                <div>
                    <div class="text-muted pull-right">
                        <time timeago datetime="{{ item.pubDate | dateToIso }}">
                            {{ item.pubDate | dateTime }}
                        </time>
                    </div>
                    <h5><a target="_blank" href="{{item.link}}" ng-bind-html="item.title"></a></h5>
                </div>
                <p class="text-left" ng-bind-html="item.description"></p>
                <hr ng-if="!$last"/>
            </div>
        </div>
    </div>
</is:widget>
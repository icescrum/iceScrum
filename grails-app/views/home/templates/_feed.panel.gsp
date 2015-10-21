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
        <div class="panel-body" ng-switch="showSettings">
            <table ng-switch-when="true">
                <tr>
                    <td>
                        ${message(code: 'todo.is.ui.panel.feed.input')}
                    </td>
                    <td>
                        <input type="text" ng-model="feed.feedUrl"/>
                    </td>
                    <td>
                        <button class="btn btn-default"
                                type="button"
                                ng-click="save(feed)">
                            ${message(code: 'is.button.add')}
                        </button>
                    </td>
                </tr>
                <tr ng-show="hasFeeds()"><td>${message(code: 'todo.is.ui.panel.feed.list')}</td>
                    <td>
                        <select class="form-control"
                                ng-model="selectedFeed"
                                ng-change="selectFeed(selectedFeed)"
                                ui-select2>
                            <option value="all">${message(code: 'todo.is.ui.panel.feed.title.allFeed')}</option>
                            <option ng-repeat="feed in feeds" value="{{feed.id}}">{{feed.feedUrl}}</option>
                        </select>
                    </td>
                    <td>
                        <button class="btn btn-default"
                                ng-disabled="disableDeleteButton"
                                type="button"
                                ng-model="selectedFeed"
                                ng-click="delete(selectedFeed)">
                            ${message(code: 'default.button.delete.label')}
                        </button>
                    </td>
                </tr>
            </table>
            <div class="feed" ng-switch-default>
                <div ng-if="hasFeedChannel()">
                    <h5><a target="_blank" href="{{feedChannel.link}}">{{feedChannel.title}}</a></h5>
                    <p class="text-left">{{feedChannel.description | limitTo: 100}}{{feedChannel.description .length > 100 ? '...' : ''}}</p>
                    <span class="small">{{feedChannel.pubDate}}</span>
                    <hr/>
                </div>
                <li ng-repeat="item in feedItems">
                    <h5><a target="_blank" href="{{item.item.link}}">{{item.item.title}}</a></h5>
                    <p class="text-left">{{item.item.description | limitTo: 100}}{{item.item.description.length > 100 ? '...' : ''}}</p>
                    <span class="small">{{item.item.pubDate}}</span>
                </li>
            </div>
        </div>
    </div>
</script>
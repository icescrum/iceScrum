<script type="text/ng-template" id="feed.panel.html">
    <div ng-controller="FeedCtrl" class="panel panel-primary">
        <div class="panel-heading">${message(code: 'is.panel.feed')}
            <button class="pull-right btn btn-default" ng-click="click()"><i class="fa fa-cog"></i></button>
        </div>
        <span ng-show="view">
            <table>
                <tr>
                    <td>${message(code: 'todo.is.ui.panel.feed.input')}</td><td><input type="text" ng-model="feed.feedUrl"/>
                </td>
                    <td><button class="btn btn-primary" ng-click="save(feed)">${message(code: 'is.button.add')}</button></td>
                </tr>
                <tr><td>${message(code: 'todo.is.ui.panel.feed.list')}</td>
                    <td>
                        <select
                                class="form-control"
                                placeholder="select Feed"
                                ng-model="selectedFeed"
                                ng-change="selectFeed(selectedFeed)"
                                ui-select2>
                            <option value="all">${message(code: 'todo.is.ui.panel.feed.title.allFeed')}</option>
                            <option ng-repeat="feed in feeds" value="{{feed.id}}">{{feed.feedUrl}}</option>
                        </select>
                    </td>
                    <td><button ng-model="selectedFeed" ng-click="delete(selectedFeed)"
                                class="btn btn-primary">${message(code: 'default.button.delete.label')}</button></td>
                </tr>
            </table>
        </span>
        <span ng-hide="view">
            <h5><a target="_blank" href="{{feed.link}}">{{feed.title}}</a></h5>

            <p class="text-left">{{feed.description | limitTo: 100}}{{feed.description .length > 100 ? '...' : ''}}</p>
            <span class="small">{{feed.pubDate}}</span>
            <li ng-repeat="item in feedItems">
                <h5><a target="_blank" href="{{item.item.link}}">{{item.item.title}}</a></h5>

                <p class="text-left">{{item.item.description | limitTo: 100}}{{item.item.description.length > 100 ? '...' : ''}}</p>
                <span class="small">{{item.item.pubDate}}</span>
            </li>
        </span>
    </div>
</script>
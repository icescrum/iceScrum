<script type="text/ng-template" id="rss.panel.html">
    <div ng-controller="FeedCtrl" class="panel panel-primary">
        <div class="panel-heading">${message(code: 'is.panel.rss')}
            <button class="pull-right btn btn-default" ng-click="click()"><i class="fa fa-cog"></i></button>
        </div>
        <span ng-show="view">
            <table>
                <tr>
                    <td>${message(code: 'todo.is.iu.panel.rss.input')}</td><td><input type="text" ng-model="rss.rssUrl"/>
                </td>
                    <td><button class="btn btn-primary" ng-click="save(rss)">Save</button></td>
                </tr>
                <tr><td>${message(code: 'todo.is.iu.panel.rss.list')}</td>
                    <td>
                        <select
                                class="form-control"
                                placeholder="select Rss"
                                ng-model="selectedRss"
                                ng-change="selectRss(selectedRss)"
                                ui-select2>
                            <option value="all">${message(code: 'todo.is.iu.panel.rss.title.allRss')}</option>
                            <option ng-repeat="rss in rssList" value="{{rss.id}}">{{rss.rssUrl}}</option>
                        </select>
                    </td>
                    <td><button ng-model="selectedRss" ng-click="delete(selectedRss)"
                                class="btn btn-primary">Delete</button></td>
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
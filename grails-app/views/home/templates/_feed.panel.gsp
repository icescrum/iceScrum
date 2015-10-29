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
                    <select class="form-control"
                            ng-model="holder.selectedFeed"
                            ng-change="selectFeed(holder.selectedFeed)"
                            class="form-control"
                            ui-select2>
                        <option value="all">${message(code: 'todo.is.ui.panel.feed.title.allFeed')}</option>
                        <option ng-repeat="feed in feeds" value="{{feed.id}}">{{feed.title}}</option>
                    </select>
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
                <span class="small">{{item.item.pubDate | date:"dd/MM/yyyy - HH:mm:ss"}}</span><hr/>
            </li>
        </div>
    </div>
</div>
</script>
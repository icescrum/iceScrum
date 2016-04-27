<form ng-switch-when="true"
      ng-controller="FeedCtrl"
      ng-submit="save(feed)"
      class="form-horizontal">
    <div class="form-group">
        <label class="col-sm-2">${message(code: 'todo.is.ui.panel.feed.input')}</label>
        <div class="col-sm-7">
            <input autofocus
                   name="name"
                   class="form-control"
                   type="text"
                   placeholder="${message(code: 'todo.is.ui.panel.feed.input.add')}"
                   ng-model="feed.feedUrl"/>
        </div>
        <button type="submit"
                ng-disabled="!feed.feedUrl"
                class="btn btn-default">
            ${message(code: 'is.button.add')}
        </button>
    </div>
    <div ng-show="hasFeeds()" class="form-group">
        <label class="col-sm-2">${message(code: 'todo.is.ui.panel.feed.list')}</label>
        <div class="col-sm-7">
            <ui-select class="form-control"
                       ng-model="holder.selectedFeed"
                       on-select="selectFeed(holder.selectedFeed)">
                <ui-select-match allow-clear="true" placeholder="${message(code: 'todo.is.ui.panel.feed.title.allFeed')}">{{ $select.selected.title }}</ui-select-match>
                <ui-select-choices repeat="feed in feeds">{{feed.title}}</ui-select-choices>
            </ui-select>
        </div>
        <button ng-disabled="disableDeleteButton"
                type="button"
                class="btn btn-default"
                ng-click="delete(holder.selectedFeed)">
            ${message(code: 'default.button.delete.label')}
        </button>
    </div>
</form>
%{--
- Copyright (c) 2017 Kagilum.
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
<div class="form-group">
    <label>${message(code: 'is.ui.widget.feed.input')}</label>
    <div class="input-group">
        <input autofocus
               name="name"
               class="form-control"
               type="text"
               placeholder="${message(code: 'is.ui.widget.feed.input.add')}"
               ng-model="holder.feedUrl"/>
        <span class="input-group-append">
            <button ng-click="add(holder.feedUrl)"
                    type="button"
                    ng-disabled="!holder.feedUrl"
                    class="btn btn-primary btn-sm">
                ${message(code: 'is.button.add')}
            </button>
        </span>
    </div>
</div>
<div ng-show="widget.settings.feeds" class="form-group">
    <label>${message(code: 'is.ui.widget.feed.list')}</label>
    <div class="input-group">
        <ui-select class="form-control"
                   ng-model="holder.selected"
                   on-select="onSelect($item, $model)"
                   on-remove="onRemove($item, $model)">
            <ui-select-match allow-clear="true" placeholder="${message(code: 'is.ui.widget.feed.title.allFeed')}">{{ $select.selected.title }}</ui-select-match>
            <ui-select-choices repeat="feed in widget.settings.feeds">{{feed.title}}</ui-select-choices>
        </ui-select>
        <span class="input-group-append">
            <button ng-disabled="disableDeleteButton"
                    type="button"
                    class="btn btn-danger btn-sm"
                    ng-click="deleteFeed(holder.selected)">
                ${message(code: 'default.button.delete.label')}
            </button>
        </span>
    </div>
</div>
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
<tr ng-show="getSelected().stories === undefined">
    <td class="empty-content">
        <i class="fa fa-refresh fa-spin"></i>
    </td>
</tr>
<tr ng-repeat="story in getSelected().stories">
    <td>
        <div class="content">
            <span class="label label-default"
                  tooltip-placement="left"
                  tooltip="${message(code: 'is.backlogelement.id')}">{{ story.uid }}</span>
            <a href="#">{{ story.name }}</a>
            <div class="pretty-printed"
                 ng-bind-html="story | descriptionHtml | sanitize">
            </div>
        </div>
    </td>
</tr>
<tr ng-show="!getSelected().stories.length">
    <td class="empty-content">
        <small>${message(code:'todo.is.ui.story.empty')}</small>
    </td>
</tr>
</script>
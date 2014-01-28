%{--
- Copyright (c) 2014 Kagilum
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
-
--}%
<ul class="list postit-rows"
    id="widget-${controllerName}"
    style="display:${stories ? 'block' : 'none'};"
    ${request.productOwner || request.scrumMaster ? 'data-ui-draggable' : ''}
    data-ui-draggable-selector=".postit-row"
    data-ui-draggable-helper="clone"
    data-ui-draggable-connect-to-sortable='.backlog.connectableToWidgetBacklog'
    data-ui-draggable-append-to="body"
    data-ui-draggable-start="$.icescrum.onStartDragWidget"
    data-ui-draggable-stop="$.icescrum.onStopDragWidget"
    data-binding
    data-binding-type="story"
    data-binding-selector="li.postit-row-story"
    data-binding-tpl="tpl-postit-row-story"
    data-binding-watch="items"
    data-binding-highlight="true"
    data-binding-config="backlog">
</ul>

<div class="box-blank" style="display:${stories ? 'none' : 'block'};">
    ${message(code: 'is.widget.backlog.empty')}
</div>

<entry:point id="${controllerName}-${actionName}-widget" model="[stories:stories]"/>
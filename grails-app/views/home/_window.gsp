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
<div id="view-home" class="view">
    <div class="content">
        <div class="row">
            <div class="panel-column">
                <div ng-if="authenticated()" ng-include="'userProjects.panel.html'" class="panel-userProjects"></div>
                <div as-sortable="widgetSortableOptions | merge: sortableScrollOptions('#view-home')"
                     ng-model='widgetsLeft'>
                    <div ng-include="'ui/widget/'+widget.id"
                         as-sortable-item
                         id="{{ widget.id }}"
                         class="panel-container widget-{{ widget.id }}"
                         ng-repeat="widget in widgetsLeft"></div>
                </div>
            </div>
            <div class="panel-column">
                <div as-sortable="widgetSortableOptions | merge: sortableScrollOptions('#view-home')"
                     ng-model='widgetsRight'>
                    <div ng-include="'ui/widget/'+widget.id"
                         as-sortable-item
                         id="{{ widget.id }}"
                         class="panel-container widget-{{ widget.id }}"
                         ng-repeat="widget in widgetsRight"></div>
                </div>
            </div>
        </div>
    </div>
</div>
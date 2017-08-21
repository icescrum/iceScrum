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
        <div class="row widgets"
             as-sortable="widgetSortableOptions"
             ng-model="widgets">
            <div as-sortable-item
                 ng-include src="templateWidgetUrl(widget)"
                 id="{{ widget.id }}"
                 ng-controller="widgetCtrl"
                 class="widget widget-{{ widget.widgetDefinitionId }} widget-height-{{ widget.height }} widget-width-{{ widget.width }}"
                 ng-repeat="widget in widgets"></div>
        </div>
        <div class="add-widget" ng-if="authenticated()">
            <button class="btn btn-primary" ng-click="showAddWidgetModal()">
                <i class="fa fa-plus fa-2x" aria-hidden="true"></i>
            </button>
        </div>
    </div>
</div>
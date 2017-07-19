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
            <div class="widget-column">
                <div as-sortable="widgetSortableOptionsLeft | merge: sortableScrollOptions('#view-home')"
                     is-disabled="!authenticated()"
                     ng-model='widgetsOnLeft'>
                    <div ng-include src="templateWidgetUrl(widget)"
                         as-sortable-item
                         id="{{ widget.id }}"
                         class="panel-container widget-{{ widget.id }}"
                         ng-repeat="widget in widgetsOnLeft"></div>
                    <div class="add-widget" ng-if="authenticated()">
                        <button class="btn btn-default" ng-click="showAddWidgetModal()">
                            <i class="fa fa-plus" aria-hidden="true"></i> <g:message code="is.ui.widget.new"/>
                        </button>
                    </div>
                </div>
            </div>
            <div class="widget-column">
                <div as-sortable="widgetSortableOptionsRight | merge: sortableScrollOptions('#view-home')"
                     is-disabled="!authenticated()"
                     ng-model='widgetsOnRight'>
                    <div ng-include src="templateWidgetUrl(widget)"
                         as-sortable-item
                         id="{{ widget.id }}"
                         class="panel-container widget-{{ widget.id }}"
                         ng-repeat="widget in widgetsOnRight"></div>
                    <div class="add-widget" ng-if="authenticated()">
                        <button class="btn btn-default" ng-click="showAddWidgetModal(true)">
                            <i class="fa fa-plus" aria-hidden="true"></i> <g:message code="is.ui.widget.new"/>
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
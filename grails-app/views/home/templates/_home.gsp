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

<script type="text/ng-template" id="home.html">
    <div id="view-home" class="view col-sm-12 no-flex">
        <div class="col-md-6"
             as-sortable="panelSortableListeners"
             ng-model='panelsLeft' >
            <div ng-include="panel.id+'.panel.html'"
                 as-sortable-item
                 id="{{ panel.id }}"
                 ng-repeat="panel in panelsLeft"></div>
        </div>
        <div class="col-md-6"
             as-sortable="panelSortableListeners"
             ng-model='panelsRight'>
            <div ng-include="panel.id+'.panel.html'"
                 as-sortable-item
                 id="{{ panel.id }}"
                 ng-repeat="panel in panelsRight"></div>
        </div>
    </div>
</script>

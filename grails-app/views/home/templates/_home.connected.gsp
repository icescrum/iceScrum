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
<script type="text/ng-template" id="home.connected.html">
<ul id =panel style="list-style-type:none;" ng-controller="positionPanelCtrl"
     html-sortable html-sortable-callback="sortablePanelUpdate(startModel, destModel, start, end)"
     ng-model='panels'
     ng-init='panels'
     class="row">
    <li id="{{ panel.id }}" ng-repeat="panel in panels" class="col-md-5">
        <div ng-include="panel.id+'.panel.html'"></div>
    </li>
</ul>
</script>
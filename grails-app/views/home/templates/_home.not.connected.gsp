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
<script type="text/ng-template" id="home.not.connected.html">
<div html-sortable class="row" id="panelhome">
    <div class="col-md-4">
        <div class="panel panel-primary">
            <div class="panel-heading ">
                <h3 class="panel-title">${message(code: 'is.connection')}</h3>
            </div>
            <div class="panel-body">
                <div ng-include="'login.panel.html'"></div>
            </div>
        </div>
    </div>
    <div class="col-md-4" >
        <div class="panel panel-primary">
            <div class="panel-heading">
                <h4 class="panel-title">${message(code: 'is.panel.project.public')}</h4>
            </div>
            <div ng-include="'projectsList.panel.html'"></div>
        </div>
    </div>
</div>
</script>



%{--
- Copyright (c) 2017 Kagilum SAS.
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

<div id="carousel-whats-new" class="carousel slide" data-ride="carousel">
    <ol class="carousel-indicators">
        <li data-target="#carousel-whats-new" data-slide-to="0" class="active"></li>
        <li data-target="#carousel-whats-new" data-slide-to="1"></li>
    </ol>
    <div class="carousel-inner" role="listbox">
        <div class="item text-center active">
            <asset:image src="/whatsNew/diagrams.png" style="max-height:500px; margin:0 auto;"/>
            <div class="carousel-caption" style="text-shadow: 0 0 2px rgba(0,0,0,.6)">
                <h3>New App: create diagrams and mockups</h3>
                <p><strong>Use draw.io to create flowcharts, process diagrams, org charts, mockups, UML… directly in iceScrum.</strong></p>
                <p><button ng-click="$close(); showAppsModal('drawIO');" class="btn btn-primary">Enable it now!</button></p>
            </div>
        </div>
        <div class="item text-center">
            <asset:image src="/whatsNew/epics.png" style="max-height:500px;  margin:0 auto;"/>
            <div class="carousel-caption" style="text-shadow: 0 0 2px rgba(0,0,0,.6)">
                <h3>New App: create epic stories</h3>
                <p><strong>Identify stories that are too big and split them into smaller ones.</strong></p>
                <p><button ng-click="$close(); showAppsModal('epic');" class="btn btn-primary">Enable it now!</button></p>
            </div>
        </div>
    </div>
</div>
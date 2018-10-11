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
            <asset:image src="/whatsNew/story-workflow.jpg" style="max-height:500px; margin:0 auto;"/>
            <div class="carousel-caption" style="text-shadow: 0 0 2px rgba(0,0,0,.6)">
                <h3>New App: Story workflow</h3>
                <p><strong>Customize the story workflow on your project and add the "Frozen" and "In review" states.</strong></p>
                <p><button ng-click="$close(); showAppsModal('storyWorkflow');" class="btn btn-primary">Enable it now!</button></p>
            </div>
        </div>
        <div class="item text-center">
            <asset:image src="/whatsNew/time-tracking.png" style="max-height:500px;  margin:0 auto;"/>
            <div class="carousel-caption" style="text-shadow: 0 0 2px rgba(0,0,0,.6)">
                <h3>New App: Time tracking</h3>
                <p><strong>Track the time spent by tasks during the sprint.</strong></p>
                <p><button ng-click="$close(); showAppsModal('taskTimeTracking');" class="btn btn-primary">Enable it now!</button></p>
            </div>
        </div>
    </div>
</div>
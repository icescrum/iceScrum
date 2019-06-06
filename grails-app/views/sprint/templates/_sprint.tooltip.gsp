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
- Authors:
-
- Vincent Barrier (vbarrier@kagilum.com)
- Nicolas Noullet (nnoullet@kagilum.com)
--}%
<script type="text/ng-template" id="sprint.tooltip.html">
<div ng-if="sprint.state">{{ sprint.startDate | dayShorter }} | {{ sprint.endDate | dayShorter }}
    <div>{{ sprint.state | i18n:'SprintStates' }}</div>
    <div ng-if="sprint.capacity || sprint.velocity">
        <span>{{ message('is.sprint.' + (sprint.state > sprintStatesByName.TODO ? 'velocity' : 'plannedVelocity')) }}</span>
        <strong ng-if="sprint.state > sprintStatesByName.TODO">{{ sprint.velocity | roundNumber:2 }} /</strong>
        <strong>{{ sprint.capacity | roundNumber:2 }}</strong>
    </div>
</script>
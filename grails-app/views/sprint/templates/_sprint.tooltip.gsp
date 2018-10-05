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
<p ng-if="sprint.goal">{{ sprint.goal }}</p>
<p ng-if="sprint.state">{{ sprint.state | i18n:'SprintStates' }}</p>
<p ng-if="sprint.capacity || sprint.velocity">{{ (sprint.velocity | roundNumber:2) + '/' + (sprint.capacity | roundNumber:2) }} (${message(code: 'is.sprint.velocity')} / ${message(code: 'is.sprint.plannnedVelocity')})</p>
<p><i class="fa fa-calendar"></i> {{ sprint.startDate | dayShorter }} <i class="fa fa-arrow-right"></i> {{ sprint.endDate | dayShorter }}</p>
</script>